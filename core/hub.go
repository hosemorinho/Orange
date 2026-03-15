package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/netip"
	"os"
	"runtime"
	"runtime/debug"
	"strconv"
	"sync"
	"time"

	box "github.com/sagernet/sing-box"
	"github.com/sagernet/sing-box/adapter"
	"github.com/sagernet/sing-box/common/urltest"
	"github.com/sagernet/sing-box/experimental/clashapi/trafficontrol"
	"github.com/sagernet/sing-box/include"
	sbLog "github.com/sagernet/sing-box/log"
	"github.com/sagernet/sing-box/option"
	"github.com/sagernet/sing/common"
	"github.com/sagernet/sing/common/json/badoption"
	"github.com/sagernet/sing/common/observable"
	"github.com/sagernet/sing/service"
)

var (
	logSubscription       observable.Subscription[sbLog.Entry]
	logDone               <-chan struct{}
	logLock               sync.Mutex // protects logSubscription, logDone
	logStreamingRequested bool

	// Traffic rate tracking — protected by trafficLock
	trafficLock      sync.Mutex
	prevUp, prevDown int64
	prevTime         time.Time
)

func handleInitClash(paramsString string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	var params = InitParams{}
	err := json.Unmarshal([]byte(paramsString), &params)
	if err != nil {
		return false
	}
	version = params.Version
	homeDir = params.HomeDir
	if params.AppName != "" {
		appName = params.AppName
	}

	// Set working directory to homeDir so sing-box resolves relative paths
	if homeDir != "" {
		_ = os.MkdirAll(homeDir, 0o755)
		_ = os.Chdir(homeDir)
	}

	isInit = true
	return isInit
}

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	if currentBox != nil {
		return true
	}
	if currentOpts == nil || shouldDelayBoxStart(currentOpts) {
		return true
	}
	if err := startBoxFromOpts(currentOpts); err != nil {
		isRunning = false
		return false
	}
	patchSelectGroup(selectedMapSnapshot)
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	shutdownBox()
	return true
}

func handleGetIsInit() bool {
	return isInit
}

func handleForceGC() {
	runtime.GC()
	debug.FreeOSMemory()
}

func handleShutdown() bool {
	runLock.Lock()
	shutdownBox()
	currentOpts = nil
	selectedMapSnapshot = map[string]string{}
	isInit = false
	isRunning = false
	runLock.Unlock()
	handleForceGC()
	return true
}

func handleValidateConfig(path string) string {
	buf, err := readConfigBytes(path)
	if err != nil {
		return err.Error()
	}
	opts, err := ParseSingboxConfig(buf)
	if err != nil {
		return err.Error()
	}
	// Semantic validation: create a temporary Box to catch bad outbound refs, etc.
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	ctx = include.Context(ctx)
	ctx = service.ContextWithDefaultRegistry(ctx)
	// Register a stub PlatformInterface to avoid nil panics during validation.
	if platformInterfaceProvider != nil {
		service.MustRegister[adapter.PlatformInterface](ctx, platformInterfaceProvider)
	}
	tmpBox, err := box.New(box.Options{Context: ctx, Options: *opts})
	if err != nil {
		return err.Error()
	}
	_ = tmpBox.Close()
	return ""
}

func handleGetProxies() ProxiesData {
	runLock.Lock()
	defer runLock.Unlock()

	outboundMgr := getOutboundManager()
	if outboundMgr == nil {
		return ProxiesData{
			Proxies: map[string]*ProxyInfo{},
			All:     []string{},
		}
	}
	clashSrv := getClashServer()
	return BuildProxiesData(outboundMgr, clashSrv)
}

func handleChangeProxy(data string, fn func(string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()

		var params = &ChangeProxyParams{}
		err := json.Unmarshal([]byte(data), params)
		if err != nil {
			fn(err.Error())
			return
		}
		groupName := *params.GroupName
		proxyName := *params.ProxyName

		outboundMgr := getOutboundManager()
		if outboundMgr == nil {
			fn("not initialized")
			return
		}

		ob, exists := outboundMgr.Outbound(groupName)
		if !exists {
			fn("Not found group")
			return
		}

		group, isGroup := ob.(adapter.OutboundGroup)
		if !isGroup {
			fn("Group is not selectable")
			return
		}

		if !selectOutbound(group, proxyName) {
			fn("Failed to select outbound")
			return
		}
		selectedMapSnapshot[groupName] = proxyName

		fn("")
	}()
}

