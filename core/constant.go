package main

import (
	"encoding/json"
	"net/netip"
	"time"
)

type InitParams struct {
	HomeDir string `json:"home-dir"`
	AppName string `json:"app-name"`
	Version int    `json:"version"`
}

type SetupParams struct {
	SelectedMap     map[string]string `json:"selected-map"`
	TestURL         string            `json:"test-url"`
	ConfigSessionId string            `json:"config-session-id,omitempty"`
}

type UpdateParams struct {
	Tun                *tunSchema `json:"tun"`
	AllowLan           *bool      `json:"allow-lan"`
	MixedPort          *int       `json:"mixed-port"`
	FindProcessMode    *string    `json:"find-process-mode"`
	Mode               *string    `json:"mode"`
	LogLevel           *string    `json:"log-level"`
	IPv6               *bool      `json:"ipv6"`
	Sniffing           *bool      `json:"sniffing"`
	TCPConcurrent      *bool      `json:"tcp-concurrent"`
	ExternalController *string    `json:"external-controller"`
	Interface          *string    `json:"interface-name"`
	UnifiedDelay       *bool      `json:"unified-delay"`
}

type tunSchema struct {
	Enable       bool            `json:"enable"`
	Device       *string         `json:"device"`
	Stack        *string         `json:"stack"`
	DNSHijack    *[]string       `json:"dns-hijack"`
	AutoRoute    *bool           `json:"auto-route"`
	RouteAddress *[]netip.Prefix `json:"route-address,omitempty"`
}

type ChangeProxyParams struct {
	GroupName *string `json:"group-name"`
	ProxyName *string `json:"proxy-name"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	TestUrl   string `json:"test-url"`
	Timeout   int64  `json:"timeout"`
}

// SubscriptionInfo mirrors the upstream provider subscription info for JSON compatibility.
type SubscriptionInfo struct {
	Upload   int64 `json:"Upload"`
	Download int64 `json:"Download"`
	Total    int64 `json:"Total"`
	Expire   int64 `json:"Expire"`
}

type ExternalProvider struct {
	Name             string            `json:"name"`
	Type             string            `json:"type"`
	VehicleType      string            `json:"vehicle-type"`
	Count            int               `json:"count"`
	Path             string            `json:"path"`
	UpdateAt         time.Time         `json:"update-at"`
	SubscriptionInfo *SubscriptionInfo `json:"subscription-info"`
}

// ProxyInfo represents a proxy's JSON-serializable data matching Clash API format.
type ProxyInfo struct {
	Name    string      `json:"name"`
	Type    string      `json:"type"`
	UDP     bool        `json:"udp"`
	History []DelayHist `json:"history"`
	// group-only fields
	Now *string  `json:"now,omitempty"`
	All []string `json:"all,omitempty"`
}

type DelayHist struct {
	Time  string `json:"time"`
	Delay uint16 `json:"delay"`
}

type ProxiesData struct {
	Proxies map[string]*ProxyInfo `json:"proxies"`
	All     []string              `json:"all"`
}

const (
	messageMethod                  Method = "message"
	initClashMethod                Method = "initClash"
	getIsInitMethod                Method = "getIsInit"
	forceGcMethod                  Method = "forceGc"
	shutdownMethod                 Method = "shutdown"
	validateConfigMethod           Method = "validateConfig"
	updateConfigMethod             Method = "updateConfig"
	getProxiesMethod               Method = "getProxies"
	changeProxyMethod              Method = "changeProxy"
	getTrafficMethod               Method = "getTraffic"
	getTotalTrafficMethod          Method = "getTotalTraffic"
	resetTrafficMethod             Method = "resetTraffic"
	asyncTestDelayMethod           Method = "asyncTestDelay"
	getConnectionsMethod           Method = "getConnections"
	closeConnectionsMethod         Method = "closeConnections"
	resetConnectionsMethod         Method = "resetConnectionsMethod"
	closeConnectionMethod          Method = "closeConnection"
	getExternalProvidersMethod     Method = "getExternalProviders"
	getExternalProviderMethod      Method = "getExternalProvider"
	getCountryCodeMethod           Method = "getCountryCode"
	getMemoryMethod                Method = "getMemory"
	updateGeoDataMethod            Method = "updateGeoData"
	updateExternalProviderMethod   Method = "updateExternalProvider"
	sideLoadExternalProviderMethod Method = "sideLoadExternalProvider"
	startLogMethod                 Method = "startLog"
	stopLogMethod                  Method = "stopLog"
	startListenerMethod            Method = "startListener"
	stopListenerMethod             Method = "stopListener"
	updateDnsMethod                Method = "updateDns"
	crashMethod                    Method = "crash"
	setupConfigMethod              Method = "setupConfig"
	getConfigMethod                Method = "getConfig"
	deleteFile                     Method = "deleteFile"
	beginConfigSessionMethod       Method = "beginConfigSession"
	appendConfigChunkMethod        Method = "appendConfigChunk"
	commitConfigSessionMethod      Method = "commitConfigSession"
)

type Method string

type MessageType string

type Delay struct {
	Url   string `json:"url"`
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

const (
	LogMessage     MessageType = "log"
	DelayMessage   MessageType = "delay"
	RequestMessage MessageType = "request"
	LoadedMessage  MessageType = "loaded"
)

func (message *Message) Json() (string, error) {
	data, err := json.Marshal(message)
	return string(data), err
}
