import CryptoKit
import Foundation
import NetworkExtension
#if canImport(leaf)
import leaf
#endif

private enum SharedKeys {
  static let appGroupId = "group.com.follow.flClash"
  static let leafConfig = "leaf_config_json"
  static let leafConfigRecord = "leaf_config_record_v1"
  static let leafConfigFile = "leaf_config_v1.json"
  static let leafSelectedTag = "leaf_selected_tag"
  static let recentLogs = "recent_logs"
  static let lastHeartbeat = "leaf_last_heartbeat"
}

private enum PacketTunnelConstants {
  static let configVersion = 1
  static let startupProbeDelayMs = 450
  static let defaultMTU = 1500
  static let heartbeatIntervalSeconds = 10
  static let maxSharedLogLines = 1000
  static let defaultDNSServers = ["1.1.1.1", "8.8.8.8"]
}

private extension Data {
  var sha256Hex: String {
    SHA256.hash(data: self).map { String(format: "%02x", $0) }.joined()
  }
}

private enum LogLevel: Int {
  case debug = 0
  case info = 1
  case warn = 2
  case error = 3

  var label: String {
    switch self {
    case .debug:
      return "DEBUG"
    case .info:
      return "INFO"
    case .warn:
      return "WARN"
    case .error:
      return "ERROR"
    }
  }
}

private enum PacketTunnelError: LocalizedError {
  case missingTunFd
  case invalidConfig(String)
  case leafNotLinked
  case leafRuntimeFailed(Int32, String)

  var errorDescription: String? {
    switch self {
    case .missingTunFd:
      return "Unable to read packet flow file descriptor"
    case .invalidConfig(let reason):
      return "Invalid leaf config: \(reason)"
    case .leafNotLinked:
      return "leaf.xcframework is not linked in PacketTunnel target"
    case .leafRuntimeFailed(let code, let action):
      return "leaf \(action) failed with code \(code)"
    }
  }
}

private final class LeafRuntime {
  static let shared = LeafRuntime()

  private let runtimeId: UInt16 = 1
  private let stateQueue = DispatchQueue(label: "com.follow.flclash.packet.leaf.state")
  private let runQueue = DispatchQueue(label: "com.follow.flclash.packet.leaf.run")
  private var isRunning = false
  private var lastExitCode: Int32 = 0

  private init() {}

  func start(configJson: String, completion: @escaping (Error?) -> Void) {
#if canImport(leaf)
    stateQueue.async {
      if self.isRunning {
        completion(nil)
        return
      }

      let testCode: Int32 = configJson.withCString { ptr in
        leaf_test_config_string(ptr)
      }
      guard testCode == 0 else {
        completion(PacketTunnelError.leafRuntimeFailed(testCode, "test_config"))
        return
      }

      self.isRunning = true
      self.lastExitCode = 0

      self.runQueue.async {
        let runCode: Int32 = configJson.withCString { ptr in
          leaf_run_with_options_config_string(self.runtimeId, ptr, true, true, 0, 0)
        }
        self.stateQueue.async {
          self.isRunning = false
          self.lastExitCode = runCode
        }
      }

      // Probe startup result shortly after launch. This keeps the app-side
      // startup timeout low while still surfacing immediate runtime failures.
      self.stateQueue.asyncAfter(deadline: .now() + .milliseconds(PacketTunnelConstants.startupProbeDelayMs)) {
        if self.isRunning {
          completion(nil)
        } else {
          completion(PacketTunnelError.leafRuntimeFailed(self.lastExitCode, "start"))
        }
      }
    }
#else
    completion(PacketTunnelError.leafNotLinked)
#endif
  }

  func stop() {
#if canImport(leaf)
    stateQueue.async {
      if self.isRunning {
        _ = leaf_shutdown(self.runtimeId)
      }
      self.isRunning = false
    }
#endif
  }