func handleGetTraffic(onlyStatisticsProxy bool) string {
	tm := getTrafficManager()
	if tm == nil {
		return `{"up":0,"down":0}`
	}
	up, down := tm.Total()
	now := time.Now()

	trafficLock.Lock()
	var rateUp, rateDown int64
	if !prevTime.IsZero() {
		elapsed := now.Sub(prevTime).Seconds()
		if elapsed > 0 {
			rateUp = int64(float64(up-prevUp) / elapsed)
			rateDown = int64(float64(down-prevDown) / elapsed)
		}
	}
	if rateUp < 0 {
		rateUp = 0
	}
	if rateDown < 0 {
		rateDown = 0
	}
	prevUp = up
	prevDown = down
	prevTime = now
	trafficLock.Unlock()

	traffic := map[string]int64{
		"up":   rateUp,
		"down": rateDown,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleGetTotalTraffic(onlyStatisticsProxy bool) string {
	tm := getTrafficManager()
	if tm == nil {
		return `{"up":0,"down":0}`
	}
	up, down := tm.Total()
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleResetTraffic() {
	tm := getTrafficManager()
	if tm != nil {
		tm.ResetStatistic()
	}
}

func handleAsyncTestDelay(paramsString string, fn func(string)) {
	go func() {
		var params = &TestDelayParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			fn("")
			return
		}

		delayData := &Delay{
			Name: params.ProxyName,
		}

		outboundMgr := getOutboundManager()
		if outboundMgr == nil {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return
		}

		ob, exists := outboundMgr.Outbound(params.ProxyName)
		if !exists {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return
		}

		testUrl := "https://www.gstatic.com/generate_204"
		if params.TestUrl != "" {
			testUrl = params.TestUrl
		}
		delayData.Url = testUrl

		timeout := time.Duration(params.Timeout) * time.Millisecond
		if timeout <= 0 {
			timeout = 5 * time.Second
		}
		ctx, cancel := context.WithTimeout(context.Background(), timeout)
		defer cancel()

		delay, err := urltest.URLTest(ctx, testUrl, ob)
		if err != nil || delay == 0 {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))

			// Also send delay message
			sendMessage(Message{
				Type: DelayMessage,
				Data: delayData,
			})
			return
		}

		delayData.Value = int32(delay)
		data, _ := json.Marshal(delayData)
		fn(string(data))

		// Send delay message for live updates
		sendMessage(Message{
			Type: DelayMessage,
			Data: delayData,
		})
	}()
}

func handleGetConnections() string {
	runLock.Lock()
	defer runLock.Unlock()

	tm := getTrafficManager()
	if tm == nil {
		return "[]"
	}

	snapshot := tm.Snapshot()
	data, err := json.Marshal(snapshot)
	if err != nil {
		return "[]"
	}
	return string(data)
}

func handleCloseConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()

	tm := getTrafficManager()
	if tm == nil {
		return true
	}

	conns := tm.Connections()
	for _, c := range conns {
		tracker := tm.Connection(c.ID)
		if tracker != nil {
			_ = tracker.Close()
		}
	}
	return true
}

func handleResetConnections() bool {
	return true
}

func handleCloseConnection(connectionId string) bool {
	runLock.Lock()
	defer runLock.Unlock()

	// The Dart side sends connection ID as string; we parse to find it
	// sing-box uses uuid.UUID, but we search by string match
	tm := getTrafficManager()
	if tm == nil {
		return false
	}

	conns := tm.Connections()
	for _, c := range conns {
		if c.ID.String() == connectionId {
			tracker := tm.Connection(c.ID)
			if tracker != nil {
				_ = tracker.Close()
				return true
			}
		}
	}
	return false
}

func handleGetExternalProviders() string {
	// sing-box doesn't have external providers in the same way as Clash.
	// Return empty array; UI will naturally hide the providers section.
	return "[]"
}

func handleGetExternalProvider(externalProviderName string) string {
	return ""
}

func handleUpdateGeoData(geoType string, geoName string, fn func(value string)) {
	go func() {
		// TODO: implement geo data download for sing-box format
		// For now, return success as sing-box handles geo data differently
		fn("")
	}()
}

func handleUpdateExternalProvider(providerName string, fn func(value string)) {
	go func() {
		fn("external providers not supported")
	}()
}

func handleSideLoadExternalProvider(providerName string, data []byte, fn func(value string)) {
	go func() {
		fn("external providers not supported")
	}()
}

func handleSuspend(suspended bool) bool {
	// sing-box doesn't have a direct suspend/resume API.
	// On Android, the system handles this via VPN lifecycle.
	return true
}

