//go:build cgo && !android

package main

import (
	"os"
	"sync"
	"unsafe"

	"github.com/sagernet/sing-box/adapter"
	"github.com/sagernet/sing-box/option"
	"github.com/sagernet/sing/common/logger"
	tun "github.com/sagernet/sing-tun"
)

// platformBridge stub for non-Android CGO builds.
// Desktop builds don't need TUN/VPN platform integration.
// Fields are kept for source compatibility with lib.go (cgo build tag).
type platformBridge struct {
	mu          sync.RWMutex
	tunCallback unsafe.Pointer
	tunFd       int
}

func newPlatformBridge() *platformBridge {
	return &platformBridge{}
}

func (p *platformBridge) Initialize(_ adapter.NetworkManager) error {
	return nil
}

func (p *platformBridge) UsePlatformAutoDetectInterfaceControl() bool {
	return false
}

func (p *platformBridge) AutoDetectInterfaceControl(_ int) error {
	return nil
}

func (p *platformBridge) UsePlatformInterface() bool {
	return false
}

func (p *platformBridge) OpenInterface(_ *tun.Options, _ option.TunPlatformOptions) (tun.Tun, error) {
	return nil, os.ErrNotExist
}

func (p *platformBridge) UsePlatformDefaultInterfaceMonitor() bool {
	return false
}

func (p *platformBridge) CreateDefaultInterfaceMonitor(_ logger.Logger) tun.DefaultInterfaceMonitor {
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

func (p *platformBridge) ClearDNSCache() {}

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
	return false
}

func (p *platformBridge) FindConnectionOwner(_ *adapter.FindConnectionOwnerRequest) (*adapter.ConnectionOwner, error) {
	return nil, os.ErrNotExist
}

func (p *platformBridge) UsePlatformWIFIMonitor() bool {
	return false
}

func (p *platformBridge) UsePlatformNotification() bool {
	return false
}

func (p *platformBridge) SendNotification(_ *adapter.Notification) error {
	return nil
}
