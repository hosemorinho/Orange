# OpenClash xboard Integration Progress

Last updated: 2026-02-21

Detailed UI/API mapping doc: `docs/xboard-ui-api.md`

## Implemented

1. Added xboard provider fields in subscribe edit UI.
2. Added controller API persistence for xboard fields in `action_add_subscription`.
3. Added xboard runtime flow in updater:
   - login: `/api/v1/passport/auth/login`
   - subscribe metadata: `/api/v1/user/getSubscribe`
   - subscribe URL build: `/api/v1/client/subscribe?token=...` or custom path
   - encrypted payload decode before Clash/YAML validation
4. Added URL masking in logs to avoid token leakage.
5. Migrated xboard core logic from shell to Lua:
   - new runtime file: `root/usr/share/openclash/openclash_xboard.lua`
   - shell now only calls Lua for `prepare`, `decode`, and `mask-url`
6. Added Lua constants file for hardcoded endpoint/domain config:
   - `root/usr/share/openclash/openclash_xboard_constants.lua`
7. Added CI injection script + workflow hook for GitHub Actions secrets:
   - `.github/scripts/inject_xboard_constants.sh`
   - `.github/workflows/compile_new_ipk.yml` (optional secrets-driven injection)
8. Added LuCI frontend branding integration:
   - shared loader: `luasrc/openclash.lua::get_branding()`
   - toolbar branding chip (name/icon + theme button color):
     `luasrc/view/openclash/toolbar_show.htm`
   - status page branding ribbon + theme color override:
     `luasrc/view/openclash/status.htm`
   - native Crisp floating widget init in LuCI pages (shown only when `CRISP_WEBSITE_ID` is configured)
9. Added full XBoard LuCI portal and switched default OpenClash menu entry:
   - visible menu now points to `xboard` page
   - native OpenClash UI menus are hidden from navigation
   - deprecated `xboard_base_url` field removed from UI/save path
   - old `xboard_base_url` residues are auto-cleaned from UCI
   - API host now resolves from `API_BASE_URL` + decrypted `API_TEXT_DOMAIN` hosts with latency race (Orange-style)
   - new XBoard pages:
     - auth: login / register / forgot password
     - dashboard: home / plans / tickets / invite / settings
   - new backend endpoints for frontend integration:
     - `GET/POST /admin/services/openclash/xboard/config`
     - `POST /admin/services/openclash/xboard/proxy`

## New UCI fields for `config_subscribe`

- `provider_type`: `default` | `xboard`
- `provider_auth_ref`: `auto` | `token` | `login`
- `xboard_email`
- `xboard_password`
- `xboard_token`
- `xboard_sub_path`
- `enc_enable`: `0` | `1`
- `enc_format`: `raw` | `base64` | `json-envelope`
- `enc_algo`: `aes-256-cbc` | `aes-256-gcm`
- `enc_key_ref`: `token-sha256` | `token` | `auth-token-sha256` | `auth-token` | `literal`
- `enc_key_value`
- `enc_meta` (example: `iv=iv,data=data,tag=tag,cipher=cipher,format=format`)

## Runtime behavior

1. `provider_type != xboard`: keep original OpenClash behavior.
2. `provider_type = xboard`:
   - resolve base URL only from constants:
     - `API_BASE_URL`
     - decrypted `API_TEXT_DOMAIN` hosts
   - supports `API_TEXT_DOMAIN` resolution:
     - query TXT via DoH (`dns.google` / `cloudflare-dns.com`)
     - decrypt TXT payload with CryptoJS-compatible AES-256-CBC (`Salted__`, EVP_BytesToKey MD5), password=`APP_NAME`
     - read `hosts` list from decrypted JSON and run latency race (Orange-style) to pick fastest API base
   - optional text-domain alias mapping in Lua constants (`TEXT_DOMAIN_MAP`)
   - auth strategy:
     - `token`: use `xboard_token`
     - `login`: use `xboard_email` + `xboard_password`
     - `auto`: token first, then one login retry when subscribe metadata is empty
   - use `/api/v1/user/getSubscribe` first
   - fallback to `xboard_sub_path` if `subscribe_url` missing
   - optional decrypt if `enc_enable=1`

## CI secrets injection (optional)

The compile workflow can inject these secrets into `openclash_xboard_constants.lua`:

- `API_BASE_URL` (used)
- `API_TEXT_DOMAIN` (used: DoH TXT resolve entry)
- `APP_ICON_URL` (used in LuCI toolbar/status branding icon)
- `APP_NAME` (used as API_TEXT_DOMAIN decrypt password + LuCI branding name)
- `APP_PACKAGE_NAME` (used as LuCI branding tooltip metadata)
- `CRISP_WEBSITE_ID` (used to enable native Crisp floating chat widget in LuCI, hidden when empty)
- `KEYSTORE` (stored only, currently not used by OpenClash runtime)
- `KEY_ALIAS` (stored only, currently not used by OpenClash runtime)
- `KEY_PASSWORD` (stored only, currently not used by OpenClash runtime)
- `STORE_PASSWORD` (stored only, currently not used by OpenClash runtime)
- `THEME_COLOR` (used in LuCI primary color override)

## Security note

Build-time injection reduces repository exposure, but values embedded into the shipped OpenWrt package remain extractable from device filesystem. Do not treat built artifacts as a secure secret vault.

## Validation checklist

1. Configure one xboard subscription in LuCI:
   - `provider_type=xboard`
   - token or login credentials
   - `API_BASE_URL` and/or `API_TEXT_DOMAIN` configured via constants
2. Trigger update from UI.
3. Verify:
   - YAML validation passes
   - config file updates under `/etc/openclash/config/*.yaml`
   - `/tmp/openclash.log` URL line has masked token
4. Optional:
   - enable `enc_enable=1` and verify decryption works

## Not yet done

1. Full package namespace split for coexist install (`luci-app-xboardclash`).
2. FIFO-based zero-landed-plaintext pipeline.
3. Strict in-memory decrypt mode (`memfd`) and feature constraints.
