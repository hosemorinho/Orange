//go:build android && cgo

package main

import (
	"fmt"
	"os"
	"sync"
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
	mu          sync.RWMutex
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
	p.mu.RLock()
	cb := p.tunCallback
	p.mu.RUnlock()
	if cb != nil {
		protect(cb, fd)
	}
	return nil
}

func (p *platformBridge) UsePlatformInterface() bool {
	return true
}

func (p *platformBridge) OpenInterface(options *tun.Options, platformOptions option.TunPlatformOptions) (tun.Tun, error) {
	p.mu.RLock()
	fd := p.tunFd
	p.mu.RUnlock()
	if fd == 0 {
		return nil, fmt.Errorf("TUN fd not set")
	}
	options.FileDescriptor = fd
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
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.tunCallback != nil
}

func (p *platformBridge) FindConnectionOwner(request *adapter.FindConnectionOwnerRequest) (*adapter.ConnectionOwner, error) {
	p.mu.RLock()
	cb := p.tunCallback
	p.mu.RUnlock()
	if cb == nil {
		return nil, os.ErrNotExist
	}
	protocol := int(request.IpProtocol)
	srcStr := fmt.Sprintf("%s:%d", request.SourceAddress, request.SourcePort)
	dstStr := fmt.Sprintf("%s:%d", request.DestinationAddress, request.DestinationPort)

	uid := -1
	packageName := resolveProcess(cb, protocol, srcStr, dstStr, uid)
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
