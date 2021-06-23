local zdm = 'zdm-dailybonus'
local uci = luci.model.uci.cursor()
local sys = require 'luci.sys'

m = Map(zdm)

-- [[ Global setting ]]--

s = m:section(TypedSection, 'global', translate('Global Setting'))
s.anonymous = true

--Auto Run Script Service

o = s:option(Flag, 'auto_run', translate('Enable automatic sign-in and post a mood'))
o.rmempty = false

o = s:option(ListValue, 'auto_run_interval', translate('Auto refresh check in interval (minutes)'))
for t = 1, 60 do
    o:value(t, t)
end
o.default = 12
o.rmempty = true
o:depends('auto_run', '1')
o.description = translate('Auto refresh in serval minutes to avoid cookie timeout')

o = s:option(Value, 'delay', translate('Sign-in delay'))
o.rmempty = false
o.default = 1000
o.datatype = integer
o.description = translate('Customize concurrent sign-in delay, in milliseconds')

o = s:option(Value, 'timeout', translate('API timeout'))
o.rmempty = false
o.default = 0
o.datatype = integer
o.description = translate('API timeout, to avoid interface blockage when the network is unstable, 0 is not limited, in milliseconds')

o = s:option(Value, 'sign_text', translate('Sign-in mood'))
o.rmempty = true
o.description = translate('Mood text for each automatic sign in')

o = s:option(Flag, 'notify_success', translate('Push notification only for sign-in success and cookie timeout'))
o.rmempty = false
o.description = translate('By default, the message will be pushed every time the sign in is refreshed')

-- Cookies

o = s:option(DynamicList, "Cookies", translate("Account cookies"))
o.rmempty = false
o.description = translate('Double click the input box, then scan the QR code, the input box will be autocomplete after login success')

-- Dingding

o = s:option(Value, 'dd_token', translate('Dingtalk robot webhook'))
o.rmempty = true
o.description = translate('Add a dingtalk group custom robot and set the keyword as 签到 to get a webhook')

-- server chan
o = s:option(ListValue, 'serverurl', translate('Server chan API URL'))
o:value('scu', translate('SCU'))
o:value('sct', translate('SCT'))
o.default = 'scu'
o.rmempty = false
o.description = translate('Select the type of push interface for the server chan')

o = s:option(Value, 'serverchan', translate('Select chan SCKEY'))
o.rmempty = true
o.description = translate('Sign in and bind to get a SCKEY on http://sc.ftqq.com/')

-- telegram

o = s:option(Value, 'tg_token', translate('Telegram Bot Token'))
o.rmempty = true
o.description = translate('Search the BotFather robot on Telegram, create a notification robot and get the token')

o = s:option(Value, 'tg_userid', translate('Telegram UserID'))
o.rmempty = true
o.description = translate('Search the getuserIDbot robot on Telegram to get your UserID')

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.template = 'zdm-dailybonus/cookie_tools'

return m
