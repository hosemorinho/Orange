//go:build android && cgo

package main

import (
	"net/netip"
	"os"
	"unsafe"

	"github.com/sagernet/sing-box/adapter"
	"github.com/sagernet/sing-box/option"
	"github.com/sagernet/sing/common/logger"
	tun "github.com/sagernet/sing-tun"
)

// platformBridge implements adapter.PlatformInterface for Android.
// It bridges sing-box platform calls to the JNI callbacks via the existing
// bride.go protect/resolveProcess functions.
type platformBridge struct {
	tunCallback unsafe.Pointer
	tunFd       int
}

func newPlatformBridge() *platformBridge {
	return &platformBridge{}
}

func (p *platformBridge) Initialize(networkManager adapter.NetworkManager) error {
	return nil
}

func (p *platformBridge) UsePlatformAutoDetectInterfaceControl() bool {
	return true
}

func (p *platformBridge) AutoDetectInterfaceControl(fd int) error {
	if p.tunCallback != nil {
		protect(p.tunCallback, fd)
	}
	return nil
}

func (p *platformBridge) UsePlatformInterface() bool {
	return true
}

func (p *platformBridge) OpenInterface(options *tun.Options, platformOptions option.TunPlatformOptions) (tun.Tun, error) {
	// On Android, the TUN fd is provided by the Java VPN service.
	// We use the fd stored in platformBridge.
	options.FileDescriptor = p.tunFd
	options.Name = "Orange"
	return tun.Open(*options)
}

func (p *platformBridge) UsePlatformDefaultInterfaceMonitor() bool {
	return false
}

func (p *platformBridge) CreateDefaultInterfaceMonitor(log logger.Logger) tun.DefaultInterfaceMonitor {
	return nil
}

func (p *platformBridge) UsePlatformNetworkInterfaces() bool {
	return false
}

func (p *platformBridge) NetworkInterfaces() ([]adapter.NetworkInterface, error) {
	return nil, os.ErrNotExist
}

func (p *platformBridge) UnderNetworkExtension() bool {
	return false
}

func (p *platformBridge) NetworkExtensionIncludeAllNetworks() bool {
	return false
}

func (p *platformBridge) ClearDNSCache() {
}

func (p *platformBridge) RequestPermissionForWIFIState() error {
	return nil
}

func (p *platformBridge) ReadWIFIState() adapter.WIFIState {
	return adapter.WIFIState{}
}

func (p *platformBridge) SystemCertificates() []string {
	return nil
}

func (p *platformBridge) UsePlatformConnectionOwnerFinder() bool {
	return p.tunCallback != nil
}

func (p *platformBridge) FindConnectionOwner(request *adapter.FindConnectionOwnerRequest) (*adapter.ConnectionOwner, error) {
	if p.tunCallback == nil {
		return nil, os.ErrNotExist
	}
	var protocol int
	srcAddr := request.Source
	dstAddr := request.Destination
	switch request.Network {
	case "udp":
		protocol = 17 // IPPROTO_UDP
	default:
		protocol = 6 // IPPROTO_TCP
	}

	srcStr := formatAddrPort(srcAddr)
	dstStr := formatAddrPort(dstAddr)

	uid := -1
	// on older Android, query /proc/net for uid
	if version < 29 {
		// Use procfs if available
		uid = queryUIDFromProcFs(srcAddr)
	}

	packageName := resolveProcess(p.tunCallback, protocol, srcStr, dstStr, uid)
	return &adapter.ConnectionOwner{
		AndroidPackageName: packageName,
	}, nil
}

func (p *platformBridge) UsePlatformWIFIMonitor() bool {
	return false
}

func (p *platformBridge) UsePlatformNotification() bool {
	return false
}

func (p *platformBridge) SendNotification(notification *adapter.Notification) error {
	return nil
}

func (p *platformBridge) UsePlatformNeighborResolver() bool {
	return false
}

func (p *platformBridge) StartNeighborMonitor(listener adapter.NeighborUpdateListener) error {
	return nil
}

func (p *platformBridge) CloseNeighborMonitor(listener adapter.NeighborUpdateListener) error {
	return nil
}

func formatAddrPort(ap netip.AddrPort) string {
	return ap.String()
}

func queryUIDFromProcFs(srcAddr netip.AddrPort) int {
	// Simplified — on Android < 29 use /proc/net lookup.
	// This is a best-effort; returning -1 tells Java side to use its own lookup.
	return -1
}
