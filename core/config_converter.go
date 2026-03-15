package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/sagernet/sing-box/include"
	"github.com/sagernet/sing-box/option"
	sjson "github.com/sagernet/sing/common/json"
)

// ParseSingboxConfig parses raw sing-box JSON config bytes into option.Options.
// It uses the same extended JSON decoder and registries that sing-box upstream uses.
func ParseSingboxConfig(raw []byte) (*option.Options, error) {
	ctx := include.Context(context.Background())
	opts, err := sjson.UnmarshalExtendedContext[option.Options](ctx, raw)
	if err != nil {
		// Keep a plain JSON fallback for simpler tests and minimal configs.
		if plainErr := json.Unmarshal(raw, &opts); plainErr != nil {
			return nil, fmt.Errorf("parse sing-box config: %w", err)
		}
	}
	return &opts, nil
}
