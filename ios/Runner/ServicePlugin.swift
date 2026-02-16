import CryptoKit
import Flutter
import Foundation
import NetworkExtension

private enum SharedKeys {
  static let appGroupId = "group.com.follow.flClash"
  static let sharedState = "shared_state"
  static let leafConfig = "leaf_config_json"
  static let leafConfigRecord = "leaf_config_record_v1"
  static let leafConfigFile = "leaf_config_v1.json"
  static let leafSelectedTag = "leaf_selected_tag"
  static let lastHeartbeat = "leaf_last_heartbeat"
}

private enum LeafConfigConstants {
  static let version = 1
}

private extension Data {
  var sha256Hex: String {
    SHA256.hash(data: self).map { String(format: "%02x", $0) }.joined()
  }
}

enum VPNError: LocalizedError {
  case configurationInvalid(String)
  case permissionDenied
  case tunnelStartFailed(String)
  case providerNotReady(String)
  case networkExtensionUnavailable
  case autoRecoveryFailed(String)
  case unknown(String)

  var errorDescription: String? {
    switch self {
    case .configurationInvalid(let details):
      return "Config invalid: \(details)"
    case .permissionDenied:
      return "VPN permission denied"
    case .tunnelStartFailed(let reason):
      return "VPN start failed: \(reason)"
    case .providerNotReady(let reason):
      return "VPN provider not ready: \(reason)"
    case .networkExtensionUnavailable:
      return "Network Extension unavailable"
    case .autoRecoveryFailed(let reason):
      return "VPN auto recovery failed: \(reason)"
    case .unknown(let message):
      return "Unknown VPN error: \(message)"
    }
  }

  var errorCode: String {
    switch self {
    case .configurationInvalid:
      return "CONFIG_INVALID"
    case .permissionDenied:
      return "PERMISSION_DENIED"
    case .tunnelStartFailed:
      return "TUNNEL_START_FAILED"
    case .providerNotReady:
      return "PROVIDER_NOT_READY"
    case .networkExtensionUnavailable:
      return "NE_UNAVAILABLE"
    case .autoRecoveryFailed:
      return "AUTO_RECOVERY_FAILED"
    case .unknown:
      return "UNKNOWN"
    }
  }

  static func from(_ error: Error, context: String) -> VPNError {
    if let error = error as? VPNError {
      return error
    }

    let nsError = error as NSError
    if nsError.domain == NEVPNErrorDomain {
      switch nsError.code {
      case 1:
        return .configurationInvalid(context)
      case 2:
        return .permissionDenied
      case 3:
        return .tunnelStartFailed(context)
      case 4, 5:
        return .networkExtensionUnavailable
      default:
        break
      }
    }

    let lowered = nsError.localizedDescription.lowercased()
    if lowered.contains("permission") || lowered.contains("not authorized") {
      return .permissionDenied
    }

    return .unknown(context)
  }
}

struct LeafConfigRecord {
  let version: Int
  let checksum: String
  let timestamp: TimeInterval
  let config: String

  static func make(config: String) throws -> LeafConfigRecord {
    guard let data = config.data(using: .utf8) else {
      throw VPNError.configurationInvalid("Config is not UTF-8")
    }

    return LeafConfigRecord(
      version: LeafConfigConstants.version,
      checksum: data.sha256Hex,
      timestamp: Date().timeIntervalSince1970,
      config: config
    )
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> LeafConfigRecord {
    guard let version = dict["version"] as? Int else {
      throw VPNError.configurationInvalid("Config record missing version")
    }
    guard let checksum = dict["checksum"] as? String, !checksum.isEmpty else {
      throw VPNError.configurationInvalid("Config record missing checksum")
    }
    guard let timestamp = dict["timestamp"] as? TimeInterval else {
      throw VPNError.configurationInvalid("Config record missing timestamp")
    }
    guard let config = dict["config"] as? String, !config.isEmpty else {
      throw VPNError.configurationInvalid("Config record missing config")
    }

    guard version == LeafConfigConstants.version else {
      throw VPNError.configurationInvalid("Unsupported config version: \(version)")
    }

    guard let data = config.data(using: .utf8) else {
      throw VPNError.configurationInvalid("Config payload is not UTF-8")
    }

    guard data.sha256Hex == checksum else {
      throw VPNError.configurationInvalid("Config checksum mismatch")
    }

    return LeafConfigRecord(version: version, checksum: checksum, timestamp: timestamp, config: config)
  }

  func toDictionary() -> [String: Any] {
    [
      "version": version,
      "checksum": checksum,
      "timestamp": timestamp,
      "config": config,
    ]
  }
}

enum LeafConfigValidator {
  static func parseRoot(_ config: String) throws -> [String: Any] {
    guard let data = config.data(using: .utf8) else {
      throw VPNError.configurationInvalid("Config is not UTF-8")
    }

    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw VPNError.configurationInvalid("Config root must be a JSON object")
    }

