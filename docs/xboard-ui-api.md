# OpenClash XBoard UI 与 API 对照说明

最后更新：2026-02-22

## 1. 当前 UI 覆盖范围

LuCI 入口已切到 XBoard 页面：

- 路由：`/admin/services/openclash/xboard`
- 菜单标题：`XBoard`
- 视图模板：`luci-app-openclash/luasrc/view/openclash/xboard_client.htm`
- 前端逻辑：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js`

页面覆盖（已实现）：

- 认证页：登录 / 注册 / 忘记密码
- 面板页：首页 / 套餐 / 工单 / 邀请 / 设置

对应模板位置：

- 认证 tabs：`luci-app-openclash/luasrc/view/openclash/xboard_client.htm:39`
- 页面导航：`luci-app-openclash/luasrc/view/openclash/xboard_client.htm:108`
- 页面容器：`luci-app-openclash/luasrc/view/openclash/xboard_client.htm:115`

## 2. LuCI 后端 API（供前端调用）

当前新增并使用的 LuCI 接口：

1. `GET/POST /admin/services/openclash/xboard/config`
2. `POST /admin/services/openclash/xboard/proxy`

定义位置：

- `luci-app-openclash/luasrc/controller/openclash.lua:4680`
- `luci-app-openclash/luasrc/controller/openclash.lua:4703`

### 2.1 `xboard/config` 返回内容

主要字段：

- `ok`
- `base_url`
- `api_text_domain`
- `app_name`
- `app_icon_url`
- `theme_color`
- `crisp_website_id`
- `app_package_name`

前端用于品牌展示和可用性判断：

- 品牌加载：`client.js` 的 `initBranding()`
- API 可用性判断：`loadConfig()` 中 `state.baseUrl`

### 2.2 `xboard/proxy` 请求格式

`application/x-www-form-urlencoded` 字段：

- `method`: `GET` 或 `POST`
- `path`: 目标 XBoard API 路径
- `token`: 用户 token（匿名接口可不传）
- `query`: JSON 字符串（可选）
- `data`: JSON 字符串（可选）

当前后端限制：

- 仅允许 `GET/POST`
- `path` 必须以 `/api/v1/` 开头
- 禁止 `..` 路径穿越

校验位置：

- `luci-app-openclash/luasrc/controller/openclash.lua:4711`
- `luci-app-openclash/luasrc/controller/openclash.lua:4717`

## 3. 页面与 XBoard API 对照

以下为前端 `client.js` 实际调用集合（已实现）：

### 3.1 认证相关

- 登录：`POST /api/v1/passport/auth/login`
- 注册：`POST /api/v1/passport/auth/register`
- 忘记密码：`POST /api/v1/passport/auth/forget`
- 邮箱验证码：`POST /api/v1/passport/comm/sendEmailVerify`
- 登录态检查：`GET /api/v1/passport/auth/check`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:473`

### 3.2 首页

- 用户信息：`GET /api/v1/user/info`
- 订阅信息：`GET /api/v1/user/getSubscribe`
- 统计信息：`GET /api/v1/user/getStat`
- 公告列表：`GET /api/v1/user/notice/fetch`
- 重置订阅链接：`GET /api/v1/user/resetSecurity`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:390`

### 3.3 套餐/购买

- 套餐列表：`GET /api/v1/user/plan/fetch`
- 创建订单：`POST /api/v1/user/order/save`
- 支付方式：`GET /api/v1/user/order/getPaymentMethod`
- 发起结账：`POST /api/v1/user/order/checkout`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:278`

### 3.4 工单

- 工单列表/详情：`GET /api/v1/user/ticket/fetch`
- 新建工单：`POST /api/v1/user/ticket/save`
- 回复工单：`POST /api/v1/user/ticket/reply`
- 关闭工单：`POST /api/v1/user/ticket/close`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:411`

### 3.5 邀请

- 邀请信息：`GET /api/v1/user/invite/fetch`
- 邀请明细：`GET /api/v1/user/invite/details`
- 生成邀请码：`GET /api/v1/user/invite/save`
- 佣金划转：`POST /api/v1/user/transfer`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:429`

### 3.6 设置

- 更新用户资料：`POST /api/v1/user/update`
- 修改密码：`POST /api/v1/user/changePassword`
- 退出登录：`GET /api/v1/user/logout`

参考：`luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:602`

## 4. API 基地址解析（已去除 `xboard_base_url`）

当前逻辑只使用以下常量输入：

- `API_BASE_URL`
- `API_TEXT_DOMAIN`（解密解析 host 列表）
- `APP_NAME`（作为 `API_TEXT_DOMAIN` 解密密码）

策略：

1. 收集候选 host（`API_BASE_URL` + `API_TEXT_DOMAIN` 解密结果）
2. 请求 `/api/v1/guest/comm/config` 做延迟竞速
3. 选最快可用 base URL 并缓存 300 秒

位置：

- `luci-app-openclash/luasrc/controller/openclash.lua:4573`
- `luci-app-openclash/root/usr/share/openclash/openclash_xboard.lua`

## 5. 品牌与 Crisp 展示

已支持从常量注入并展示：

- `APP_NAME`
- `APP_ICON_URL`
- `APP_PACKAGE_NAME`
- `THEME_COLOR`
- `CRISP_WEBSITE_ID`

规则：

- 配置了 `CRISP_WEBSITE_ID` 才显示原生 Crisp 浮窗
- 未配置则不显示

前端入口：

- `luci-app-openclash/root/www/luci-static/resources/openclash/xboard/client.js:147`

## 6. 当前状态结论

就“首页/套餐/工单/邀请/设置 + 登录/注册/忘记密码”这条目标线，UI 和 API 代理链路已经打通，可运行。

目前仍属于“可用版”的范围，不是“100% 对齐所有 XBoard 站点定制接口”的最终形态。不同站点若有额外私有接口，仍需要按站点扩展。
