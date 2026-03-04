# workflow_dispatch 最小验收清单

文件：`.github/workflows/compile_new_ipk.yml`

## 触发方式

1. 打开 GitHub Actions -> `Compile The New Version OpenClash`
2. 点击 `Run workflow`
3. `run_minimal_acceptance` 保持 `true`
4. 运行后查看 Job：`Minimal-Acceptance`

## 验收范围

`Minimal-Acceptance` 不下载 SDK，不编译固件，仅做最小改写验收：

1. `Resolve Namespace`
2. `Inject XBoard Constants (Optional)`
3. `Inject Namespace and Runtime Paths (Optional)`
4. `Minimal Acceptance Checks`

## Secrets 逐项检查

会校验这些值已被写入常量文件（逐字段文本匹配）：

1. `API_BASE_URL`
2. `API_TEXT_DOMAIN`
3. `APP_ICON_URL`
4. `APP_NAME`
5. `APP_PACKAGE_NAME`
6. `CRISP_WEBSITE_ID`
7. `THEME_COLOR`
8. `KEYSTORE`
9. `KEY_ALIAS`
10. `KEY_PASSWORD`
11. `STORE_PASSWORD`

额外规则：

1. 当 `API_TEXT_DOMAIN` 非 URL 且 `API_BASE_URL` 非空时，校验 `TEXT_DOMAIN_MAP` 映射项已生成。

## 命名空间与产物路径检查

命名空间解析优先级：

1. `APP_NAMESPACE`
2. `APP_NAME`（slugify）
3. `APP_PACKAGE_NAME`（slugify）
4. 默认 `openclash`

假设解析结果为 `APP_NS`，会校验：

1. `Makefile` 包名：`PKG_NAME:=luci-app-${APP_NS}`
2. 路由命名空间：`/admin/services/${APP_NS}/xboard`
3. 静态资源命名空间：`/luci-static/resources/${APP_NS}/xboard/`
4. 运行目录存在：
   - `root/usr/share/${APP_NS}`
   - `root/etc/${APP_NS}`
   - `root/www/luci-static/resources/${APP_NS}`
5. 文件重命名存在：
   - `root/etc/init.d/${APP_NS}`
   - `root/etc/uci-defaults/luci-${APP_NS}`
   - `root/usr/share/rpcd/acl.d/luci-app-${APP_NS}.json`
   - `root/usr/share/ucitrack/luci-app-${APP_NS}.json`
6. 当 `APP_NS != openclash` 时，旧路径必须不存在：
   - `root/usr/share/openclash`
   - `root/etc/openclash`
   - `root/www/luci-static/resources/openclash`
   - `root/etc/init.d/openclash`
   - `root/etc/uci-defaults/luci-openclash`
   - `root/usr/share/rpcd/acl.d/luci-app-openclash.json`
   - `root/usr/share/ucitrack/luci-app-openclash.json`

## 结果判定

1. Job 全绿且 `Minimal Acceptance Checks` 无 `::error::`，判定通过。
2. `Step Summary` 会输出：
   - `APP_NS`
   - `PKG_NAME`
   - 常量文件路径
   - 已检查 secrets 列表
   - 已检查命名空间替换范围

