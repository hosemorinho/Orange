import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testLeafConfigRecordRoundTrip() throws {
    let config = """
    {
      "inbounds": [],
      "outbounds": [{ "tag": "direct", "protocol": "direct" }]
    }
    """

    let record = try LeafConfigRecord.make(config: config)
    let decoded = try LeafConfigRecord.fromDictionary(record.toDictionary())

    XCTAssertEqual(decoded.version, 1)
    XCTAssertEqual(decoded.config, config)
    XCTAssertEqual(decoded.checksum, record.checksum)
  }

  func testLeafConfigRecordRejectsChecksumMismatch() throws {
    let config = """
    {
      "inbounds": [],
      "outbounds": [{ "tag": "direct", "protocol": "direct" }]
    }
    """

    let record = try LeafConfigRecord.make(config: config)
    var tampered = record.toDictionary()
    tampered["config"] = "{}"

    XCTAssertThrowsError(try LeafConfigRecord.fromDictionary(tampered))
  }

  func testLeafConfigValidatorRejectsInvalidJson() {
    XCTAssertThrowsError(try LeafConfigValidator.parseRoot("{invalid json"))
  }

  func testLeafConfigValidatorRejectsMissingOutbounds() {
    let invalid = """
    {
      "inbounds": []
    }
    """
    XCTAssertThrowsError(try LeafConfigValidator.parseRoot(invalid))
  }

  func testVpnErrorCodes() {
    XCTAssertEqual(VPNError.configurationInvalid("x").errorCode, "CONFIG_INVALID")
    XCTAssertEqual(VPNError.permissionDenied.errorCode, "PERMISSION_DENIED")
    XCTAssertEqual(VPNError.tunnelStartFailed("x").errorCode, "TUNNEL_START_FAILED")
    XCTAssertEqual(VPNError.providerNotReady("x").errorCode, "PROVIDER_NOT_READY")
    XCTAssertEqual(VPNError.networkExtensionUnavailable.errorCode, "NE_UNAVAILABLE")
    XCTAssertEqual(VPNError.autoRecoveryFailed("x").errorCode, "AUTO_RECOVERY_FAILED")
  }
}