    try validate(root)
    return root
  }

  static func validate(_ root: [String: Any]) throws {
    guard root["inbounds"] is [[String: Any]] else {
      throw VPNError.configurationInvalid("Missing or invalid 'inbounds' field")
    }
    guard let outbounds = root["outbounds"] as? [[String: Any]], !outbounds.isEmpty else {
      throw VPNError.configurationInvalid("Missing or empty 'outbounds' field")
    }
    let hasValidOutbound = outbounds.contains { outbound in
      guard let `protocol` = outbound["protocol"] as? String else {
        return false
      }
      return !`protocol`.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    guard hasValidOutbound else {
      throw VPNError.configurationInvalid("No valid outbound found")
    }
  }
}

final class ServicePlugin: NSObject, FlutterPlugin {
  private let tunnelManager = TunnelManager.shared
  private var channel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.follow.clash/service", binaryMessenger: registrar.messenger())
    let instance = ServicePlugin()
    instance.channel = channel
    instance.tunnelManager.setStatusSink { [weak instance] status in
      instance?.emitVpnStatus(status)
    }
    instance.tunnelManager.setErrorSink { [weak instance] message in
      instance?.emitCoreError(message)
    }
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      result("")
    case "shutdown":
      result(true)
    case "syncState":
      if let state = call.arguments as? String {
        tunnelManager.storeSharedState(state)
      }
      result("")
    case "syncLeafConfig":
      if let config = call.arguments as? String {
        switch tunnelManager.storeLeafConfig(config) {
        case .success:
          tunnelManager.reloadConfigIfConnected(config) { outcome in
            DispatchQueue.main.async {
              result(outcome.rawValue)
            }
          }
        case .failure:
          DispatchQueue.main.async {
            result("invalid_config")
          }
        }
      } else {
        result("invalid_config")
      }
    case "selectNode":
      if let nodeTag = call.arguments as? String, !nodeTag.isEmpty {
        tunnelManager.storeSelectedNode(nodeTag)
        tunnelManager.selectNodeIfConnected(nodeTag) { outcome in
          DispatchQueue.main.async {
            result(outcome == .applied || outcome == .stored)
          }
        }
      } else {
        result(false)
      }
    case "start":
      tunnelManager.start { success, error in
        DispatchQueue.main.async {
          let payload: [String: Any] = [
            "success": success,
            "error": error?.localizedDescription ?? "",
            "errorCode": error?.errorCode ?? "",
          ]
          result(payload)
        }
      }
    case "stop":
      tunnelManager.stop()
      result(true)
    case "getRunTime":
      tunnelManager.fetchStartTimestampMs { timestamp in
        DispatchQueue.main.async {
          result(timestamp)
        }
      }
    case "getLastError":
      result(tunnelManager.lastErrorPayload())
    case "getTunFd":
      result(nil)
    case "enableSocketProtection", "disableSocketProtection":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func emitVpnStatus(_ status: NEVPNStatus) {
    let statusValue = TunnelManager.statusString(status)
    let connected = status == .connected || status == .connecting || status == .reasserting
    let args: [String: Any] = [
      "status": statusValue,
      "connected": connected,
    ]
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod("vpnStatus", arguments: args)
    }
  }

  private func emitCoreError(_ message: String) {
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod("coreError", arguments: message)
    }
  }
}

final class TunnelManager {
  enum ProviderCommandOutcome: String {
    case applied = "applied"
    case stored = "stored"
    case failed = "failed"
  }

  static let shared = TunnelManager()

  private var manager: NETunnelProviderManager?
  private let stateQueue = DispatchQueue(label: "com.follow.flclash.tunnel.state")
  private var _startDate: Date?
  private var _lastError: VPNError?
  private var _lastRecoveryAttempt: Date?
  private var statusSink: ((NEVPNStatus) -> Void)?
  private var errorSink: ((String) -> Void)?
  private var statusObserver: NSObjectProtocol?
  private var heartbeatMonitor: DispatchSourceTimer?

