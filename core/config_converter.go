package main

import (
	"encoding/json"
	"fmt"

	"github.com/sagernet/sing-box/option"
)

// ParseSingboxConfig parses raw sing-box JSON config bytes into option.Options.
// No YAML conversion — the subscription server returns native sing-box JSON format.
func ParseSingboxConfig(raw []byte) (*option.Options, error) {
	var opts option.Options
	if err := json.Unmarshal(raw, &opts); err != nil {
		return nil, fmt.Errorf("parse sing-box config: %w", err)
	}
	return &opts, nil
}
