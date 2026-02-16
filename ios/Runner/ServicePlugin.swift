import Flutter
import Foundation
import NetworkExtension

private enum SharedKeys {
  static let appGroupId = "group.com.follow.flClash"
  static let sharedState = "shared_state"
  static let leafConfig = "leaf_config_json"
  static let leafSelectedTag = "leaf_selected_tag"
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
        tunnelManager.storeLeafConfig(config)
        tunnelManager.reloadConfigIfConnected(config) { outcome in
          DispatchQueue.main.async {
            result(outcome.rawValue)
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
      tunnelManager.start { success in
        DispatchQueue.main.async {
          result(success)
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
}

final class TunnelManager {
  enum ProviderCommandOutcome: String {
    case applied = "applied"
    case stored = "stored"
    case failed = "failed"
  }

  static let shared = TunnelManager()

  private var manager: NETunnelProviderManager?
  private var startDate: Date?
  private var statusSink: ((NEVPNStatus) -> Void)?
  private var statusObserver: NSObjectProtocol?

  private init() {}

  func storeSharedState(_ state: String) {
    UserDefaults(suiteName: SharedKeys.appGroupId)?.set(state, forKey: SharedKeys.sharedState)
  }

  func storeLeafConfig(_ config: String) {
    UserDefaults(suiteName: SharedKeys.appGroupId)?.set(config, forKey: SharedKeys.leafConfig)
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
    startDate = nil
  }

  func setStatusSink(_ sink: @escaping (NEVPNStatus) -> Void) {
    statusSink = sink
    if let manager {
      observeStatusChanges(for: manager)
    }
  }

  func start(completion: @escaping (Bool) -> Void) {
    loadOrCreateManager { [weak self] manager, error in
      guard let self else {
        completion(false)
        return
      }
      if error != nil || manager == nil {
        completion(false)
        return
      }

      self.manager = manager
      guard let manager else {
        completion(false)
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
            completion(false)
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
        completion(false)
        return
      }

      self.waitUntilConnected(manager: manager, timeout: 20) { connected in
        guard connected else {
          completion(false)
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

  private func verifyProviderReady(completion: @escaping (Bool) -> Void) {
    let sent = sendProviderCommand(type: "health_check", payload: [:]) { [weak self] response in
      if response == "ok" {
        completion(true)
      } else {
        self?.startDate = nil
        completion(false)
      }
    }
    if !sent {
      startDate = nil
      completion(false)
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
    } else if status == .disconnected || status == .invalid || status == .disconnecting {
      startDate = nil
    }
    statusSink?(status)
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
