import Foundation
import NetworkExtension
#if canImport(leaf)
import leaf
#endif

private enum SharedKeys {
  static let appGroupId = "group.com.follow.flClash"
  static let leafConfig = "leaf_config_json"
  static let leafSelectedTag = "leaf_selected_tag"
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

      self.stateQueue.asyncAfter(deadline: .now() + .milliseconds(450)) {
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
}

class PacketTunnelProvider: NEPacketTunnelProvider {
  private var tunFd: Int32?

  private func log(_ message: String) {
    NSLog("[PacketTunnel] %@", message)
  }

  override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "198.18.0.1")

    let ipv4 = NEIPv4Settings(addresses: ["198.18.0.2"], subnetMasks: ["255.255.255.0"])
    ipv4.includedRoutes = [NEIPv4Route.default()]
    settings.ipv4Settings = ipv4

    let dns = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
    dns.matchDomains = [""]
    settings.dnsSettings = dns

    settings.mtu = 1500

    setTunnelNetworkSettings(settings) { [weak self] error in
      guard let self else {
        completionHandler(PacketTunnelError.invalidConfig("provider deallocated"))
        return
      }
      if let error {
        self.log("Failed to apply tunnel settings: \(error.localizedDescription)")
        completionHandler(error)
        return
      }

      do {
        let fd = try self.readTunFileDescriptor()
        self.tunFd = fd

        let baseConfig = self.loadLeafConfigFromSharedStore()
        let runtimeConfig = try self.buildRuntimeConfig(baseConfig, tunFd: fd)

        LeafRuntime.shared.start(configJson: runtimeConfig) { startError in
          if let startError {
            self.log("Leaf runtime start failed: \(startError.localizedDescription)")
            completionHandler(startError)
            return
          }

          self.applySavedSelection()
          self.log("Packet tunnel started with leaf runtime")
          completionHandler(nil)
        }
      } catch {
        self.log("Packet tunnel startup failed: \(error.localizedDescription)")
        completionHandler(error)
      }
    }
  }

  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    LeafRuntime.shared.stop()
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
    case "reload_config":
      guard let tunFd else {
        completionHandler?("tun_not_ready".data(using: .utf8))
        return
      }

      let baseConfig = payload["config"] as? String ?? loadLeafConfigFromSharedStore()
      do {
        let runtimeConfig = try buildRuntimeConfig(baseConfig, tunFd: tunFd)
        let ok = LeafRuntime.shared.reload(configJson: runtimeConfig)
        if ok {
          applySavedSelection()
          completionHandler?("ok".data(using: .utf8))
        } else {
          completionHandler?("reload_failed".data(using: .utf8))
        }
      } catch {
        completionHandler?("invalid_config".data(using: .utf8))
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

  private func readTunFileDescriptor() throws -> Int32 {
    let flowObject = packetFlow as NSObject
    guard let number = flowObject.value(forKeyPath: "socket.fileDescriptor") as? NSNumber else {
      throw PacketTunnelError.missingTunFd
    }
    return number.int32Value
  }

  private func loadLeafConfigFromSharedStore() -> String {
    let defaults = UserDefaults(suiteName: SharedKeys.appGroupId)
    if let config = defaults?.string(forKey: SharedKeys.leafConfig), !config.isEmpty {
      return config
    }
    return """
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

  private func buildRuntimeConfig(_ baseConfigJson: String, tunFd: Int32) throws -> String {
    guard let data = baseConfigJson.data(using: .utf8) else {
      throw PacketTunnelError.invalidConfig("base config is not UTF-8")
    }
    guard var root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw PacketTunnelError.invalidConfig("base config root is not a JSON object")
    }

    var inbounds = (root["inbounds"] as? [[String: Any]]) ?? []
    inbounds.removeAll { ($0["protocol"] as? String) == "tun" }
    inbounds.append([
      "tag": "tun_in",
      "protocol": "tun",
      "settings": [
        "fd": Int(tunFd),
        "mtu": 1500,
      ],
    ])
    root["inbounds"] = inbounds

    let runtimeData = try JSONSerialization.data(withJSONObject: root)
    guard let runtimeJson = String(data: runtimeData, encoding: .utf8) else {
      throw PacketTunnelError.invalidConfig("runtime config encode failed")
    }
    return runtimeJson
  }

  private func applySavedSelection() {
    let defaults = UserDefaults(suiteName: SharedKeys.appGroupId)
    guard let selected = defaults?.string(forKey: SharedKeys.leafSelectedTag), !selected.isEmpty else {
      return
    }
    _ = LeafRuntime.shared.selectNode(selected)
  }
}
