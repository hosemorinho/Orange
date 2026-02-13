import Foundation
import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
  private let logger = Logger(subsystem: "com.follow.clash", category: "PacketTunnel")

  override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "198.18.0.1")

    let ipv4 = NEIPv4Settings(addresses: ["198.18.0.2"], subnetMasks: ["255.255.255.0"])
    ipv4.includedRoutes = [NEIPv4Route.default()]
    settings.ipv4Settings = ipv4

    let dns = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
    dns.matchDomains = [""]
    settings.dnsSettings = dns

    setTunnelNetworkSettings(settings) { error in
      if let error {
        self.logger.error("Failed to apply tunnel settings: \(error.localizedDescription, privacy: .public)")
        completionHandler(error)
        return
      }
      self.logger.info("Packet tunnel started")
      completionHandler(nil)
    }
  }

  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    logger.info("Packet tunnel stopped, reason=\(reason.rawValue)")
    completionHandler()
  }

  override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
    completionHandler?(messageData)
  }

  override func sleep(completionHandler: @escaping () -> Void) {
    completionHandler()
  }

  override func wake() {}
}
