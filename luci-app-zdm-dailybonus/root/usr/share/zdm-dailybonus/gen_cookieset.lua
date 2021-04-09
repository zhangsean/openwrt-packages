#!/usr/bin/lua
local uci = require "luci.model.uci".cursor()
local json = require 'luci.jsonc'

function write_json(file, content)
    local f = assert(io.open(file, 'w'))
    f:write(json.stringify(content, 1))
    f:close()
end


local data = {
    Cookies = {},
    DailyBonusDelay = uci:get('zdm-dailybonus', '@global[0]', 'stop'),
    DailyBonusTimeOut = uci:get('zdm-dailybonus', '@global[0]', 'out')
}

for i, v in pairs( uci:get('zdm-dailybonus', '@global[0]', 'Cookies') or {} ) do
    table.insert(data.Cookies, {["cookie"]=v})
end

data.Cookies = json.stringify( data.Cookies )

write_json('/usr/share/zdm-dailybonus/CookieSet.json', data)