func handleStartLog() {
	logStreamingRequested = true
	if logFactory == nil {
		return
	}

	// Stop existing subscription
	stopLogSubscription(false)

	logLock.Lock()
	var err error
	logSubscription, logDone, err = logFactory.Subscribe()
	if err != nil {
		logLock.Unlock()
		return
	}
	sub := logSubscription
	done := logDone
	logLock.Unlock()

	go func() {
		for {
			select {
			case entry, ok := <-sub:
				if !ok {
					return
				}
				message := &Message{
					Type: LogMessage,
					Data: map[string]interface{}{
						"LogLevel": formatAppLogLevel(entry.Level),
						"Payload":  entry.Message,
					},
				}
				sendMessage(*message)
			case <-done:
				return
			}
		}
	}()
}

func handleStopLog() {
	stopLogSubscription(true)
}

func stopLogSubscription(clearRequest bool) {
	logLock.Lock()
	defer logLock.Unlock()
	if clearRequest {
		logStreamingRequested = false
	}
	if logSubscription != nil && logFactory != nil {
		logFactory.UnSubscribe(logSubscription)
	}
	logSubscription = nil
	logDone = nil
}

func handleGetCountryCode(ip string, fn func(value string)) {
	go func() {
		// sing-box geo lookup is different; for now return empty
		fn("")
	}()
}

func handleGetMemory(fn func(value string)) {
	go func() {
		var m runtime.MemStats
		runtime.ReadMemStats(&m)
		fn(strconv.FormatUint(m.Alloc, 10))
	}()
}

