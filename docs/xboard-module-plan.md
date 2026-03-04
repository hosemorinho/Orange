# OpenClash xboard Module Plan

## Scope
- Base repo: `J:/html/OpenClash` (upstream OpenClash `master`).
- Goal: add an `xboard`-oriented module that can coexist with user-installed OpenClash without collisions.
- Goal: support encrypted config pull and "0-landed plaintext decrypt" flow.

## Non-Conflict Strategy (Must-Do)
Use a strict namespace instead of partial rename.

`APP_ID` example: `xboardclash`
`APP_NAME` example: `XBoard Clash`

All identifiers below should be parameterized by `APP_ID`:
- Package name: `luci-app-${APP_ID}` (not `luci-app-openclash`)
- UCI config: `/etc/config/${APP_ID}` (not `/etc/config/openclash`)
- Init service: `/etc/init.d/${APP_ID}` (not `/etc/init.d/openclash`)
- Runtime dir: `/etc/${APP_ID}` and `/usr/share/${APP_ID}`
- LuCI static dir: `/www/luci-static/resources/${APP_ID}`
- LuCI route: `admin/services/${APP_ID}`
- ACL file/key: `root/usr/share/rpcd/acl.d/luci-app-${APP_ID}.json`
- Ucitrack: `root/usr/share/ucitrack/luci-app-${APP_ID}.json`
- Firewall include section: `firewall.${APP_ID}`, file `/var/etc/${APP_ID}.include`
- Temp/lock/log prefix: `/tmp/${APP_ID}*`, `/tmp/lock/${APP_ID}*`

If any `openclash` symbol is left in these areas, dual-install conflicts will still happen.

## Current Files That Drive Namespacing
- `luci-app-openclash/Makefile`
- `luci-app-openclash/root/etc/init.d/openclash`
- `luci-app-openclash/root/etc/config/openclash`
- `luci-app-openclash/root/etc/uci-defaults/luci-openclash`
- `luci-app-openclash/luasrc/controller/openclash.lua`
- `luci-app-openclash/root/usr/share/rpcd/acl.d/luci-app-openclash.json`
- `luci-app-openclash/root/usr/share/ucitrack/luci-app-openclash.json`
- `luci-app-openclash/root/usr/share/openclash/*.sh`

## xboard Encrypted Config Pull Plan

### 1) UCI model extension (`config_subscribe`)
Add fields for encrypted subscription:
- `enc_enable` (`0/1`)
- `enc_format` (`raw`, `base64`, `json-envelope`)
- `enc_algo` (`aes-256-gcm` initially)
- `enc_key_ref` (reference, not plain key)
- `enc_meta` (nonce/tag field names for envelope mode)
- `provider_type` (`default`, `xboard`)
- `provider_auth_ref` (token/key reference)

Do not store long-term secrets in plain UCI text if avoidable. Prefer key-id + secure resolver script.

### 2) Pull path
Current path downloads to `CFG_FILE="/tmp/yaml_sub_tmp_config.yaml"` in:
- `root/usr/share/openclash/openclash.sh` (`config_download`, `sub_info_get`)

New path for encrypted xboard provider:
- `fetch_encrypted_stream` -> `decrypt_stream` -> `validate_yaml` -> `apply`

### 3) 0-landed plaintext decrypt (recommended level)
Recommended for OpenWrt shell constraints:
- Keep encrypted payload in stream (stdin).
- Decrypt to stdout only.
- Pass plaintext through pipe/FIFO to parser/tester.
- Never write decrypted plaintext to regular temp files.

Practical implementation:
- FIFO node in `/tmp` with `chmod 600` and immediate cleanup.
- Producer: decrypt command writes plaintext into FIFO.
- Consumer: YAML validator + Clash `-t` read FIFO.

This is "zero plaintext landed", but still uses a FIFO inode (no plaintext file content persisted).

### 4) Strict mode (optional, bigger change)
If you need no filesystem node at all:
- Add small helper binary using `memfd_create`.
- Decrypt into memfd, exec clash with `/proc/self/fd/<n>`.

Impact is larger and less portable than FIFO mode.

## Important Reality Check
OpenClash workflow edits and stores final YAML config for management features.
So there are two modes:
- `secure_runtime_mode=0` (default): final config stays on disk for compatibility.
- `secure_runtime_mode=1` (strict): keep encrypted-at-rest and decrypt only for runtime path; many edit/merge features must be constrained or redesigned.

If you require strict all-memory runtime, this is a medium-to-large refactor, not a small patch.

## Delivery Phases

### Phase A (Low risk, first)
- Full namespacing and package split.
- Build and install coexisting with upstream OpenClash.

### Phase B (Medium)
- Add xboard provider fields and API pull path.
- Keep current plain subscription path untouched.

### Phase C (Medium-Large)
- Add zero-land decrypt pipeline (FIFO first).
- Add feature flag and fallback logic.

### Phase D (Optional Large)
- Strict memfd mode + encrypted-at-rest policy.
- Limit/adjust editing features that assume plain YAML on disk.

## Acceptance Checklist
- Can install `luci-app-openclash` and `luci-app-${APP_ID}` together.
- Each package owns independent UCI/init/firewall/ACL/resources.
- Encrypted subscription can update config without plaintext temp file.
- Logs do not print secrets.
- Restart/upgrade does not leak plaintext artifacts in `/tmp` or `/etc`.

## Suggested Branch Layout
- `xboard/base-namespace`
- `xboard/provider-encrypted-fetch`
- `xboard/zero-land-decrypt`
- `xboard/hardening-and-tests`
