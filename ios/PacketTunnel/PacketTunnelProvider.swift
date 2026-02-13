import Foundation
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
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

    setTunnelNetworkSettings(settings) { error in
      if let error {
        self.log("Failed to apply tunnel settings: \(error.localizedDescription)")
        completionHandler(error)
        return
      }
      self.log("Packet tunnel started")
      completionHandler(nil)
    }
  }

  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    log("Packet tunnel stopped, reason=\(reason.rawValue)")
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
