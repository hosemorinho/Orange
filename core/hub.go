package main

import (
	"context"
	"encoding/json"
	"fmt"
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
	sbLog "github.com/sagernet/sing-box/log"
	"github.com/sagernet/sing/common/observable"
	"github.com/sagernet/sing/service"
)

var (
	logSubscription observable.Subscription[sbLog.Entry]
	logDone         <-chan struct{}
	logLock         sync.Mutex // protects logSubscription, logDone

	// Traffic rate tracking — protected by trafficLock
	trafficLock          sync.Mutex
	prevUp, prevDown     int64
	prevTime             time.Time
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
	if currentOpts == nil {
		return false
	}
	if currentBox != nil {
		// Already running
		isRunning = true
		return true
	}
	if err := startBoxFromOpts(currentOpts); err != nil {
		return false
	}
	isRunning = true
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
	if logFactory == nil {
		return
	}

	// Stop existing subscription
	handleStopLog()

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
						"LogLevel": sbLog.FormatLevel(entry.Level),
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
	logLock.Lock()
	defer logLock.Unlock()
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

	// Mode change: lightweight, no restart needed
	if params.Mode != nil {
		type modeSettable interface {
			SetMode(mode string)
		}
		if ms, ok := getClashServer().(modeSettable); ok {
			ms.SetMode(*params.Mode)
		}
	}

	// Log level change: lightweight, no restart needed
	if params.LogLevel != nil {
		if logFactory != nil {
			level, parseErr := sbLog.ParseLevel(*params.LogLevel)
			if parseErr == nil {
				logFactory.SetLevel(level)
			}
		}
	}

	// Other structural changes (mixed-port, allow-lan, TUN, etc.) require a
	// full config reload via setupConfig. They are not applied here because
	// sing-box inbound options are typed structs that can't be patched after
	// deserialization without re-parsing. The Dart side should trigger a full
	// config reload for these changes.

	return ""
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