  private var startDate: Date? {
    get { stateQueue.sync { _startDate } }
    set { stateQueue.sync { _startDate = newValue } }
  }

  private var lastError: VPNError? {
    get { stateQueue.sync { _lastError } }
    set { stateQueue.sync { _lastError = newValue } }
  }

  private var lastRecoveryAttempt: Date? {
    get { stateQueue.sync { _lastRecoveryAttempt } }
    set { stateQueue.sync { _lastRecoveryAttempt = newValue } }
  }

  private init() {}

  func storeSharedState(_ state: String) {
    UserDefaults(suiteName: SharedKeys.appGroupId)?.set(state, forKey: SharedKeys.sharedState)
  }

  @discardableResult
  func storeLeafConfig(_ config: String) -> Result<Void, VPNError> {
    do {
      _ = try LeafConfigValidator.parseRoot(config)
      let record = try LeafConfigRecord.make(config: config)
      try persistLeafConfigRecord(record)
      return .success(())
    } catch let error as VPNError {
      recordError(error)
      return .failure(error)
    } catch {
      let mapped = VPNError.configurationInvalid(error.localizedDescription)
      recordError(mapped)
      return .failure(mapped)
    }
  }

  func storeSelectedNode(_ nodeTag: String) {
    UserDefaults(suiteName: SharedKeys.appGroupId)?.set(nodeTag, forKey: SharedKeys.leafSelectedTag)
  }

