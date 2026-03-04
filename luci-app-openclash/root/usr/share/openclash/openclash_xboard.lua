#!/usr/bin/lua

local function getenv(name, default)
  local value = os.getenv(name)
  if value == nil or value == "" then
    return default
  end
  return value
end

local function trim(value)
  if not value then
    return ""
  end
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function starts_with(value, prefix)
  return value:sub(1, #prefix) == prefix
end

local function shell_escape(value)
  value = tostring(value or "")
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function cmd_success(command)
  local a, b, c = os.execute(command)
  if type(a) == "number" then
    return a == 0
  end
  if type(a) == "boolean" then
    return a and b == "exit" and c == 0
  end
  return false
end

local function run_capture(command)
  local pipe = io.popen(command, "r")
  if not pipe then
    return nil
  end
  local output = pipe:read("*a")
  pipe:close()
  return output
end

local function file_read(path)
  local handle = io.open(path, "rb")
  if not handle then
    return nil
  end
  local data = handle:read("*a")
  handle:close()
  return data
end

local function file_write(path, data)
  local handle = io.open(path, "wb")
  if not handle then
    return false
  end
  handle:write(data or "")
  handle:close()
  return true
end

local function file_size(path)
  local handle = io.open(path, "rb")
  if not handle then
    return 0
  end
  local data = handle:read("*a")
  handle:close()
  if not data then
    return 0
  end
  return #data
end

local function trim_url(raw)
  local value = trim(raw)
  while #value > 0 and value:sub(-1) == "/" do
    value = value:sub(1, -2)
  end
  return value
end

local function mask_url(raw)
  local value = tostring(raw or "")
  value = value:gsub("([?&]token=)[^&]+", "%1***MASKED***")
  value = value:gsub("(/subscription%-encrypt/)[^/?&]+", "%1***MASKED***")
  return value
end

local function parse_query_value(url, key)
  if not url or url == "" then
    return nil
  end
  local pattern = "[?&]" .. key:gsub("([^%w])", "%%%1") .. "=([^&]+)"
  return url:match(pattern)
end

local function urldecode(value)
  if not value then
    return ""
  end
  value = value:gsub("+", " ")
  value = value:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  return value
end

local http_urlencode = nil
do
  local ok_http, http = pcall(require, "luci.http")
  if ok_http and http and http.urlencode then
    http_urlencode = http.urlencode
  end
end

local function urlencode(value)
  value = tostring(value or "")
  if http_urlencode then
    return http_urlencode(value)
  end
  return (value:gsub("([^%w%-_%.~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local jsonc = nil
do
  local ok_jsonc, module = pcall(require, "luci.jsonc")
  if ok_jsonc then
    jsonc = module
  end
end

local function json_parse(raw)
  if not jsonc or not raw or raw == "" then
    return nil
  end
  local ok, result = pcall(jsonc.parse, raw)
  if ok then
    return result
  end
  return nil
end

local function json_get(obj, path)
  if type(obj) ~= "table" or type(path) ~= "string" then
    return nil
  end
  local current = obj
  for key in path:gmatch("[^.]+") do
    if type(current) ~= "table" then
      return nil
    end
    current = current[key]
    if current == nil then
      return nil
    end
  end
  return current
end

local function json_get_from_raw(raw, path)
  if not raw or raw == "" or not path or path == "" then
    return nil
  end

  if jsonc then
    local payload = json_parse(raw)
    if payload then
      return json_get(payload, path)
    end
  end

  local unique = tostring({}):gsub("table: ", ""):gsub("%W", "")
  local tmp_json = string.format("/tmp/openclash_xboard_json_%d_%s.json", os.time(), unique)
  if not file_write(tmp_json, raw) then
    return nil
  end

  local ruby_code = [[
begin
  obj = JSON.parse(File.read(ARGV[0]))
  cur = obj
  ARGV[1].split('.').each do |k|
    unless cur.is_a?(Hash) && cur.key?(k)
      exit 1
    end
    cur = cur[k]
  end
  if cur.nil?
    exit 1
  elsif cur.is_a?(String) || cur.is_a?(Numeric) || cur == true || cur == false
    print cur.to_s
  else
    print cur.to_json
  end
rescue
  exit 1
end
]]

  local command_parts = {"ruby", "-rjson", "-e", ruby_code, tmp_json, path}
  local quoted = {}
  for index = 1, #command_parts do
    quoted[#quoted + 1] = shell_escape(command_parts[index])
  end
  local command = table.concat(quoted, " ") .. " 2>/dev/null"
  local value = trim(run_capture(command) or "")
  os.remove(tmp_json)

  if value == "" then
    return nil
  end
  return value
end

local function json_escape(value)
  value = tostring(value or "")
  value = value:gsub("\\", "\\\\")
  value = value:gsub("\"", "\\\"")
  value = value:gsub("\n", "\\n")
  value = value:gsub("\r", "\\r")
  value = value:gsub("\t", "\\t")
  return "\"" .. value .. "\""
end

local function load_constants()
  local default_constants = {
    API_BASE_URL = "",
    API_TEXT_DOMAIN = "",
    APP_ICON_URL = "",
    APP_NAME = "",
    APP_PACKAGE_NAME = "",
    CRISP_WEBSITE_ID = "",
    THEME_COLOR = "",
    KEYSTORE = "",
    KEY_ALIAS = "",
    KEY_PASSWORD = "",
    STORE_PASSWORD = "",
    DEFAULT_BASE_URL = "",
    TEXT_DOMAIN_MAP = {},
    LOGIN_PATH = "/api/v1/passport/auth/login",
    GET_SUBSCRIBE_PATH = "/api/v1/user/getSubscribe",
    DEFAULT_SUB_PATH = "/api/v1/client/subscribe?token={token}",
  }

  local ok, module = pcall(dofile, "/usr/share/openclash/openclash_xboard_constants.lua")
  if ok and type(module) == "table" then
    for key, value in pairs(module) do
      default_constants[key] = value
    end
  end

  return default_constants
end

local resolve_api_text_hosts = nil

local function resolve_base_url(constants)
  local function force_https(url)
    url = trim_url(url)
    if url == "" then
      return ""
    end
    url = url:gsub("^https?://", "")
    return "https://" .. url
  end

  local function add_candidate(candidates, value)
    value = trim_url(value)
    if value == "" then
      return
    end
    if not starts_with(value, "http://") and not starts_with(value, "https://") then
      value = "https://" .. value
    end
    value = force_https(value)
    for _, item in ipairs(candidates) do
      if item == value then
        return
      end
    end
    candidates[#candidates + 1] = value
  end

  local function race_candidates(candidates)
    if #candidates == 0 then
      return ""
    end
    if #candidates == 1 then
      return candidates[1]
    end

    local unique = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
    local tmp_file = "/tmp/openclash_xboard_race_" .. unique .. ".txt"
    local script = "rm -f " .. shell_escape(tmp_file) .. "; "

    for _, base in ipairs(candidates) do
      local test_url = trim_url(base) .. "/api/v1/guest/comm/config"
      script = script ..
        "( r=$(curl -k -sS --noproxy '*' --connect-timeout 5 -m 8 -o /dev/null -w '%{http_code} %{time_total}' " ..
        shell_escape(test_url) .. " 2>/dev/null); " ..
        "c=${r%% *}; t=${r#* }; case \"$c\" in 2*|3*) printf '%s\\t%s\\n' \"$t\" " ..
        shell_escape(base) .. " >> " .. shell_escape(tmp_file) .. ";; esac ) & "
    end

    script = script ..
      "wait; " ..
      "if [ -s " .. shell_escape(tmp_file) .. " ]; then sort -n " .. shell_escape(tmp_file) ..
      " | head -n1 | awk '{print $2}'; fi; " ..
      "rm -f " .. shell_escape(tmp_file)

    local winner = trim(run_capture(script) or "")
    if winner ~= "" then
      return winner
    end
    return candidates[1]
  end

  local candidates = {}
  local api_text_domain = trim(constants.API_TEXT_DOMAIN or "")
  local fallback = trim_url(constants.API_BASE_URL or constants.DEFAULT_BASE_URL or "")

  add_candidate(candidates, fallback)

  if resolve_api_text_hosts and api_text_domain ~= "" then
    local hosts = resolve_api_text_hosts(constants)
    if type(hosts) == "table" then
      for _, host in ipairs(hosts) do
        add_candidate(candidates, host)
      end
    end
  end

  if #candidates == 0 and type(constants.TEXT_DOMAIN_MAP) == "table" then
    add_candidate(candidates, constants.TEXT_DOMAIN_MAP[api_text_domain or ""])
  end

  return race_candidates(candidates)
end

local function join_url(base, path)
  base = trim_url(base)
  path = trim(path or "")
  if path == "" then
    return base
  end
  if starts_with(path, "http://") or starts_with(path, "https://") then
    return path
  end
  if path:sub(1, 1) ~= "/" then
    path = "/" .. path
  end
  return base .. path
end

local function build_subscribe_url(base_url, sub_path, token)
  if base_url == "" or token == "" then
    return ""
  end

  local final_path = trim(sub_path or "")
  if final_path == "" then
    final_path = "/api/v1/client/subscribe?token={token}"
  end

  local encoded_token = urlencode(token)

  if final_path:find("{token}", 1, true) then
    final_path = final_path:gsub("{token}", encoded_token)
  elseif not final_path:find("token=", 1, true) then
    if final_path:find("%?", 1) then
      final_path = final_path .. "&token=" .. encoded_token
    else
      final_path = final_path .. "?token=" .. encoded_token
    end
  end

  if starts_with(final_path, "http://") or starts_with(final_path, "https://") then
    return final_path
  end

  if final_path:sub(1, 1) ~= "/" then
    final_path = "/" .. final_path
  end

  return base_url .. final_path
end

local function build_curl_command(parts)
  local quoted = {}
  for index = 1, #parts do
    quoted[#quoted + 1] = shell_escape(parts[index])
  end
  return table.concat(quoted, " ")
end

local api_text_cache = {}

resolve_api_text_hosts = function(constants)
  constants = constants or {}
  local api_text_domain = trim(constants.API_TEXT_DOMAIN or "")
  local password = trim(constants.APP_NAME or "")
  local fallback_crisp = trim(constants.CRISP_WEBSITE_ID or "")

  if api_text_domain == "" then
    return {}
  end

  if starts_with(api_text_domain, "http://") or starts_with(api_text_domain, "https://") then
    return {trim_url(api_text_domain)}
  end

  if password == "" then
    return {}
  end

  local cache_key = api_text_domain .. "|" .. password
  if api_text_cache[cache_key] then
    return api_text_cache[cache_key]
  end

  local ruby_code = [[
begin
  domain = ARGV[0].to_s.strip
  password = ARGV[1].to_s
  fallback_crisp = ARGV[2].to_s.strip
  exit 1 if domain.empty? || password.empty?

  query = URI.encode_www_form_component(domain)
  servers = [
    "https://dns.google/resolve?name=#{query}&type=TXT",
    "https://cloudflare-dns.com/dns-query?name=#{query}&type=TXT"
  ]

  txt = nil
  servers.each do |url|
    begin
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 4
      http.read_timeout = 4
      req = Net::HTTP::Get.new(uri)
      req['accept'] = 'application/dns-json'
      req['user-agent'] = 'openclash-xboard/1.0'
      res = http.request(req)
      next unless res.code.to_i == 200
      payload = JSON.parse(res.body) rescue nil
      next unless payload.is_a?(Hash)
      answers = payload['Answer']
      next unless answers.is_a?(Array)
      answers.each do |answer|
        next unless answer.is_a?(Hash)
        next unless answer['type'].to_i == 16
        data = answer['data'].to_s.strip
        next if data.empty?
        if data.include?('"')
          chunks = data.scan(/"([^"]*)"/).flatten
          data = chunks.join unless chunks.empty?
        end
        data = data.gsub(/\A"+|"+\z/, '')
        data = data.gsub('\"', '"')
        data = data.gsub(/\s+/, '')
        if !data.empty?
          txt = data
          break
        end
      end
      break if txt && !txt.empty?
    rescue
      next
    end
  end

  exit 1 if txt.nil? || txt.empty?
  encrypted = Base64.decode64(txt.to_s)
  exit 1 if encrypted.nil? || encrypted.bytesize < 16
  exit 1 unless encrypted[0, 8] == 'Salted__'

  salt = encrypted[8, 8]
  ciphertext = encrypted[16..-1] || ''.b
  derived = ''.b
  prev = ''.b
  while derived.bytesize < 48
    prev = Digest::MD5.digest(prev + password.b + salt)
    derived << prev
  end
  key = derived[0, 32]
  iv = derived[32, 16]

  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.decrypt
  cipher.key = key
  cipher.iv = iv
  plaintext = cipher.update(ciphertext) + cipher.final

  config = JSON.parse(plaintext) rescue nil
  exit 1 unless config.is_a?(Hash)

  hosts = config['hosts']
  if hosts.is_a?(Array)
    hosts.each do |host|
      host_s = host.to_s.strip
      next if host_s.empty?
      puts "HOST=#{host_s}"
    end
  end

  crisp = config['crisp'].to_s.strip
  crisp = fallback_crisp if crisp.empty?
  puts "CRISP=#{crisp}" unless crisp.empty?
rescue
  exit 1
end
]]

  local command = build_curl_command({
    "ruby",
    "-rjson",
    "-ruri",
    "-rnet/http",
    "-rbase64",
    "-ropenssl",
    "-rdigest",
    "-e",
    ruby_code,
    api_text_domain,
    password,
    fallback_crisp
  }) .. " 2>/dev/null"

  local output = run_capture(command) or ""
  local hosts = {}
  for line in output:gmatch("[^\r\n]+") do
    if starts_with(line, "HOST=") then
      local host = trim(line:sub(6))
      if host ~= "" then
        if not starts_with(host, "http://") and not starts_with(host, "https://") then
          host = "https://" .. host
        end
        hosts[#hosts + 1] = trim_url(host)
      end
    elseif starts_with(line, "CRISP=") then
      local crisp = trim(line:sub(7))
      if crisp ~= "" and (not constants.CRISP_WEBSITE_ID or constants.CRISP_WEBSITE_ID == "") then
        constants.CRISP_WEBSITE_ID = crisp
      end
    end
  end

  api_text_cache[cache_key] = hosts
  return hosts
end

local function http_request(method, request_url, request_ua, auth_token, request_data)
  local unique = tostring({}):gsub("table: ", ""):gsub("%W", "")
  local tmp_output = string.format("/tmp/openclash_xboard_http_%d_%s.json", os.time(), unique)
  local parts = {
    "curl", "-sS", "-L", "--connect-timeout", "10", "-m", "30", "--retry", "1",
    "-H", "User-Agent: " .. (request_ua or "clash.meta")
  }

  if method == "POST" then
    parts[#parts + 1] = "-H"
    parts[#parts + 1] = "Content-Type: application/json"
    parts[#parts + 1] = "-X"
    parts[#parts + 1] = "POST"
    parts[#parts + 1] = "-d"
    parts[#parts + 1] = request_data or "{}"
  else
    parts[#parts + 1] = "-X"
    parts[#parts + 1] = "GET"
  end

  if auth_token and auth_token ~= "" then
    parts[#parts + 1] = "-H"
    parts[#parts + 1] = "Authorization: " .. auth_token
  end

  parts[#parts + 1] = "-o"
  parts[#parts + 1] = tmp_output
  parts[#parts + 1] = "-w"
  parts[#parts + 1] = "%{http_code}"
  parts[#parts + 1] = request_url

  local http_code = trim(run_capture(build_curl_command(parts)) or "")
  local body = file_read(tmp_output) or ""
  os.remove(tmp_output)

  if http_code:match("^2%d%d$") then
    return true, body, tonumber(http_code) or 0
  end
  return false, body, tonumber(http_code) or 0
end

local function parse_meta(meta)
  local map = {}
  for pair in tostring(meta or ""):gmatch("[^,]+") do
    local key, value = pair:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
    if key and value and key ~= "" then
      map[key] = value
    end
  end
  return map
end

local function meta_get(meta_map, key, default)
  local value = meta_map[key]
  if value == nil or value == "" then
    return default
  end
  return value
end

local function run_ruby(ruby_requires, ruby_code, args)
  local parts = {"ruby"}
  for _, item in ipairs(ruby_requires or {}) do
    parts[#parts + 1] = item
  end
  parts[#parts + 1] = "-e"
  parts[#parts + 1] = ruby_code
  for _, item in ipairs(args or {}) do
    parts[#parts + 1] = item
  end
  return cmd_success(build_curl_command(parts) .. " >/dev/null 2>&1")
end

local function decode_payload()
  local cfg_file = getenv("XB_CFG_FILE", "")
  local enc_enable = getenv("XB_ENC_ENABLE", "0")
  local enc_format = getenv("XB_ENC_FORMAT", "json-envelope")
  local enc_algo = getenv("XB_ENC_ALGO", "aes-256-cbc")
  local enc_key_ref = getenv("XB_ENC_KEY_REF", "token-sha256")
  local enc_key_value = getenv("XB_ENC_KEY_VALUE", "")
  local enc_meta = getenv("XB_ENC_META", "iv=iv,data=data,tag=tag,cipher=cipher,format=format")
  local sub_token = getenv("XB_SUB_TOKEN", "")
  local auth_token = getenv("XB_AUTH_TOKEN", "")

  if enc_enable ~= "1" then
    return true
  end

  if cfg_file == "" or file_size(cfg_file) == 0 then
    return false
  end

  if enc_format == "base64" then
    local ruby_code = [[
begin
  content = File.read(ARGV[0])
  File.binwrite(ARGV[0], Base64.decode64(content))
rescue
  exit 1
end
]]
    return run_ruby({"-rbase64"}, ruby_code, {cfg_file})
  end

  if enc_format == "raw" then
    return true
  end

  local key_source = ""
  if enc_key_ref == "token-sha256" or enc_key_ref == "token" then
    key_source = sub_token
  elseif enc_key_ref == "auth-token-sha256" or enc_key_ref == "auth-token" then
    key_source = auth_token
  elseif enc_key_ref == "literal" then
    key_source = enc_key_value
  else
    key_source = sub_token
  end

  if key_source == "" then
    return false
  end

  local meta_map = parse_meta(enc_meta)
  local iv_field = meta_get(meta_map, "iv", "iv")
  local data_field = meta_get(meta_map, "data", "data")
  local tag_field = meta_get(meta_map, "tag", "tag")
  local cipher_field = meta_get(meta_map, "cipher", "cipher")
  local format_field = meta_get(meta_map, "format", "format")

  local ruby_code = [[
begin
  file_path = ARGV[0]
  algo = (ARGV[1] || 'aes-256-cbc').downcase
  key_ref = ARGV[2] || 'token-sha256'
  key_source = ARGV[3] || ''
  iv_field = ARGV[4] || 'iv'
  data_field = ARGV[5] || 'data'
  tag_field = ARGV[6] || 'tag'
  cipher_field = ARGV[7] || 'cipher'
  format_field = ARGV[8] || 'format'

  raw = File.read(file_path)
  begin
    payload = JSON.parse(raw)
  rescue
    exit 0
  end

  unless payload.is_a?(Hash)
    exit 0
  end

  enc_data = payload[data_field] || payload['data']
  if enc_data.nil? || enc_data.to_s.empty?
    exit 0
  end

  envelope_format = (payload[format_field] || payload['format']).to_s
  if !envelope_format.empty? && envelope_format != 'encrypted'
    exit 0
  end

  cipher_name = (payload[cipher_field] || payload['cipher'] || algo).to_s.downcase
  if cipher_name.empty?
    cipher_name = algo
  end

  key =
    if key_ref.end_with?('-sha256')
      Digest::SHA256.digest(key_source)
    else
      key_source.dup.force_encoding('BINARY')
    end
  if key.bytesize != 32
    key = Digest::SHA256.digest(key_source)
  end

  encrypted_bin = Base64.decode64(enc_data.to_s)
  plain = nil
  if cipher_name.include?('gcm')
    nonce_raw = payload[iv_field] || payload['iv'] || payload['nonce']
    tag_raw = payload[tag_field] || payload['tag']
    raise 'missing nonce/tag' if nonce_raw.nil? || tag_raw.nil?
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.decode64(nonce_raw.to_s)
    cipher.auth_tag = Base64.decode64(tag_raw.to_s)
    cipher.auth_data = ''
    plain = cipher.update(encrypted_bin) + cipher.final
  else
    iv_raw = payload[iv_field] || payload['iv']
    raise 'missing iv' if iv_raw.nil?
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.decode64(iv_raw.to_s)
    plain = cipher.update(encrypted_bin) + cipher.final
  end

  File.binwrite(file_path, plain)
rescue
  exit 1
end
]]

  return run_ruby({"-rjson", "-rbase64", "-rdigest", "-ropenssl"}, ruby_code, {
    cfg_file,
    enc_algo,
    enc_key_ref,
    key_source,
    iv_field,
    data_field,
    tag_field,
    cipher_field,
    format_field,
  })
end

-- decode_payload_to_fifo: decrypt and write plaintext to FIFO for zero-landed plaintext
local function decode_payload_to_fifo()
  local cfg_file = getenv("XB_CFG_FILE", "")
  local fifo_file = getenv("XB_FIFO_FILE", "")
  local enc_enable = getenv("XB_ENC_ENABLE", "0")
  local enc_format = getenv("XB_ENC_FORMAT", "json-envelope")
  local enc_algo = getenv("XB_ENC_ALGO", "aes-256-cbc")
  local enc_key_ref = getenv("XB_ENC_KEY_REF", "token-sha256")
  local enc_key_value = getenv("XB_ENC_KEY_VALUE", "")
  local enc_meta = getenv("XB_ENC_META", "iv=iv,data=data,tag=tag,cipher=cipher,format=format")
  local sub_token = getenv("XB_SUB_TOKEN", "")
  local auth_token = getenv("XB_AUTH_TOKEN", "")

  if enc_enable ~= "1" then
    -- No encryption: copy file to FIFO directly
    if cfg_file ~= "" and fifo_file ~= "" then
      local cmd = "cat " .. shell_escape(cfg_file) .. " > " .. shell_escape(fifo_file)
      return cmd_success(cmd)
    end
    return false
  end

  if cfg_file == "" or file_size(cfg_file) == 0 then
    return false
  end

  if fifo_file == "" then
    return false
  end

  if enc_format == "base64" then
    local ruby_code = [[
begin
  require 'base64'
  content = File.read(ARGV[0])
  plain = Base64.decode64(content)
  # Write to FIFO
  fifo = ARGV[1]
  File.open(fifo, 'wb') { |f| f.write(plain) }
rescue
  exit 1
end
]]
    return run_ruby({"-rbase64"}, ruby_code, {cfg_file, fifo_file})
  end

  if enc_format == "raw" then
    -- Raw format: copy directly to FIFO
    local cmd = "cat " .. shell_escape(cfg_file) .. " > " .. shell_escape(fifo_file)
    return cmd_success(cmd)
  end

  local key_source = ""
  if enc_key_ref == "token-sha256" or enc_key_ref == "token" then
    key_source = sub_token
  elseif enc_key_ref == "auth-token-sha256" or enc_key_ref == "auth-token" then
    key_source = auth_token
  elseif enc_key_ref == "literal" then
    key_source = enc_key_value
  else
    key_source = sub_token
  end

  if key_source == "" then
    return false
  end

  local meta_map = parse_meta(enc_meta)
  local iv_field = meta_get(meta_map, "iv", "iv")
  local data_field = meta_get(meta_map, "data", "data")
  local tag_field = meta_get(meta_map, "tag", "tag")
  local cipher_field = meta_get(meta_map, "cipher", "cipher")
  local format_field = meta_get(meta_map, "format", "format")

  local ruby_code = [[
begin
  require 'json'
  require 'base64'
  require 'digest'
  require 'openssl'

  cfg_file = ARGV[0]
  fifo_file = ARGV[1]
  algo = (ARGV[2] || 'aes-256-cbc').downcase
  key_ref = ARGV[3] || 'token-sha256'
  key_source = ARGV[4] || ''
  iv_field = ARGV[5] || 'iv'
  data_field = ARGV[6] || 'data'
  tag_field = ARGV[7] || 'tag'
  cipher_field = ARGV[8] || 'cipher'
  format_field = ARGV[9] || 'format'

  raw = File.read(cfg_file)
  begin
    payload = JSON.parse(raw)
  rescue
    exit 0
  end

  unless payload.is_a?(Hash)
    exit 0
  end

  enc_data = payload[data_field] || payload['data']
  if enc_data.nil? || enc_data.to_s.empty?
    exit 0
  end

  envelope_format = (payload[format_field] || payload['format']).to_s
  if !envelope_format.empty? && envelope_format != 'encrypted'
    exit 0
  end

  cipher_name = (payload[cipher_field] || payload['cipher'] || algo).to_s.downcase
  if cipher_name.empty?
    cipher_name = algo
  end

  key =
    if key_ref.end_with?('-sha256')
      Digest::SHA256.digest(key_source)
    else
      key_source.dup.force_encoding('BINARY')
    end
  if key.bytesize != 32
    key = Digest::SHA256.digest(key_source)
  end

  encrypted_bin = Base64.decode64(enc_data.to_s)
  plain = nil
  if cipher_name.include?('gcm')
    nonce_raw = payload[iv_field] || payload['iv'] || payload['nonce']
    tag_raw = payload[tag_field] || payload['tag']
    raise 'missing nonce/tag' if nonce_raw.nil? || tag_raw.nil?
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.decode64(nonce_raw.to_s)
    cipher.auth_tag = Base64.decode64(tag_raw.to_s)
    cipher.auth_data = ''
    plain = cipher.update(encrypted_bin) + cipher.final
  else
    iv_raw = payload[iv_field] || payload['iv']
    raise 'missing iv' if iv_raw.nil?
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.decode64(iv_raw.to_s)
    plain = cipher.update(encrypted_bin) + cipher.final
  end

  # Write plaintext to FIFO (zero-landed: no temp file)
  File.open(fifo_file, 'wb') { |f| f.write(plain) }
rescue => e
  exit 1
end
]]

  return run_ruby({"-rjson", "-rbase64", "-rdigest", "-ropenssl"}, ruby_code, {
    cfg_file,
    fifo_file,
    enc_algo,
    enc_key_ref,
    key_source,
    iv_field,
    data_field,
    tag_field,
    cipher_field,
    format_field,
  })
end

local function prepare_subscription()
  local constants = load_constants()

  local auth_mode = getenv("XB_AUTH_MODE", "auto")
  local provider_token = getenv("XB_PROVIDER_TOKEN", "")
  local provider_email = getenv("XB_PROVIDER_EMAIL", "")
  local provider_password = getenv("XB_PROVIDER_PASSWORD", "")
  local sub_path = getenv("XB_SUB_PATH", constants.DEFAULT_SUB_PATH or "/api/v1/client/subscribe?token={token}")
  local request_ua = getenv("XB_UA", "clash.meta")

  local base_url = resolve_base_url(constants)
  if base_url == "" then
    return false
  end

  local login_path = trim(getenv("XB_LOGIN_PATH", constants.LOGIN_PATH or "/api/v1/passport/auth/login"))
  local get_subscribe_path = trim(getenv("XB_GET_SUBSCRIBE_PATH", constants.GET_SUBSCRIBE_PATH or "/api/v1/user/getSubscribe"))

  local login_api = join_url(base_url, login_path)
  local subscribe_api = join_url(base_url, get_subscribe_path)

  local auth_token = ""
  if auth_mode == "token" or auth_mode == "auto" then
    auth_token = provider_token
  end

  local function do_login()
    if provider_email == "" or provider_password == "" then
      return nil
    end
    local login_payload = "{" ..
      "\"email\":" .. json_escape(provider_email) .. "," ..
      "\"password\":" .. json_escape(provider_password) ..
    "}"
    local ok, body = http_request("POST", login_api, request_ua, "", login_payload)
    if not ok then
      return nil
    end
    local token = json_get_from_raw(body, "data.auth_data")
    if (not token or token == "") then
      token = json_get_from_raw(body, "data.token")
    end
    if token and token ~= "" then
      return tostring(token)
    end
    return nil
  end

  if auth_mode == "login" or auth_token == "" then
    local token = do_login()
    if not token or token == "" then
      return false
    end
    auth_token = token
  end

  local subscribe_url = ""
  local sub_token = ""

  local function load_subscribe()
    local ok, body = http_request("GET", subscribe_api, request_ua, auth_token, "")
    if not ok then
      return "", ""
    end
    local sub_url = json_get_from_raw(body, "data.subscribe_url")
    local token = json_get_from_raw(body, "data.token")
    return tostring(sub_url or ""), tostring(token or "")
  end

  subscribe_url, sub_token = load_subscribe()

  if subscribe_url == "" and sub_token == "" and auth_mode == "auto" and provider_email ~= "" and provider_password ~= "" then
    local token = do_login()
    if token and token ~= "" then
      auth_token = token
      subscribe_url, sub_token = load_subscribe()
    end
  end

  if subscribe_url == "" then
    if sub_token == "" then
      sub_token = provider_token
    end
    if sub_token == "" then
      sub_token = auth_token
    end
    subscribe_url = build_subscribe_url(base_url, sub_path, sub_token)
  end

  if sub_token == "" and subscribe_url ~= "" then
    local extracted = parse_query_value(subscribe_url, "token")
    if extracted and extracted ~= "" then
      sub_token = urldecode(extracted)
    end
  end

  if subscribe_url == "" then
    return false
  end

  print("BASE_URL=" .. base_url)
  print("AUTH_TOKEN=" .. (auth_token or ""))
  print("SUB_TOKEN=" .. (sub_token or ""))
  print("SUBSCRIBE_URL=" .. subscribe_url)
  print("MASKED_SUBSCRIBE_URL=" .. mask_url(subscribe_url))
  return true
end

local mode = getenv("XB_MODE", arg[1] or "")
if mode == "mask-url" then
  local raw_url = getenv("XB_URL", arg[2] or "")
  io.write(mask_url(raw_url))
  os.exit(0)
elseif mode == "prepare" then
  if prepare_subscription() then
    os.exit(0)
  else
    os.exit(1)
  end
elseif mode == "decode" then
  if decode_payload() then
    os.exit(0)
  else
    os.exit(1)
  end
elseif mode == "decode-fifo" then
  if decode_payload_to_fifo() then
    os.exit(0)
  else
    os.exit(1)
  end
else
  os.exit(1)
end
