-- Copyright (C) 2021 zhangsean <zxf2342@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module('luci.controller.zdm-dailybonus', package.seeall)
function index()
    if not nixio.fs.access('/etc/config/zdm-dailybonus') then
        return
    end

    entry({'admin', 'services', 'zdm-dailybonus'}, alias('admin', 'services', 'zdm-dailybonus', 'setting'), _('ZDM Daily Bonus'), 11).dependent = true -- Menu item
    entry({'admin', 'services', 'zdm-dailybonus', 'setting'}, cbi('zdm-dailybonus/setting', {hidesavebtn = true, hideresetbtn = true}), _('Setting'), 10).leaf = true -- Setting page
    entry({'admin', 'services', 'zdm-dailybonus', 'log'}, form('zdm-dailybonus/log'), _('Log'), 30).leaf = true -- Log page
    entry({'admin', 'services', 'zdm-dailybonus', 'run'}, call('run')) -- Run action
    entry({'admin', 'services', 'zdm-dailybonus', 'qrcode'}, call('qrcode')) -- get qrcode
    entry({'admin', 'services', 'zdm-dailybonus', 'check_login'}, call('check_login')) -- check login
    entry({'admin', 'services', 'zdm-dailybonus', 'realtime_log'}, call('get_log')) -- get realtime log
end

-- run
function run()
    local running = luci.sys.call("busybox ps -w | grep zdm-dailybonus | grep -v grep >/dev/null") == 0
    if not running then
        luci.sys.call('sh /usr/share/zdm-dailybonus/app.sh -r')
    end
    luci.http.write('')
end

local User_Agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'
local Accept='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
local Accept_Language='Accept-Language: zh-CN,zh;q=0.9'
local tmp_cookie='/tmp/zdm-cookie'
local tmp_login='/tmp/zdm-login'
local zdm_login = 'http://www.zuidaima.com/user/weixin/login.htm'
local zdm_bind = 'http://www.zuidaima.com/user/weixin/bind_query_ticket.htm'
local zdm_home = 'http://www.zuidaima.com/'

-- qrcode
function qrcode()
    luci.sys.exec("wget-ssl --header='"..Accept.."' --header='"..Accept_Language.."' --referer='"..zdm_home.."' --user-agent='"..User_Agent.."' --load-cookies="..tmp_cookie.." --save-cookies="..tmp_cookie.." --keep-session-cookies -q -O - '"..zdm_login.."' > "..tmp_login)
    local img_data = luci.sys.exec("echo -n $(cat "..tmp_login.." | grep -oE 'data:image(.*)\" width=' | sed -r 's/.{8}$//')")
    local ticket = luci.sys.exec("echo -n $(cat "..tmp_login.." | sed -nr \"s/.*bind_weixin_query_ticket\\(\\\"(.*)\\\")'.*/\\1/p\")")
    local return_json = {
        qrcode_data = img_data,
        ticket = ticket
    }
    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

-- check_login
function check_login()
    local data = luci.http.formvalue()
    local response = luci.sys.exec("echo -n $(wget-ssl --header='"..Accept.."' --header='"..Accept_Language.."' --referer='"..zdm_login.."' --user-agent='"..User_Agent.."' --load-cookies="..tmp_cookie.." --save-cookies="..tmp_cookie.." --keep-session-cookies -q -O - '"..zdm_bind.."?ticket="..data.ticket.."&_="..os.time().."')")
    local return_json = {
        response = response,
        code = tonumber(luci.sys.exec("echo -n $(echo \'"..response.."\' | sed -nr 's/.*code\\\":(.*),.*/\\1/p')")),
        msg = luci.sys.exec("echo -n $(echo \'"..response.."\' | sed -nr 's/.*msg\\\":\\\"(.*)\\\"./\\1/p')"),
    }
    if return_json.code == 0 then
        local guid = luci.sys.exec("echo -n $(cat "..tmp_cookie.." | grep zdmid | awk '{print $7}')")
        return_json.cookie = 'zdmid=' .. guid .. ';'
    end

    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

-- get_log
function get_log()
    local fs = require "nixio.fs"
    local e = {}
    e.running = luci.sys.call("busybox ps -w | grep zdm-dailybonus | grep -v grep >/dev/null") == 0
    e.log = fs.readfile("/var/log/zdm-dailybonus.log") or ""
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