  func reload(configJson: String) -> Bool {
#if canImport(leaf)
    var ok = false
    stateQueue.sync {
      guard self.isRunning else { return }
      let code: Int32 = configJson.withCString { ptr in
        leaf_reload_with_config_string(self.runtimeId, ptr)
      }
      ok = (code == 0)
    }
    return ok
#else
    return false
#endif
  }

  func selectNode(_ nodeTag: String) -> Bool {
#if canImport(leaf)
    var ok = false
    stateQueue.sync {
      guard self.isRunning else { return }
      let code: Int32 = "proxy".withCString { outboundPtr in
        nodeTag.withCString { nodePtr in
          leaf_set_outbound_selected(self.runtimeId, outboundPtr, nodePtr)
        }
      }
      if code == 0 {
        _ = leaf_close_connections(self.runtimeId)
        ok = true
      }
    }
    return ok
#else
    return false
#endif
  }

  func runtimeRunning() -> Bool {
    var running = false
    stateQueue.sync {
      running = self.isRunning
    }
    return running
  }
}

class PacketTunnelProvider: NEPacketTunnelProvider {
  private var tunFd: Int32?
  private let heartbeatQueue = DispatchQueue(label: "com.follow.flclash.packet.heartbeat")
  private var heartbeatTimer: DispatchSourceTimer?

  private func log(
    _ message: String,
    level: LogLevel = .info,
    file: String = #file,
    line: Int = #line
  ) {
    let filename = (file as NSString).lastPathComponent
#if DEBUG
    NSLog("[PacketTunnel][\(level.label)][\(filename):\(line)] \(message)")
#else
    if level.rawValue >= LogLevel.warn.rawValue {
      NSLog("[PacketTunnel][\(level.label)] \(message)")
    }
#endif

    if level.rawValue >= LogLevel.warn.rawValue {
      appendSharedLog("[\(Int(Date().timeIntervalSince1970))][\(level.label)] \(message)")
    }
  }

