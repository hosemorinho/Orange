package main

import (
	b "bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/sagernet/sing-box"
	"github.com/sagernet/sing-box/adapter"
	"github.com/sagernet/sing-box/include"
	"github.com/sagernet/sing-box/log"
	"github.com/sagernet/sing-box/option"
	"github.com/sagernet/sing/service"
)

var (
	currentBox    *box.Box
	currentCtx    context.Context
	currentCancel context.CancelFunc
	currentOpts   *option.Options // last applied options, for partial update

	version   = 0
	homeDir   = ""
	isRunning = false
	isInit    = false
	runLock   sync.Mutex

	// observable log factory reference, set after Box creation
	logFactory log.ObservableFactory

	// platformInterfaceProvider is set by lib.go init() on CGO/Android builds.
	// It is registered in the Box context before box.New() so sing-box can
	// use it during initialization (TUN, socket protection, etc.).
	platformInterfaceProvider adapter.PlatformInterface

	// selectedMapSnapshot is applied when a delayed or restarted box comes up.
	selectedMapSnapshot = map[string]string{}
)

const inlineConfigPrefix = "inline-b64://"
const sessionConfigPrefix = "session://"

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     "https://www.gstatic.com/generate_204",
		SelectedMap: map[string]string{},
	}
}

func readFile(path string) ([]byte, error) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return nil, err
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	return data, err
}

// readConfigBytes supports both on-disk file path and in-memory inline payload.
// Inline payload format: inline-b64://<base64-encoded-raw-config-bytes>
func readConfigBytes(pathOrInline string) ([]byte, error) {
	if strings.HasPrefix(pathOrInline, inlineConfigPrefix) {
		encoded := strings.TrimPrefix(pathOrInline, inlineConfigPrefix)
		return base64.StdEncoding.DecodeString(encoded)
	}
	if strings.HasPrefix(pathOrInline, sessionConfigPrefix) {
		sessionId := strings.TrimPrefix(pathOrInline, sessionConfigPrefix)
		return consumeCommittedConfig(sessionId)
	}
	return readFile(pathOrInline)
}

// getClashServer retrieves the ClashServer from the running Box context.
func getClashServer() adapter.ClashServer {
	if currentCtx == nil {
		return nil
	}
	return service.FromContext[adapter.ClashServer](currentCtx)
}

// getOutboundManager retrieves the OutboundManager from the running Box.
func getOutboundManager() adapter.OutboundManager {
	if currentBox == nil {
		return nil
	}
	return currentBox.Outbound()
}

// applyConfig consumes the committed config session, parses sing-box JSON,
// creates a new Box, and starts it.
func applyConfig(params *SetupParams) error {
	runLock.Lock()
	defer runLock.Unlock()

	if params.ConfigSessionId == "" {
		return errors.New("config session id required; file-based config fallback is disabled")
	}
	buf, consumeErr := consumeCommittedConfig(params.ConfigSessionId)
	if consumeErr != nil {
		return fmt.Errorf("config session error: %w", consumeErr)
	}
	defer zeroBytes(buf)

	// Parse sing-box JSON config directly
	opts, err := ParseSingboxConfig(buf)
	if err != nil {
		return fmt.Errorf("config parse error: %w", err)
	}

	// Store for partial updates
	currentOpts = opts
	selectedMapSnapshot = cloneSelectedMap(params.SelectedMap)

	// Shut down existing box if running, but keep currentOpts/current selections
	// so a later startListener/startTUN can bring the box up with the same config.
	shutdownBox()

	if !isRunning || shouldDelayBoxStart(opts) {
		return nil
	}

	if err := startBoxFromOpts(opts); err != nil {
		return err
	}

	patchSelectGroup(selectedMapSnapshot)

	return nil
}

// startBoxFromOpts creates and starts a new Box from the given options.
// Caller must hold runLock. Sets currentBox, currentCtx, currentCancel, logFactory.
func startBoxFromOpts(opts *option.Options) error {
	ctx, cancel := context.WithCancel(context.Background())
	ctx = include.Context(ctx)
	ctx = service.ContextWithDefaultRegistry(ctx)

	// Register platform interface before box.New() — sing-box reads it from context
	if platformInterfaceProvider != nil {
		service.MustRegister[adapter.PlatformInterface](ctx, platformInterfaceProvider)
	}

	boxInstance, err := box.New(box.Options{
		Context: ctx,
		Options: *opts,
	})
	if err != nil {
		cancel()
		return fmt.Errorf("create box: %w", err)
	}

	if err := boxInstance.Start(); err != nil {
		_ = boxInstance.Close()
		cancel()
		return fmt.Errorf("start box: %w", err)
	}

	currentBox = boxInstance
	currentCtx = ctx
	currentCancel = cancel

	// Capture observable log factory for log streaming
	if lf := boxInstance.LogFactory(); lf != nil {
		if of, ok := lf.(log.ObservableFactory); ok {
			logFactory = of
		}
	}

	// Reset traffic rate tracking
	prevUp, prevDown = 0, 0
	prevTime = time.Time{}
	if logStreamingRequested {
		handleStartLog()
	}

	return nil
}

// shutdownBox closes the current Box and cancels its context.
// Caller must hold runLock.
func shutdownBox() {
	stopLogSubscription(false)
	if currentBox != nil {
		_ = currentBox.Close()
		currentBox = nil
	}
	if currentCancel != nil {
		currentCancel()
		currentCancel = nil
		currentCtx = nil
	}
	logFactory = nil
	prevUp, prevDown = 0, 0
	prevTime = time.Time{}
}

// patchSelectGroup iterates outbounds and force-selects the specified proxy in selector groups.
func patchSelectGroup(mapping map[string]string) {
	if currentBox == nil || len(mapping) == 0 {
		return
	}
	outboundMgr := currentBox.Outbound()
	for _, ob := range outboundMgr.Outbounds() {
		selected, exist := mapping[ob.Tag()]
		if !exist {
			continue
		}
		if group, ok := ob.(adapter.OutboundGroup); ok {
			selectOutbound(group, selected)
		}
	}
}

// selectOutbound tries to select the named outbound in a group.
// It checks if the group implements SelectOutbound (selector groups).
func selectOutbound(group adapter.OutboundGroup, name string) bool {
	type selectorGroup interface {
		SelectOutbound(tag string) bool
	}
	if sel, ok := group.(selectorGroup); ok {
		return sel.SelectOutbound(name)
	}
	return false
}

func cloneSelectedMap(src map[string]string) map[string]string {
	if len(src) == 0 {
		return map[string]string{}
	}
	dst := make(map[string]string, len(src))
	for key, value := range src {
		dst[key] = value
	}
	return dst
}

func hasTunInbound(opts *option.Options) bool {
	if opts == nil {
		return false
	}
	for _, inbound := range opts.Inbounds {
		if inbound.Type == "tun" {
			return true
		}
	}
	return false
}

func shouldDelayBoxStart(opts *option.Options) bool {
	if !hasTunInbound(opts) || platformInterfaceProvider == nil {
		return false
	}
	type tunReadyProvider interface {
		TunReady() bool
	}
	if provider, ok := platformInterfaceProvider.(tunReadyProvider); ok {
		return !provider.TunReady()
	}
	return false
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	err := decoder.Decode(v)
	return err
}