  func fetchStartTimestampMs(completion: @escaping (Int64?) -> Void) {
    if let manager {
      completion(timestampMs(from: manager.connection))
      return
    }
    NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
      guard error == nil, let manager = managers?.first else {
        completion(nil)
        return
      }
      self?.manager = manager
      self?.observeStatusChanges(for: manager)
      completion(self?.timestampMs(from: manager.connection))
    }
  }

  func startTimestampMs() -> Int64? {
    guard let startDate else { return nil }
    return Int64(startDate.timeIntervalSince1970 * 1000)
  }

  func stop() {
    manager?.connection.stopVPNTunnel()
    stopHeartbeatMonitor()
    startDate = nil
  }

  func setStatusSink(_ sink: @escaping (NEVPNStatus) -> Void) {
    statusSink = sink
    if let manager {
      observeStatusChanges(for: manager)
    }
  }

  func setErrorSink(_ sink: @escaping (String) -> Void) {
    errorSink = sink
  }

  func start(completion: @escaping (Bool, VPNError?) -> Void) {
    loadOrCreateManager { [weak self] manager, error in
      guard let self else {
        completion(false, .tunnelStartFailed("Tunnel manager deallocated"))
        return
      }
      if let error {
        let mapped = VPNError.from(error, context: "Failed to load VPN preferences")
        self.recordError(mapped)
        completion(false, mapped)
        return
      }

      self.manager = manager
      guard let manager else {
        let mapped = VPNError.networkExtensionUnavailable
        self.recordError(mapped)
        completion(false, mapped)
        return
      }

      let status = manager.connection.status
      if status == .connected {
        self.startDate = manager.connection.connectedDate ?? self.startDate ?? Date()
        self.verifyProviderReady(completion: completion)
        return
      }

      if status == .connecting || status == .reasserting {
        self.waitUntilConnected(manager: manager, timeout: 20) { connected in
          guard connected else {
            let mapped = VPNError.tunnelStartFailed("Timed out while waiting for VPN connection")
            self.recordError(mapped)
            completion(false, mapped)
            return
          }
          self.startDate = manager.connection.connectedDate ?? self.startDate ?? Date()
          self.verifyProviderReady(completion: completion)
        }
        return
      }

      do {
        try manager.connection.startVPNTunnel()
      } catch {
        let mapped = VPNError.from(error, context: "Failed to start VPN tunnel")
        self.recordError(mapped)
        completion(false, mapped)
        return
      }

      self.waitUntilConnected(manager: manager, timeout: 20) { connected in
        guard connected else {
          let mapped = VPNError.tunnelStartFailed("Timed out while waiting for VPN connection")
          self.recordError(mapped)
          completion(false, mapped)
          return
        }
        self.startDate = manager.connection.connectedDate ?? self.startDate ?? Date()
        self.verifyProviderReady(completion: completion)
      }
    }
  }

  func reloadConfigIfConnected(_ config: String, completion: @escaping (ProviderCommandOutcome) -> Void) {
    let sent = sendProviderCommand(
      type: "reload_config",
      payload: ["config": config]
    ) { response in
      completion(response == "ok" ? .applied : .failed)
    }
    if !sent {
      completion(.stored)
    }
  }

  func selectNodeIfConnected(_ nodeTag: String, completion: @escaping (ProviderCommandOutcome) -> Void) {
    let sent = sendProviderCommand(
      type: "select_node",
      payload: ["tag": nodeTag]
    ) { response in
      completion(response == "ok" ? .applied : .failed)
    }
    if !sent {
      completion(.stored)
    }
  }

  func lastErrorPayload() -> [String: String]? {
    guard let lastError else {
      return nil
    }
    return [
      "error": lastError.localizedDescription,
      "errorCode": lastError.errorCode,
    ]
  }

  private func persistLeafConfigRecord(_ record: LeafConfigRecord) throws {
    guard let defaults = UserDefaults(suiteName: SharedKeys.appGroupId) else {
      throw VPNError.networkExtensionUnavailable
    }

    guard let url = sharedConfigRecordURL() else {
      throw VPNError.networkExtensionUnavailable
    }

    let payload = record.toDictionary()
    let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
    try data.write(to: url, options: .atomic)

    defaults.set(payload, forKey: SharedKeys.leafConfigRecord)
    defaults.set(record.config, forKey: SharedKeys.leafConfig)
  }

  private func sharedConfigRecordURL() -> URL? {
    guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedKeys.appGroupId) else {
      return nil
    }
    return groupURL.appendingPathComponent(SharedKeys.leafConfigFile)
  }

  private func providerBundleIdentifier() -> String? {
    guard let appBundleId = Bundle.main.bundleIdentifier else { return nil }
    return "\(appBundleId).PacketTunnel"
  }

  private func sendProviderCommand(
    type: String,
    payload: [String: Any],
    completion: ((String?) -> Void)? = nil
  ) -> Bool {
    guard let session = manager?.connection as? NETunnelProviderSession else {
      return false
    }
    guard session.status == .connected else {
      return false
    }
    var body = payload
    body["type"] = type
    guard let data = try? JSONSerialization.data(withJSONObject: body) else {
      return false
    }
    do {
      try session.sendProviderMessage(data) { responseData in
        let response = responseData.flatMap { String(data: $0, encoding: .utf8) }
        completion?(response)
      }
    } catch {
      return false
    }
    return true
  }

  private func verifyProviderReady(completion: @escaping (Bool, VPNError?) -> Void) {
    let sent = sendProviderCommand(type: "health_check", payload: [:]) { [weak self] response in
      if response == "ok" {
        completion(true, nil)
      } else {
        self?.startDate = nil
        let mapped = VPNError.providerNotReady("Packet tunnel health check failed")
        self?.recordError(mapped)
        completion(false, mapped)
      }
    }
    if !sent {
      startDate = nil
      let mapped = VPNError.providerNotReady("Unable to communicate with packet tunnel provider")
      recordError(mapped)
      completion(false, mapped)
    }
  }

  private func waitUntilConnected(
    manager: NETunnelProviderManager,
    timeout: TimeInterval,
    completion: @escaping (Bool) -> Void
  ) {
    if manager.connection.status == .connected {
      completion(true)
      return
    }

    var observer: NSObjectProtocol?
    var finished = false
    let center = NotificationCenter.default
    func finish(_ success: Bool) {
      if finished { return }
      finished = true
      if let observer {
        center.removeObserver(observer)
      }
      completion(success)
    }

    observer = center.addObserver(
      forName: .NEVPNStatusDidChange,
      object: manager.connection,
      queue: .main
    ) { [weak self] _ in
      let status = manager.connection.status
      self?.handleStatusChange(status, connection: manager.connection)
      if status == .connected {
        finish(true)
      } else if status == .disconnected || status == .invalid {
        finish(false)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
      finish(manager.connection.status == .connected)
    }
  }

  private func observeStatusChanges(for manager: NETunnelProviderManager) {
    if let statusObserver {
      NotificationCenter.default.removeObserver(statusObserver)
      self.statusObserver = nil
    }
    statusObserver = NotificationCenter.default.addObserver(
      forName: .NEVPNStatusDidChange,
      object: manager.connection,
      queue: .main
    ) { [weak self] _ in
      self?.handleStatusChange(manager.connection.status, connection: manager.connection)
    }
    handleStatusChange(manager.connection.status, connection: manager.connection)
  }

  private func handleStatusChange(_ status: NEVPNStatus, connection: NEVPNConnection) {
    if status == .connected {
      startDate = connection.connectedDate ?? startDate ?? Date()
      if let manager {
        startHeartbeatMonitor(for: manager)
      }
    } else if status == .disconnected || status == .invalid || status == .disconnecting {
      startDate = nil
      stopHeartbeatMonitor()
    }
    statusSink?(status)
  }

  private func startHeartbeatMonitor(for manager: NETunnelProviderManager) {
    stopHeartbeatMonitor()

    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline: .now() + .seconds(30), repeating: .seconds(30))
    timer.setEventHandler { [weak self, weak manager] in
      guard let self, let manager else { return }
      self.checkHeartbeat(manager: manager)
    }
    heartbeatMonitor = timer
    timer.resume()
  }

  private func stopHeartbeatMonitor() {
    heartbeatMonitor?.setEventHandler {}
    heartbeatMonitor?.cancel()
    heartbeatMonitor = nil
  }

  private func checkHeartbeat(manager: NETunnelProviderManager) {
    guard manager.connection.status == .connected else {
      return
    }

    let timestamp = UserDefaults(suiteName: SharedKeys.appGroupId)?.double(forKey: SharedKeys.lastHeartbeat) ?? 0
    guard timestamp > 0 else {
      return
    }

    let age = Date().timeIntervalSince1970 - timestamp
    guard age > 60 else {
      return
    }

    let staleError = VPNError.providerNotReady("Packet tunnel heartbeat stale (\(Int(age))s)")
    recordError(staleError)

    verifyProviderReady { [weak self] ok, _ in
      guard let self else { return }
      guard !ok else { return }
      self.tryAutoRecover(manager: manager)
    }
  }

  private func tryAutoRecover(manager: NETunnelProviderManager) {
    let now = Date()
    if let last = lastRecoveryAttempt, now.timeIntervalSince(last) < 90 {
      return
    }
    lastRecoveryAttempt = now

    manager.connection.stopVPNTunnel()
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
      guard let self else { return }
      do {
        try manager.connection.startVPNTunnel()
      } catch {
        let mapped = VPNError.autoRecoveryFailed(error.localizedDescription)
        self.recordError(mapped)
      }
    }
  }

  private func timestampMs(from connection: NEVPNConnection) -> Int64? {
    let status = connection.status
    guard status == .connected || status == .connecting || status == .reasserting else {
      startDate = nil
      return nil
    }
    if let connectedDate = connection.connectedDate {
      startDate = connectedDate
    } else if startDate == nil {
      startDate = Date()
    }
    guard let startDate else { return nil }
    return Int64(startDate.timeIntervalSince1970 * 1000)
  }

  private func loadOrCreateManager(completion: @escaping (NETunnelProviderManager?, Error?) -> Void) {
    NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
      if let error {
        completion(nil, error)
        return
      }

      let manager = managers?.first ?? NETunnelProviderManager()
      self?.configure(manager)
      self?.observeStatusChanges(for: manager)

      manager.saveToPreferences { saveError in
        if let saveError {
          completion(nil, saveError)
          return
        }

        manager.loadFromPreferences { loadError in
          completion(loadError == nil ? manager : nil, loadError)
        }
      }
    }
  }

  private func configure(_ manager: NETunnelProviderManager) {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
      ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
      ?? "App"
    let proto = NETunnelProviderProtocol()
    proto.providerBundleIdentifier = providerBundleIdentifier()
    proto.serverAddress = appName
    proto.disconnectOnSleep = false

    manager.protocolConfiguration = proto
    manager.localizedDescription = "\(appName) VPN"
    manager.isEnabled = true
  }

  private func recordError(_ error: VPNError) {
    lastError = error
    errorSink?("[\(error.errorCode)] \(error.localizedDescription)")
  }

  static func statusString(_ status: NEVPNStatus) -> String {
    switch status {
    case .invalid:
      return "invalid"
    case .disconnected:
      return "disconnected"
    case .connecting:
      return "connecting"
    case .connected:
      return "connected"
    case .reasserting:
      return "reasserting"
    case .disconnecting:
      return "disconnecting"
    @unknown default:
      return "unknown"
    }
  }
}
