
local m, s, o
local openclash = "openclash"
local uci = luci.model.uci.cursor()
local fs = require "luci.openclash"
local sys = require "luci.sys"
local json = require "luci.jsonc"
local sid = arg[1]

font_red = [[<b style=color:red>]]
font_off = [[</b>]]
bold_on = [[<strong>]]
bold_off = [[</strong>]]


m = Map(openclash, translate("Config Subscribe Edit"))
m.pageaction = false
m.description=translate("Convert Subscribe function of Online is Supported By subconverter Written By tindy X") ..
"<br/>"..
"<br/>"..translate("API By tindy X & lhie1")..
"<br/>"..
"<br/>"..translate("Subconverter external configuration (subscription conversion template) Description: https://github.com/tindy2013/subconverter#external-configuration-file")..
"<br/>"..
"<br/>"..translate("If you need to customize the external configuration file (subscription conversion template), please write it according to the instructions, upload it to the accessible location of the external network, and fill in the address correctly when using it")..
"<br/>"..
"<br/>"..translate("If you have a recommended external configuration file (subscription conversion template), you can modify by following The file format of /usr/share/openclash/res/sub_ini.list and pr")
m.redirect = luci.dispatcher.build_url("admin/services/openclash/config-subscribe")
if m.uci:get(openclash, sid) ~= "config_subscribe" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Config Subscribe Setting ]]--
s = m:section(NamedSection, sid, "config_subscribe")
s.anonymous = true
s.addremove = false

---- name
o = s:option(Value, "name", translate("Config Alias"))
o.description = font_red..bold_on..translate("Name For Distinguishing")..bold_off..font_off
o.placeholder = translate("config")
o.rmempty = true

