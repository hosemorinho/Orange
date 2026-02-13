import Flutter
import Foundation
import NetworkExtension

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

  private let appGroupId = "group.com.follow.flClash"

  private init() {}

  func storeSharedState(_ state: String) {
    UserDefaults(suiteName: appGroupId)?.set(state, forKey: "shared_state")
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

  private func providerBundleIdentifier() -> String? {
    guard let appBundleId = Bundle.main.bundleIdentifier else { return nil }
    return "\(appBundleId).PacketTunnel"
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
