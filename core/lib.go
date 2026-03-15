//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"context"
	"encoding/json"
	"errors"
	"net/netip"
	"strings"
	"sync"
	"unsafe"

	"golang.org/x/sync/semaphore"

	"github.com/sagernet/sing-box/adapter"
	sbLog "github.com/sagernet/sing-box/log"
	"github.com/sagernet/sing/service"
)

var eventListener unsafe.Pointer

// TunHandler manages the Android TUN interface lifecycle.
type TunHandler struct {
	bridge   *platformBridge
	callback unsafe.Pointer
	limit    *semaphore.Weighted
}

func (th *TunHandler) start(fd int, stack, address, dns string) {
	runLock.Lock()
	defer runLock.Unlock()
	_ = th.limit.Acquire(context.TODO(), 4)
	defer th.limit.Release(4)

	// Store fd and callback in the platform bridge for sing-box to use
	th.bridge.tunFd = fd
	th.bridge.tunCallback = th.callback

	// Set up socket protection hook
	th.initHook()

	// If a box is running, it should already have a TUN inbound configured.
	// The platform bridge's OpenInterface will use the fd we stored.
	// For now, log the TUN setup.
	sbLog.Info("[TUN] started with fd=", fd, " stack=", stack, " address=", address)

	// Parse addresses for logging
	for _, a := range strings.Split(address, ",") {
		a = strings.TrimSpace(a)
		if len(a) == 0 {
			continue
		}
		prefix, err := netip.ParsePrefix(a)
		if err == nil {
			sbLog.Info("[TUN] address: ", prefix.String())
		}
	}
}

func (th *TunHandler) close() {
	_ = th.limit.Acquire(context.TODO(), 4)
	defer th.limit.Release(4)
	th.clear()
}

func (th *TunHandler) clear() {
	th.removeHook()
	if th.callback != nil {
		releaseObject(th.callback)
	}
	th.callback = nil
	if th.bridge != nil {
		th.bridge.tunCallback = nil
		th.bridge.tunFd = 0
	}
}

func (th *TunHandler) handleProtect(fd int) {
	_ = th.limit.Acquire(context.Background(), 1)
	defer th.limit.Release(1)

	if th.callback == nil {
		return
	}

	protect(th.callback, fd)
}

func (th *TunHandler) initHook() {
	// Register the platform bridge with the sing-box context if available.
	// The platform bridge handles socket protection via AutoDetectInterfaceControl.
	if currentCtx != nil && th.bridge != nil {
		service.MustRegister[adapter.PlatformInterface](currentCtx, th.bridge)
	}
}

func (th *TunHandler) removeHook() {
	// Platform bridge lifecycle is managed by the Box context
}

var (
	tunLock    sync.Mutex
	errBlocked = errors.New("blocked")
	tunHandler *TunHandler
	globalBridge *platformBridge
)

func init() {
	globalBridge = newPlatformBridge()
}

func handleStopTun() {
	tunLock.Lock()
	defer tunLock.Unlock()
	if tunHandler != nil {
		tunHandler.close()
	}
}

func handleStartTun(callback unsafe.Pointer, fd int, stack, address, dns string) {
	handleStopTun()
	tunLock.Lock()
	defer tunLock.Unlock()
	if fd != 0 {
		tunHandler = &TunHandler{
			bridge:   globalBridge,
			callback: callback,
			limit:    semaphore.NewWeighted(4),
		}
		tunHandler.start(fd, stack, address, dns)
	}
}

func handleUpdateDns(value string) {
	go func() {
		sbLog.Info("[DNS] updateDns ", value)
		// sing-box doesn't expose a direct DNS update API like Clash.
		// DNS configuration is part of the Box config.
		// For runtime DNS changes, we would need to reload the box.
		// This is a no-op for now — DNS is configured at box startup.
	}()
}

func (result ActionResult) send() {
	data, err := result.Json()
	if err != nil {
		return
	}
	invokeResult(result.callback, string(data))
	if result.Method != messageMethod {
		releaseObject(result.callback)
	}
}

func nextHandle(action *Action, result ActionResult) bool {
	switch action.Method {
	case updateDnsMethod:
		data := action.Data.(string)
		handleUpdateDns(data)
		result.success(true)
		return true
	}
	return false
}

//export invokeAction
func invokeAction(callback unsafe.Pointer, paramsChar *C.char) {
	params := takeCString(paramsChar)
	var action = &Action{}
	err := json.Unmarshal([]byte(params), action)
	if err != nil {
		invokeResult(callback, err.Error())
		return
	}
	result := ActionResult{
		Id:       action.Id,
		Method:   action.Method,
		callback: callback,
	}
	go handleAction(action, result)
}

//export startTUN
func startTUN(callback unsafe.Pointer, fd C.int, stackChar, addressChar, dnsChar *C.char) bool {
	handleStartTun(callback, int(fd), takeCString(stackChar), takeCString(addressChar), takeCString(dnsChar))
	if !isRunning {
		handleStartListener()
	} else {
		handleResetConnections()
	}
	return true
}

//export quickSetup
func quickSetup(callback unsafe.Pointer, initParamsChar *C.char, setupParamsChar *C.char) {
	go func() {
		initParamsString := takeCString(initParamsChar)
		setupParamsString := takeCString(setupParamsChar)
		if !handleInitClash(initParamsString) {
			invokeResult(callback, "init failed")
			return
		}
		isRunning = true
		message := handleSetupConfig([]byte(setupParamsString))
		invokeResult(callback, message)
	}()
}

//export setEventListener
func setEventListener(listener unsafe.Pointer) {
	if eventListener != nil || listener == nil {
		releaseObject(eventListener)
	}
	eventListener = listener
}

//export getTotalTraffic
func getTotalTraffic(onlyStatisticsProxy bool) *C.char {
	data := C.CString(handleGetTotalTraffic(onlyStatisticsProxy))
	defer C.free(unsafe.Pointer(data))
	return data
}

//export getTraffic
func getTraffic(onlyStatisticsProxy bool) *C.char {
	data := C.CString(handleGetTraffic(onlyStatisticsProxy))
	defer C.free(unsafe.Pointer(data))
	return data
}

func sendMessage(message Message) {
	if eventListener == nil {
		return
	}
	result := ActionResult{
		Method:   messageMethod,
		callback: eventListener,
		Data:     message,
	}
	result.send()
}

//export stopTun
func stopTun() {
	handleStopTun()
	if isRunning {
		handleStopListener()
	}
}

//export suspend
func suspend(suspended bool) {
	handleSuspend(suspended)
}

//export forceGC
func forceGC() {
	handleForceGC()
}

//export updateDns
func updateDns(s *C.char) {
	handleUpdateDns(takeCString(s))
}

