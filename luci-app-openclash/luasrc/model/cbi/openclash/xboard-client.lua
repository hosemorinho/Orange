local m

m = SimpleForm("xboard_client", translate("XBoard Client"))
m.description = translate("XBoard unified portal for OpenClash")
m.reset = false
m.submit = false

m:section(SimpleSection).template = "openclash/xboard_client"

return m
