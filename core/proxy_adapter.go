package main

import (
	"strings"
	"time"

	"github.com/sagernet/sing-box/adapter"
	C "github.com/sagernet/sing-box/constant"
)

// BuildProxiesData reads all outbounds from the box and converts them into the
// Clash-compatible ProxiesData format that the Dart side expects.
func BuildProxiesData(outboundManager adapter.OutboundManager, clashServer adapter.ClashServer) ProxiesData {
	outbounds := outboundManager.Outbounds()
	proxies := make(map[string]*ProxyInfo, len(outbounds))
	var groupNames []string

	for _, ob := range outbounds {
		tag := ob.Tag()
		typeName := ob.Type()
		udp := false
		for _, n := range ob.Network() {
			if n == "udp" {
				udp = true
				break
			}
		}

		info := &ProxyInfo{
			Name:    tag,
			Type:    mapOutboundType(typeName),
			UDP:     udp,
			History: buildHistory(tag, clashServer),
		}

		// Check if it's a group
		if group, isGroup := ob.(adapter.OutboundGroup); isGroup {
			now := group.Now()
			info.Now = &now
			info.All = group.All()
			groupNames = append(groupNames, tag)
		}

		proxies[tag] = info
	}

	// Return only groups that actually exist in the Box outbounds.
	// If the subscription JSON defines a GLOBAL selector, it appears naturally.
	return ProxiesData{
		Proxies: proxies,
		All:     groupNames,
	}
}

// mapOutboundType maps sing-box outbound type constants to Clash-style type names.
func mapOutboundType(sbType string) string {
	switch sbType {
	case C.TypeDirect:
		return "Direct"
	case C.TypeBlock:
		return "Reject"
	case C.TypeShadowsocks:
		return "Shadowsocks"
	case C.TypeVMess:
		return "Vmess"
	case C.TypeVLESS:
		return "Vless"
	case C.TypeTrojan:
		return "Trojan"
	case C.TypeHysteria:
		return "Hysteria"
	case C.TypeHysteria2:
		return "Hysteria2"
	case C.TypeWireGuard:
		return "WireGuard"
	case C.TypeTUIC:
		return "Tuic"
	case C.TypeSelector:
		return "Selector"
	case C.TypeURLTest:
		return "URLTest"
	case C.TypeSSH:
		return "SSH"
	default:
		if len(sbType) == 0 {
			return "Unknown"
		}
		return strings.ToUpper(sbType[:1]) + sbType[1:]
	}
}

// buildHistory retrieves URLTest history for an outbound from the clash server.
func buildHistory(tag string, clashServer adapter.ClashServer) []DelayHist {
	if clashServer == nil {
		return []DelayHist{}
	}
	storage := clashServer.HistoryStorage()
	if storage == nil {
		return []DelayHist{}
	}
	hist := storage.LoadURLTestHistory(tag)
	if hist == nil {
		return []DelayHist{}
	}
	return []DelayHist{
		{
			Time:  hist.Time.Format(time.RFC3339),
			Delay: hist.Delay,
		},
	}
}