  override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    do {
      let baseConfig = try loadLeafConfigFromSharedStore()
      let baseRoot = try parseConfig(baseConfig)
      try validateLeafConfig(baseRoot)

      let dnsServers = extractDNSServers(from: baseRoot)
      let mtu = extractMTU(from: baseRoot)
      let settings = buildNetworkSettings(dnsServers: dnsServers, mtu: mtu)

      setTunnelNetworkSettings(settings) { [weak self] error in
        guard let self else {
          completionHandler(PacketTunnelError.invalidConfig("provider deallocated"))
          return
        }
        if let error {
          self.log("Failed to apply tunnel settings: \(error.localizedDescription)", level: .error)
          completionHandler(error)
          return
        }

        do {
          let fd = try self.readTunFileDescriptor()
          self.tunFd = fd
          let runtimeConfig = try self.buildRuntimeConfig(baseRoot, tunFd: fd, mtu: mtu)

          LeafRuntime.shared.start(configJson: runtimeConfig) { startError in
            if let startError {
              self.log("Leaf runtime start failed: \(startError.localizedDescription)", level: .error)
              self.rollbackTunnel(error: startError, completionHandler: completionHandler)
              return
            }

            self.startHeartbeat()
            self.applySavedSelection()
            self.log("Packet tunnel started with leaf runtime")
            completionHandler(nil)
          }
        } catch {
          self.log("Packet tunnel startup failed: \(error.localizedDescription)", level: .error)
          self.rollbackTunnel(error: error, completionHandler: completionHandler)
        }
      }
    } catch {
      log("Packet tunnel preflight failed: \(error.localizedDescription)", level: .error)
      completionHandler(error)
    }
  }

  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    stopHeartbeat()
    LeafRuntime.shared.stop()
    tunFd = nil
    log("Packet tunnel stopped, reason=\(reason.rawValue)")
    completionHandler()
  }

  override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
    guard
      let object = try? JSONSerialization.jsonObject(with: messageData),
      let payload = object as? [String: Any],
      let type = payload["type"] as? String
    else {
      completionHandler?("invalid_message".data(using: .utf8))
      return
    }

    switch type {
    case "health_check":
      let ok = LeafRuntime.shared.runtimeRunning()
      completionHandler?((ok ? "ok" : "not_running").data(using: .utf8))

    case "reload_config":
      guard let tunFd else {
        completionHandler?("tun_not_ready".data(using: .utf8))
        return
      }

      let baseConfig: String
      if let config = payload["config"] as? String, !config.isEmpty {
        baseConfig = config
      } else {
        do {
          baseConfig = try loadLeafConfigFromSharedStore()
        } catch {
          log("Reload failed while loading config: \(error.localizedDescription)", level: .error)
          completionHandler?("invalid_config".data(using: .utf8))
          return
        }
      }

      reloadRuntime(configJson: baseConfig, tunFd: tunFd) { response in
        completionHandler?(response.data(using: .utf8))
      }

    case "select_node":
      guard let nodeTag = payload["tag"] as? String, !nodeTag.isEmpty else {
        completionHandler?("invalid_tag".data(using: .utf8))
        return
      }
      let ok = LeafRuntime.shared.selectNode(nodeTag)
      completionHandler?((ok ? "ok" : "select_failed").data(using: .utf8))

    default:
      completionHandler?("unsupported".data(using: .utf8))
    }
  }

  override func sleep(completionHandler: @escaping () -> Void) {
    completionHandler()
  }

  override func wake() {}

  private func rollbackTunnel(error: Error, completionHandler: @escaping (Error?) -> Void) {
    tunFd = nil
    stopHeartbeat()
    setTunnelNetworkSettings(nil) { [weak self] clearError in
      if let clearError {
        self?.log("Failed to rollback tunnel settings: \(clearError.localizedDescription)", level: .warn)
      }
      completionHandler(error)
    }
  }

  private func reloadRuntime(configJson: String, tunFd: Int32, completion: @escaping (String) -> Void) {
    do {
      let baseRoot = try parseConfig(configJson)
      try validateLeafConfig(baseRoot)

      let dnsServers = extractDNSServers(from: baseRoot)
      let mtu = extractMTU(from: baseRoot)
      let settings = buildNetworkSettings(dnsServers: dnsServers, mtu: mtu)

      setTunnelNetworkSettings(settings) { [weak self] settingsError in
        guard let self else {
          completion("provider_deallocated")
          return
        }
        if let settingsError {
          self.log("Failed to apply runtime tunnel settings: \(settingsError.localizedDescription)", level: .warn)
          completion("settings_failed")
          return
        }

        do {
          let runtimeConfig = try self.buildRuntimeConfig(baseRoot, tunFd: tunFd, mtu: mtu)
          let ok = LeafRuntime.shared.reload(configJson: runtimeConfig)
          if ok {
            self.applySavedSelection()
            completion("ok")
          } else {
            completion("reload_failed")
          }
        } catch {
          self.log("Failed to build runtime config during reload: \(error.localizedDescription)", level: .error)
          completion("invalid_config")
        }
      }
    } catch {
      log("Reload config validation failed: \(error.localizedDescription)", level: .error)
      completion("invalid_config")
    }
  }

  private func readTunFileDescriptor() throws -> Int32 {
    let flowObject = packetFlow as NSObject
    // iOS does not expose a public TUN fd API on NEPacketTunnelFlow.
    // We rely on the de-facto key path used by VPN apps.
    guard let number = flowObject.value(forKeyPath: "socket.fileDescriptor") as? NSNumber else {
      throw PacketTunnelError.missingTunFd
    }
    return number.int32Value
  }

  private func loadLeafConfigFromSharedStore() throws -> String {
    if let url = sharedConfigRecordURL(),
       let data = try? Data(contentsOf: url),
       let object = try? JSONSerialization.jsonObject(with: data),
       let record = object as? [String: Any]
    {
      return try decodeConfigRecord(record)
    }

    let defaults = UserDefaults(suiteName: SharedKeys.appGroupId)
    if let record = defaults?.dictionary(forKey: SharedKeys.leafConfigRecord) {
      return try decodeConfigRecord(record)
    }

    if let config = defaults?.string(forKey: SharedKeys.leafConfig), !config.isEmpty {
      return config
    }

    return defaultLeafConfig()
  }

  private func decodeConfigRecord(_ record: [String: Any]) throws -> String {
    guard let version = record["version"] as? Int else {
      throw PacketTunnelError.invalidConfig("config record missing version")
    }
    guard version == PacketTunnelConstants.configVersion else {
      throw PacketTunnelError.invalidConfig("unsupported config record version: \(version)")
    }
    guard let config = record["config"] as? String, !config.isEmpty else {
      throw PacketTunnelError.invalidConfig("config record missing config")
    }
    guard let checksum = record["checksum"] as? String, !checksum.isEmpty else {
      throw PacketTunnelError.invalidConfig("config record missing checksum")
    }

    guard let data = config.data(using: .utf8) else {
      throw PacketTunnelError.invalidConfig("config record content is not UTF-8")
    }
    let currentChecksum = data.sha256Hex
    guard currentChecksum == checksum else {
      throw PacketTunnelError.invalidConfig("config checksum mismatch")
    }

    return config
  }

  private func sharedConfigRecordURL() -> URL? {
    guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedKeys.appGroupId) else {
      return nil
    }
    return groupURL.appendingPathComponent(SharedKeys.leafConfigFile)
  }

  private func defaultLeafConfig() -> String {
    """
    {
      "log": { "level": "warn" },
      "inbounds": [
        { "tag": "mixed_in", "address": "127.0.0.1", "port": 7890, "protocol": "mixed" }
      ],
      "outbounds": [
        { "tag": "direct", "protocol": "direct" }
      ],
      "router": {
        "rules": [{ "target": "direct", "type": "FINAL" }],
        "domainResolve": true
      },
      "dns": {
        "servers": ["1.1.1.1", "8.8.8.8"]
      }
    }
    """
  }

  private func parseConfig(_ configJson: String) throws -> [String: Any] {
    guard let data = configJson.data(using: .utf8) else {
      throw PacketTunnelError.invalidConfig("base config is not UTF-8")
    }

    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw PacketTunnelError.invalidConfig("base config root is not a JSON object")
    }

    return root
  }

  private func validateLeafConfig(_ config: [String: Any]) throws {
    guard let inbounds = config["inbounds"] as? [[String: Any]] else {
      throw PacketTunnelError.invalidConfig("missing or invalid 'inbounds' field")
    }

    guard let outbounds = config["outbounds"] as? [[String: Any]], !outbounds.isEmpty else {
      throw PacketTunnelError.invalidConfig("missing or empty 'outbounds' field")
    }

    let hasValidOutbound = outbounds.contains { outbound in
      guard let `protocol` = outbound["protocol"] as? String else {
        return false
      }
      return !`protocol`.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    guard hasValidOutbound else {
      throw PacketTunnelError.invalidConfig("no valid outbound found")
    }

    if inbounds.isEmpty {
      log("base config inbounds is empty, runtime tun inbound will be injected", level: .warn)
    }
  }

  private func extractDNSServers(from config: [String: Any]) -> [String] {
    if let dns = config["dns"] as? [String: Any],
       let servers = dns["servers"] as? [String]
    {
      let sanitized = servers
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
      if !sanitized.isEmpty {
        return sanitized
      }
    }
    return PacketTunnelConstants.defaultDNSServers
  }

  private func extractMTU(from config: [String: Any]) -> Int {
    if let inbounds = config["inbounds"] as? [[String: Any]],
       let tunInbound = inbounds.first(where: { ($0["protocol"] as? String) == "tun" }),
       let settings = tunInbound["settings"] as? [String: Any],
       let mtu = settings["mtu"] as? Int,
       mtu > 0
    {
      return mtu
    }
    return PacketTunnelConstants.defaultMTU
  }

  private func buildNetworkSettings(dnsServers: [String], mtu: Int) -> NEPacketTunnelNetworkSettings {
    let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "198.18.0.1")

    let ipv4 = NEIPv4Settings(addresses: ["198.18.0.2"], subnetMasks: ["255.255.255.0"])
    ipv4.includedRoutes = [NEIPv4Route.default()]
    settings.ipv4Settings = ipv4

    let dns = NEDNSSettings(servers: dnsServers)
    dns.matchDomains = [""]
    settings.dnsSettings = dns
    settings.mtu = NSNumber(value: mtu)

    return settings
  }

  private func buildRuntimeConfig(_ baseConfig: [String: Any], tunFd: Int32, mtu: Int) throws -> String {
    var root = baseConfig

    var inbounds = (root["inbounds"] as? [[String: Any]]) ?? []
    inbounds.removeAll { ($0["protocol"] as? String) == "tun" }
    inbounds.append([
      "tag": "tun_in",
      "protocol": "tun",
      "settings": [
        "fd": Int(tunFd),
        "mtu": mtu,
      ],
    ])
    root["inbounds"] = inbounds

    let runtimeData = try JSONSerialization.data(withJSONObject: root)
    guard let runtimeJson = String(data: runtimeData, encoding: .utf8) else {
      throw PacketTunnelError.invalidConfig("runtime config encode failed")
    }
    return runtimeJson
  }

  private func appendSharedLog(_ entry: String) {
    guard let defaults = UserDefaults(suiteName: SharedKeys.appGroupId) else {
      return
    }

    let current = defaults.string(forKey: SharedKeys.recentLogs) ?? ""
    var lines = current
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map(String.init)
    lines.append(entry)

    if lines.count > PacketTunnelConstants.maxSharedLogLines {
      lines = Array(lines.suffix(PacketTunnelConstants.maxSharedLogLines))
    }

    defaults.set(lines.joined(separator: "\n"), forKey: SharedKeys.recentLogs)
  }

  private func startHeartbeat() {
    heartbeatQueue.async { [weak self] in
      guard let self else { return }
      self.stopHeartbeatLocked(clearStoredValue: false)

      let timer = DispatchSource.makeTimerSource(queue: self.heartbeatQueue)
      timer.schedule(deadline: .now(), repeating: .seconds(PacketTunnelConstants.heartbeatIntervalSeconds))
      timer.setEventHandler { [weak self] in
        self?.persistHeartbeat()
      }
      self.heartbeatTimer = timer
      timer.resume()
    }
  }

  private func stopHeartbeat() {
    heartbeatQueue.async { [weak self] in
      self?.stopHeartbeatLocked(clearStoredValue: true)
    }
  }

  private func stopHeartbeatLocked(clearStoredValue: Bool) {
    heartbeatTimer?.setEventHandler {}
    heartbeatTimer?.cancel()
    heartbeatTimer = nil

    guard clearStoredValue else { return }
    UserDefaults(suiteName: SharedKeys.appGroupId)?.removeObject(forKey: SharedKeys.lastHeartbeat)
  }

  private func persistHeartbeat() {
    UserDefaults(suiteName: SharedKeys.appGroupId)?.set(Date().timeIntervalSince1970, forKey: SharedKeys.lastHeartbeat)
  }

  private func applySavedSelection() {
    let defaults = UserDefaults(suiteName: SharedKeys.appGroupId)
    guard let selected = defaults?.string(forKey: SharedKeys.leafSelectedTag), !selected.isEmpty else {
      return
    }
    _ = LeafRuntime.shared.selectNode(selected)
  }
}
