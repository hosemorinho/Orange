local M = {
  -- Build-injected runtime constants from GitHub Actions secrets.
  API_BASE_URL = "",
  API_TEXT_DOMAIN = "",
  APP_ICON_URL = "",
  -- APP_NAME is also used as API_TEXT_DOMAIN decrypt password.
  APP_NAME = "",
  APP_PACKAGE_NAME = "",
  CRISP_WEBSITE_ID = "",
  THEME_COLOR = "",
  KEYSTORE = "",
  KEY_ALIAS = "",
  KEY_PASSWORD = "",
  STORE_PASSWORD = "",

  -- Optional text-domain alias map. Example:
  -- TEXT_DOMAIN_MAP = {
  --   ["prod"] = "https://api.example.com",
  -- }
  TEXT_DOMAIN_MAP = {},

  -- API path constants for xboard/v2board style endpoints.
  LOGIN_PATH = "/api/v1/passport/auth/login",
  GET_SUBSCRIBE_PATH = "/api/v1/user/getSubscribe",
  DEFAULT_SUB_PATH = "/api/v1/client/subscribe?token={token}",
}

return M
