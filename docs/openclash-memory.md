# OpenClash Development Memory (xboard Track)

Last updated: 2026-02-21

## Upstream Branch Memory
- Upstream repo: `https://github.com/vernesong/OpenClash.git`
- Default branch: `master`
- Existing heads: `master`, `dev`, `package`, `core`
- Practical base for customization: `master`

## Lightweight Clone Memory
- Only master, shallow:
  - `git clone --branch master --single-branch --depth 1 https://github.com/vernesong/OpenClash.git`
- Smaller with partial clone:
  - `git clone --branch master --single-branch --depth 1 --filter=blob:none https://github.com/vernesong/OpenClash.git`

## Current Subscription Pipeline Memory
- Main updater script:
  - `luci-app-openclash/root/usr/share/openclash/openclash.sh`
- Key function:
  - `sub_info_get()`
- Current temp plaintext path:
  - `CFG_FILE="/tmp/yaml_sub_tmp_config.yaml"`
- Current flow:
  - download -> write CFG_FILE -> clash test -> ruby parse -> move to `/etc/openclash/config/*.yaml`

## Collision Domains To Rename For xboard Fork
- Package: `luci-app-openclash`
- UCI config: `openclash`
- Init service: `openclash`
- Runtime dir: `/etc/openclash`, `/usr/share/openclash`
- LuCI path: `admin/services/openclash`
- Static resources: `/www/luci-static/resources/openclash`
- ACL/Ucitrack file names and keys
- Firewall include section `firewall.openclash`
- Temp/lock/log files with `openclash` prefix

## Security Memory (Encrypted Config + 0-Landed Plaintext)
- "0-landed plaintext" target means decrypted content must not be saved as regular temp file.
- Recommended first implementation on OpenWrt:
  - stream decrypt with pipe/FIFO, no plaintext file.
- Strict no-fs-node mode (memfd helper) is possible but larger scope.

## Build/Delivery Memory
- Implement in phases:
  1. namespace fork and coexist install
  2. xboard encrypted provider
  3. zero-land decrypt path with feature flag
  4. optional strict mode hardening

## Next Coding Session Entry Points
- `luci-app-openclash/Makefile`
- `luci-app-openclash/luasrc/controller/openclash.lua`
- `luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe.lua`
- `luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua`
- `luci-app-openclash/root/usr/share/openclash/openclash.sh`
- `luci-app-openclash/root/etc/uci-defaults/luci-openclash`
- `luci-app-openclash/root/etc/init.d/openclash`

