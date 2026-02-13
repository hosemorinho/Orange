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

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.follow.clash/service", binaryMessenger: registrar.messenger())
    let instance = ServicePlugin()
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
        tunnelManager.reloadConfigIfConnected(config)
      }
      result("")
    case "selectNode":
      if let nodeTag = call.arguments as? String, !nodeTag.isEmpty {
        tunnelManager.storeSelectedNode(nodeTag)
        tunnelManager.selectNodeIfConnected(nodeTag)
        result(true)
      } else {
        result(false)
      }
    case "start":
      tunnelManager.start { success in
        result(success)
      }
    case "stop":
      tunnelManager.stop()
      result(true)
    case "getRunTime":
      result(tunnelManager.startTimestampMs())
    case "getTunFd":
      result(nil)
    case "enableSocketProtection", "disableSocketProtection":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

final class TunnelManager {
  static let shared = TunnelManager()

  private var manager: NETunnelProviderManager?
  private var startDate: Date?

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

  func startTimestampMs() -> Int64? {
    guard let startDate else { return nil }
    return Int64(startDate.timeIntervalSince1970 * 1000)
  }

  func stop() {
    manager?.connection.stopVPNTunnel()
    startDate = nil
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
      do {
        try manager?.connection.startVPNTunnel()
        self.startDate = Date()
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  func reloadConfigIfConnected(_ config: String) {
    _ = sendProviderCommand(
      type: "reload_config",
      payload: ["config": config]
    )
  }

  func selectNodeIfConnected(_ nodeTag: String) {
    _ = sendProviderCommand(
      type: "select_node",
      payload: ["tag": nodeTag]
    )
  }

  private func providerBundleIdentifier() -> String? {
    guard let appBundleId = Bundle.main.bundleIdentifier else { return nil }
    return "\(appBundleId).PacketTunnel"
  }

  private func sendProviderCommand(type: String, payload: [String: Any]) -> Bool {
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
      try session.sendProviderMessage(data) { _ in }
    } catch {
      return false
    }
    return true
  }

  private func loadOrCreateManager(completion: @escaping (NETunnelProviderManager?, Error?) -> Void) {
    NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
      if let error {
        completion(nil, error)
        return
      }

      let manager = managers?.first ?? NETunnelProviderManager()
      self?.configure(manager)

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
    let proto = NETunnelProviderProtocol()
    proto.providerBundleIdentifier = providerBundleIdentifier()
    proto.serverAddress = "Orange"
    proto.disconnectOnSleep = false

    manager.protocolConfiguration = proto
    manager.localizedDescription = "Orange VPN"
    manager.isEnabled = true
  }
}
