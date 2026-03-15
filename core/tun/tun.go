//go:build android && cgo

package tun

// The TUN interface is now managed by sing-box through the platformBridge.
// On Android, the Java VPN service provides the TUN fd, which is passed to
// platformBridge.OpenInterface() when sing-box starts its TUN inbound.
//
// This package is kept for backward compatibility with the import in lib.go,
// but the actual TUN management is done by sing-box's inbound system.