---- address
o = s:option(Value, "address", translate("Subscribe Address"))
o.template = "cbi/tvalue"
o.rows = 10
o.wrap = "off"
o.description = font_red..bold_on..translate("SS/SSR/Vmess or Other Link And Subscription Address is Supported When Online Subscription Conversion is Enabled, Multiple Links Should be One Per Line or Separated By |")..bold_off..font_off
o.placeholder = translate("Not Null")
o.rmempty = false
function o.validate(self, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		value = value:gsub("%c*$", "")
	end
	return value
end

---- provider type
o = s:option(ListValue, "provider_type", translate("Provider Type"))
o.description = translate("Choose subscription provider workflow")
o:value("default", translate("Default"))
o:value("xboard", translate("XBoard"))
o.default = "default"
o.rmempty = true

---- provider auth mode
o = s:option(ListValue, "provider_auth_ref", translate("Provider Auth Mode"))
o.description = translate("XBoard token source")
o:value("auto", translate("Auto"))
o:value("token", translate("Token"))
o:value("login", translate("Email/Password"))
o.default = "auto"
o.rmempty = true
o:depends("provider_type", "xboard")

---- xboard token
o = s:option(Value, "xboard_token", translate("XBoard Token"))
o.description = translate("Auth token from /api/v1/passport/auth/login or panel")
o.password = true
o.rmempty = true
o:depends({provider_type = "xboard", provider_auth_ref = "auto"})
o:depends({provider_type = "xboard", provider_auth_ref = "token"})

---- xboard email
o = s:option(Value, "xboard_email", translate("XBoard Email"))
o.rmempty = true
o:depends({provider_type = "xboard", provider_auth_ref = "auto"})
o:depends({provider_type = "xboard", provider_auth_ref = "login"})

---- xboard password
o = s:option(Value, "xboard_password", translate("XBoard Password"))
o.password = true
o.rmempty = true
o:depends({provider_type = "xboard", provider_auth_ref = "auto"})
o:depends({provider_type = "xboard", provider_auth_ref = "login"})

---- xboard subscribe path
o = s:option(Value, "xboard_sub_path", translate("XBoard Subscribe Path"))
o.description = translate("Use {token} placeholder, e.g. /api/v1/client/subscribe?token={token} or /api/v2/subscription-encrypt/{token}")
o.placeholder = "/api/v1/client/subscribe?token={token}"
o.default = "/api/v1/client/subscribe?token={token}"
o.rmempty = true
o:depends("provider_type", "xboard")

---- encrypted subscribe enable
o = s:option(Flag, "enc_enable", translate("Encrypted Subscribe Decode"))
o.description = translate("Decode encrypted payload before Clash validation")
o.default = 0
o.rmempty = true
o:depends("provider_type", "xboard")

---- encrypted format
o = s:option(ListValue, "enc_format", translate("Encrypted Format"))
o:value("raw", "raw")
o:value("base64", "base64")
o:value("json-envelope", "json-envelope")
o.default = "json-envelope"
o.rmempty = true
o:depends({provider_type = "xboard", enc_enable = "1"})

---- encrypted algorithm
o = s:option(ListValue, "enc_algo", translate("Encrypted Algorithm"))
o:value("aes-256-cbc", "aes-256-cbc")
o:value("aes-256-gcm", "aes-256-gcm")
o.default = "aes-256-cbc"
o.rmempty = true
o:depends({provider_type = "xboard", enc_enable = "1"})

---- encrypted key ref
o = s:option(ListValue, "enc_key_ref", translate("Encrypted Key Reference"))
o:value("token-sha256", "token-sha256")
o:value("token", "token")
o:value("auth-token-sha256", "auth-token-sha256")
o:value("auth-token", "auth-token")
o:value("literal", "literal")
o.default = "token-sha256"
o.rmempty = true
o:depends({provider_type = "xboard", enc_enable = "1"})

---- encrypted key value
o = s:option(Value, "enc_key_value", translate("Encrypted Literal Key"))
o.password = true
o.rmempty = true
o:depends({provider_type = "xboard", enc_enable = "1", enc_key_ref = "literal"})

---- encrypted meta
o = s:option(Value, "enc_meta", translate("Encrypted Envelope Meta"))
o.description = translate("Comma-separated key mapping, e.g. iv=iv,data=data,tag=tag,cipher=cipher,format=format")
o.placeholder = "iv=iv,data=data,tag=tag,cipher=cipher,format=format"
o.default = "iv=iv,data=data,tag=tag,cipher=cipher,format=format"
o.rmempty = true
o:depends({provider_type = "xboard", enc_enable = "1"})

local sub_path = "/tmp/dler_sub"
local info, token, get_sub, sub_info
local token = fs.uci_get_config("config", "dler_token")
if token then
	get_sub = string.format("curl -sL -H 'Content-Type: application/json' --connect-timeout 2 -d '{\"access_token\":\"%s\"}' -X POST https://dler.cloud/api/v1/managed/clash -o %s", token, sub_path)
	if not nixio.fs.access(sub_path) then
		luci.sys.exec(get_sub)
	else
		if fs.readfile(sub_path) == "" or not fs.readfile(sub_path) then
			luci.sys.exec(get_sub)
		end
	end
	sub_info = fs.readfile(sub_path)
	if sub_info then
		sub_info = json.parse(sub_info)
	end
	if sub_info and sub_info.ret == 200 then
		o:value(sub_info.smart)
		o:value(sub_info.ss)
		o:value(sub_info.vmess)
		o:value(sub_info.trojan)
	else
		fs.unlink(sub_path)
	end
end

---- UA
o = s:option(Value, "sub_ua", "User-Agent")
o.description = font_red..bold_on..translate("Used for Downloading Subscriptions, Defaults to Clash")..bold_off..font_off
o:value("clash.meta")
o:value("clash-verge/v1.5.1")
o:value("Clash")
o.default = "clash.meta"
o.rmempty = true

---- subconverter
o = s:option(Flag, "sub_convert", translate("Subscribe Convert Online"))
o.description = translate("Convert Subscribe Online With Template")
o.default = 0

---- Convert Address
o = s:option(Value, "convert_address", translate("Convert Address"))
o.rmempty = true
o.description = font_red..bold_on..translate("Note: There is A Risk of Privacy Leakage in Online Convert")..bold_off..font_off
o:depends("sub_convert", "1")
o:value("https://api.dler.io/sub", translate("api.dler.io")..translate("(Default)"))
o:value("https://api.wcc.best/sub", translate("api.wcc.best"))
o:value("https://api.asailor.org/sub", translate("api.asailor.org"))
o.default = "https://api.dler.io/sub"
o.placeholder = "https://api.dler.io/sub"

---- Template
o = s:option(ListValue, "template", translate("Template Name"))
o.rmempty = true
o:depends("sub_convert", "1")
file = io.open("/usr/share/openclash/res/sub_ini.list", "r");
for l in file:lines() do
	if l ~= "" and l ~= nil then
		o:value(string.sub(luci.sys.exec(string.format("echo '%s' |awk -F ',' '{print $1}' 2>/dev/null",l)),1,-2))
	end
end
file:close()
o:value("0", translate("Custom Template"))

---- Custom Template
o = s:option(Value, "custom_template_url", translate("Custom Template URL"))
o.rmempty = true
o.placeholder = translate("Not Null")
o.datatype = "or(host, string)"
o:depends("template", "0")

---- emoji
o = s:option(ListValue, "emoji", translate("Emoji"))
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- udp
o = s:option(ListValue, "udp", translate("UDP Enable"))
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- skip-cert-verify
o = s:option(ListValue, "skip_cert_verify", translate("skip-cert-verify"))
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- sort
o = s:option(ListValue, "sort", translate("Sort"))
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- node type
o = s:option(ListValue, "node_type", translate("Append Node Type"))
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- rule provider
o = s:option(ListValue, "rule_provider", translate("Use Rule Provider"))
o.description = font_red..bold_on..translate("Note: Please Make Sure Backend Service Supports This Feature")..bold_off..font_off
o.rmempty = false
o:value("false", translate("Disable"))
o:value("true", translate("Enable"))
o.default = "false"
o:depends("sub_convert", "1")

---- custom params
o = s:option(DynamicList, "custom_params", translate("Custom Params"))
o.description = font_red..bold_on..translate("eg: \"rename=match@replace\" , \"rename=\\s+([2-9])[xX]@ (HIGH:$1)\"")..bold_off..font_off
o.rmempty = false
o:depends("sub_convert", "1")

---- key
o = s:option(DynamicList, "keyword", font_red..bold_on..translate("Keyword Match")..bold_off..font_off)
o.description = font_red..bold_on..translate("eg: hk or tw&bgp")..bold_off..font_off
o.rmempty = true

---- exkey
o = s:option(DynamicList, "ex_keyword", font_red..bold_on..translate("Exclude Keyword Match")..bold_off..font_off)
o.description = font_red..bold_on..translate("eg: hk or tw&bgp")..bold_off..font_off
o.rmempty = true

---- de_exkey
o = s:option(MultiValue, "de_ex_keyword", font_red..bold_on..translate("Exclude Keyword Match Default")..bold_off..font_off)
o.rmempty = true
o:value("过期时间")
o:value("剩余流量")
o:value("TG群")
o:value("官网")

local t = {
	{Commit, Back}
}
a = m:section(Table, t)

o = a:option(Button,"Commit", " ")
o.inputtitle = translate("Commit Settings")
o.inputstyle = "apply"
o.write = function()
	m.uci:commit(openclash)
	luci.http.redirect(m.redirect)
end

o = a:option(Button,"Back", " ")
o.inputtitle = translate("Back Settings")
o.inputstyle = "reset"
o.write = function()
	m.uci:revert(openclash, sid)
	luci.http.redirect(m.redirect)
end

m:append(Template("openclash/toolbar_show"))
return m
