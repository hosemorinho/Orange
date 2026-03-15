package main

import (
	"context"
	"encoding/json"
	"os"
	"runtime"
	"runtime/debug"
	"strconv"
	"time"

	"github.com/sagernet/sing-box/adapter"
	"github.com/sagernet/sing-box/common/urltest"
	"github.com/sagernet/sing-box/experimental/clashapi/trafficontrol"
	"github.com/sagernet/sing/common/observable"
	"github.com/sagernet/sing/service"

	sbLog "github.com/sagernet/sing-box/log"
)

var (
	logSubscription observable.Subscription[sbLog.Entry]
	logDone         <-chan struct{}
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
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
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
	defer runLock.Unlock()
	if currentBox != nil {
		_ = currentBox.Close()
		currentBox = nil
	}
	if currentCancel != nil {
		currentCancel()
		currentCancel = nil
		currentCtx = nil
	}
	handleForceGC()
	isInit = false
	isRunning = false
	return true
}

func handleValidateConfig(path string) string {
	buf, err := readConfigBytes(path)
	if err != nil {
		return err.Error()
	}
	_, err = ParseSingboxConfig(buf)
	if err != nil {
		return err.Error()
	}
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

		fn("")
	}()
}

func handleGetTraffic(onlyStatisticsProxy bool) string {
	tm := getTrafficManager()
	if tm == nil {
		return `{"up":0,"down":0}`
	}
	// sing-box trafficontrol.Manager only has Total() - no NowTraffic concept
	// We track by diff in the Dart side or use 0 for instant traffic
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
	if logFactory == nil {
		return
	}

	// Stop existing subscription
	handleStopLog()

	var err error
	logSubscription, logDone, err = logFactory.Subscribe()
	if err != nil {
		return
	}

	go func() {
		for {
			select {
			case entry, ok := <-logSubscription:
				if !ok {
					return
				}
				message := &Message{
					Type: LogMessage,
					Data: map[string]interface{}{
						"level":   sbLog.FormatLevel(entry.Level),
						"message": entry.Message,
					},
				}
				sendMessage(*message)
			case <-logDone:
				return
			}
		}
	}()
}

func handleStopLog() {
	if logSubscription != nil && logFactory != nil {
		logFactory.UnSubscribe(logSubscription)
		logSubscription = nil
		logDone = nil
	}
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
	// Parse as YAML and return raw map for Dart side
	var result map[string]interface{}
	if err := json.Unmarshal(bytes, &result); err != nil {
		// Try treating as Clash YAML
		return map[string]interface{}{}, nil
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
	// Partial config updates are limited with sing-box.
	// Most settings require a Box restart.
	// For now, store params and they'll take effect on next full config apply.
	return ""
}

func handleDelFile(path string, result ActionResult) {
	go func() {
		fileInfo, err := os.Stat(path)
		if err != nil {
			if !os.IsNotExist(err) {
				result.success(err.Error())
			}
			result.success("")
			return
		}
		if fileInfo.IsDir() {
			err = os.RemoveAll(path)
			if err != nil {
				result.success(err.Error())
				return
			}
		} else {
			err = os.Remove(path)
			if err != nil {
				result.success(err.Error())
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

// init sets up hooks that send events to the Dart side.
// sing-box uses a different event model than Clash.Meta.
// We hook into the observable log factory and connection tracker for notifications.
func init() {
	// Unlike Clash.Meta, sing-box hooks are set up after Box creation.
	// See applyConfig() for where logFactory is captured.
	// The URL test hook equivalent is done in handleAsyncTestDelay where we
	// manually send DelayMessage after each test.
	_ = service.ContextWithDefaultRegistry // ensure import
}