func handleGetConfig(path string) (map[string]interface{}, error) {
	bytes, err := readConfigBytes(path)
	if err != nil {
		return nil, err
	}
	var result map[string]interface{}
	if err := json.Unmarshal(bytes, &result); err != nil {
		return nil, fmt.Errorf("parse config JSON: %w", err)
	}
	return result, nil
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleUpdateConfig(bytes []byte) string {
	var params = &UpdateParams{}
	err := json.Unmarshal(bytes, params)
	if err != nil {
		return err.Error()
	}

	runLock.Lock()
	defer runLock.Unlock()
	if currentOpts == nil {
		return "not initialized"
	}

	// Mode change: lightweight, no restart needed
	if params.Mode != nil {
		ensureClashAPIOptions(currentOpts)
		currentOpts.Experimental.ClashAPI.DefaultMode = *params.Mode
		type modeSettable interface {
			SetMode(mode string)
		}
		if clashServer := getClashServer(); clashServer != nil {
			if ms, ok := clashServer.(modeSettable); ok {
				ms.SetMode(*params.Mode)
			}
		}
	}

	// Log level change: lightweight, no restart needed
	if params.LogLevel != nil {
		ensureLogOptions(currentOpts)
		currentOpts.Log.Level = normalizeCoreLogLevel(*params.LogLevel)
		if logFactory != nil {
			level, parseErr := sbLog.ParseLevel(currentOpts.Log.Level)
			if parseErr == nil {
				logFactory.SetLevel(level)
			}
		}
	}

	if params.ExternalController != nil {
		ensureClashAPIOptions(currentOpts)
		currentOpts.Experimental.ClashAPI.ExternalController = *params.ExternalController
	}

	if params.FindProcessMode != nil {
		ensureRouteOptions(currentOpts)
		currentOpts.Route.FindProcess = *params.FindProcessMode == "always"
	}

	structuralReload := false
	if params.AllowLan != nil {
		patchInboundListenAddress(currentOpts, *params.AllowLan)
		structuralReload = true
	}
	if params.MixedPort != nil {
		patchMixedInboundPort(currentOpts, uint16(*params.MixedPort))
		structuralReload = true
	}
	if params.Tun != nil {
		patchTunInbound(currentOpts, params.Tun)
		structuralReload = true
	}

	if !structuralReload || !isRunning {
		return ""
	}

	shutdownBox()
	if shouldDelayBoxStart(currentOpts) {
		return ""
	}
	if err := startBoxFromOpts(currentOpts); err != nil {
		return err.Error()
	}
	patchSelectGroup(selectedMapSnapshot)
	return ""
}

func formatAppLogLevel(level sbLog.Level) string {
	logLevel := sbLog.FormatLevel(level)
	if logLevel == "warn" {
		return "warning"
	}
	if logLevel == "fatal" || logLevel == "panic" {
		return "error"
	}
	return logLevel
}

func normalizeCoreLogLevel(level string) string {
	if level == "warning" {
		return "warn"
	}
	if level == "silent" {
		return "error"
	}
	return level
}

func ensureLogOptions(opts *option.Options) {
	if opts.Log == nil {
		opts.Log = &option.LogOptions{}
	}
}

func ensureRouteOptions(opts *option.Options) {
	if opts.Route == nil {
		opts.Route = &option.RouteOptions{}
	}
}

func ensureClashAPIOptions(opts *option.Options) {
	if opts.Experimental == nil {
		opts.Experimental = &option.ExperimentalOptions{}
	}
	if opts.Experimental.ClashAPI == nil {
		opts.Experimental.ClashAPI = &option.ClashAPIOptions{}
	}
}

func patchInboundListenAddress(opts *option.Options, allowLan bool) {
	listenAddr := "127.0.0.1"
	if allowLan {
		listenAddr = "0.0.0.0"
	}
	addr := parseListenAddr(listenAddr)
	for index := range opts.Inbounds {
		if wrapper, ok := opts.Inbounds[index].Options.(option.ListenOptionsWrapper); ok {
			listenOptions := wrapper.TakeListenOptions()
			listenOptions.Listen = addr
			wrapper.ReplaceListenOptions(listenOptions)
		}
	}
}

func patchMixedInboundPort(opts *option.Options, port uint16) {
	for index := range opts.Inbounds {
		if opts.Inbounds[index].Type != "mixed" {
			continue
		}
		if wrapper, ok := opts.Inbounds[index].Options.(option.ListenOptionsWrapper); ok {
			listenOptions := wrapper.TakeListenOptions()
			listenOptions.ListenPort = port
			wrapper.ReplaceListenOptions(listenOptions)
		}
	}
}

func patchTunInbound(opts *option.Options, tunConfig *tunSchema) {
	for index := range opts.Inbounds {
		if opts.Inbounds[index].Type != "tun" {
			continue
		}
		if !tunConfig.Enable {
			opts.Inbounds = append(opts.Inbounds[:index], opts.Inbounds[index+1:]...)
			return
		}
		tunOptions, ok := opts.Inbounds[index].Options.(*option.TunInboundOptions)
		if !ok {
			continue
		}
		if tunConfig.Device != nil {
			tunOptions.InterfaceName = *tunConfig.Device
		}
		if tunConfig.Stack != nil {
			tunOptions.Stack = *tunConfig.Stack
		}
		if tunConfig.AutoRoute != nil {
			tunOptions.AutoRoute = *tunConfig.AutoRoute
		}
		if tunConfig.RouteAddress != nil {
			tunOptions.Address = *tunConfig.RouteAddress
		}
		return
	}
	if !tunConfig.Enable {
		return
	}
	tunOptions := &option.TunInboundOptions{
		InboundOptions: option.InboundOptions{
			SniffEnabled:             true,
			SniffOverrideDestination: false,
		},
	}
	if tunConfig.Device != nil {
		tunOptions.InterfaceName = *tunConfig.Device
	}
	if tunConfig.Stack != nil {
		tunOptions.Stack = *tunConfig.Stack
	}
	if tunConfig.AutoRoute != nil {
		tunOptions.AutoRoute = *tunConfig.AutoRoute
	}
	if tunConfig.RouteAddress != nil {
		tunOptions.Address = *tunConfig.RouteAddress
	}
	opts.Inbounds = append(opts.Inbounds, option.Inbound{
		Type:    "tun",
		Tag:     "tun-in",
		Options: tunOptions,
	})
}

func parseListenAddr(value string) *badoption.Addr {
	addr, err := netip.ParseAddr(value)
	if err != nil {
		return nil
	}
	return common.Ptr(badoption.Addr(addr))
}

func handleDelFile(path string, result ActionResult) {
	go func() {
		fileInfo, err := os.Stat(path)
		if err != nil {
			if os.IsNotExist(err) {
				result.success("")
				return
			}
			result.error(err.Error())
			return
		}
		if fileInfo.IsDir() {
			err = os.RemoveAll(path)
			if err != nil {
				result.error(err.Error())
				return
			}
		} else {
			err = os.Remove(path)
			if err != nil {
				result.error(err.Error())
				return
			}
		}
		result.success("")
	}()
}

func handleSetupConfig(bytes []byte) string {
	if !isInit {
		return "not initialized"
	}
	var params = defaultSetupParams()
	err := UnmarshalJson(bytes, params)
	if err != nil {
		_ = applyConfig(defaultSetupParams())
		return err.Error()
	}
	err = applyConfig(params)
	if err != nil {
		return err.Error()
	}
	return ""
}

// getTrafficManager retrieves the trafficontrol.Manager from the clash server.
func getTrafficManager() *trafficontrol.Manager {
	clashSrv := getClashServer()
	if clashSrv == nil {
		return nil
	}
	// The clash server in sing-box exposes TrafficManager()
	type trafficManagerAccessor interface {
		TrafficManager() *trafficontrol.Manager
	}
	if accessor, ok := clashSrv.(trafficManagerAccessor); ok {
		return accessor.TrafficManager()
	}
	return nil
}
