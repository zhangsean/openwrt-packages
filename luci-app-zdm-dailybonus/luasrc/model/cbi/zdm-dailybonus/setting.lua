local zdm = 'zdm-dailybonus'
local uci = luci.model.uci.cursor()
local sys = require 'luci.sys'

m = Map(zdm)
-- [[ 基本设置 ]]--

s = m:section(TypedSection, 'global', translate('基本设置'))
s.anonymous = true

o = s:option(DynamicList, "Cookies", translate("账号 Cookie 列表"))
o.rmempty = false
o.description = translate('双击输入框或点击添加图标即可调出二维码，扫码后自动填入。')

o = s:option(Value, 'sign_text', translate('签到心情'))
o.rmempty = true
o.description = translate('每次自动签到的心情文本')

o = s:option(Value, 'stop', translate('延迟签到'))
o.rmempty = false
o.default = 0
o.datatype = integer
o.description = translate('自定义延迟签到,单位毫秒. 默认分批并发无延迟. (延迟作用于每个签到接口, 如填入延迟则切换顺序签到. ) ')

o = s:option(Value, 'out', translate('接口超时'))
o.rmempty = false
o.default = 0
o.datatype = integer
o.description = translate('接口超时退出,单位毫秒 用于可能发生的网络不稳定, 0则关闭.')

-- server chan
o = s:option(ListValue, 'serverurl', translate('Server酱的推送接口地址'))
o:value('scu', translate('SCU'))
o:value('sct', translate('SCT'))
o.default = 'scu'
o.rmempty = false
o.description = translate('选择Server酱的推送接口')

o = s:option(Value, 'serverchan', translate('Server酱 SCKEY'))
o.rmempty = true
o.description = translate('微信推送，基于Server酱服务，请自行登录 http://sc.ftqq.com/ 绑定并获取 SCKEY。')

-- Dingding

o = s:option(Value, 'dd_token', translate('钉钉机器人 Token'))
o.rmempty = true
o.description = translate('创建一个群机器人并获取API Token，设置安全关键字为:签到')

-- telegram

o = s:option(Value, 'tg_token', translate('Telegram Bot Token'))
o.rmempty = true
o.description = translate('首先在Telegram上搜索BotFather机器人，创建一个属于自己的通知机器人，并获取Token。')

o = s:option(Value, 'tg_userid', translate('Telegram UserID'))
o.rmempty = true
o.description = translate('在Telegram上搜索getuserIDbot机器人，获取UserID。')

o = s:option(Flag, 'notify_success', translate('只推送签到成功和Cookie超时'))
o.rmempty = false
o.description = translate('默认每次刷新签到都推送消息')

--Auto Run Script Service

o = s:option(Flag, 'auto_run', translate('自动刷新签到'))
o.rmempty = false

o = s:option(ListValue, 'auto_run_interval', translate('自动刷新签到间隔(分钟)'))
for t = 1, 60 do
    o:value(t, t)
end
o.default = 12
o.rmempty = true
o:depends('auto_run', '1')
o.description = translate('每隔n分钟去刷新以避免Cookie超时')

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.template = 'zdm-dailybonus/cookie_tools'

return m
