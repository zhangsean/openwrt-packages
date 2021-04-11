-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module('luci.controller.zdm-dailybonus', package.seeall)
function index()
    if not nixio.fs.access('/etc/config/zdm-dailybonus') then
        return
    end

    entry({'admin', 'services', 'zdm-dailybonus'}, alias('admin', 'services', 'zdm-dailybonus', 'setting'), _('最代码签到'), 11).dependent = true -- 首页
    entry({'admin', 'services', 'zdm-dailybonus', 'setting'}, cbi('zdm-dailybonus/setting', {hidesavebtn = true, hideresetbtn = true}), _('设置'), 10).leaf = true -- 基本设置
    entry({'admin', 'services', 'zdm-dailybonus', 'log'}, form('zdm-dailybonus/log'), _('日志'), 30).leaf = true -- 日志页面
    entry({'admin', 'services', 'zdm-dailybonus', 'run'}, call('run')) -- 执行程序
    entry({'admin', 'services', 'zdm-dailybonus', 'qrcode'}, call('qrcode')) -- 获取二维码
    entry({'admin', 'services', 'zdm-dailybonus', 'check_login'}, call('check_login')) -- 检测登录
    entry({'admin', 'services', 'zdm-dailybonus', 'realtime_log'}, call('get_log')) -- 获取实时日志
end

-- 执行程序
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
local cookie='/tmp/zdm_cookie'
local zdm_login = 'http://www.zuidaima.com/user/weixin/login.htm'
local zdm_home = 'http://www.zuidaima.com/'

--获取二维码
function qrcode()
    local response = luci.sys.exec("echo -n $(wget-ssl --header='"..Accept.."' --header='"..Accept_Language.."' --referer='"..zdm_home.."' --user-agent='"..User_Agent.."' --load-cookies="..cookie.." --save-cookies="..cookie.." --keep-session-cookies -q -O - '"..zdm_login.."')")
    local img = luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '<img src=\"data:(.+?)\"' | awk -F \\\" '{print $4}')")
    local return_json = {
        img_data = img
    }
    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

--检测登录
function check_login()
    local data = luci.http.formvalue()
    local response = luci.sys.exec("echo -n $(wget-ssl --header='"..Accept.."' --header='"..Accept_Language.."' --referer='"..zdm_login.."' --user-agent='"..User_Agent.."' --load-cookies="..cookie.." --save-cookies="..cookie.." --keep-session-cookies -q -O - '"..zdm_home.."')")
    local return_json = {
        error = tonumber(luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '\"errcode\":(\\d+)' | awk -F : '{print $2}')")),
        msg = luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '\"message\":\"(.+?)\"' | awk -F \\\" '{print $4}')"),
    }
    if return_json.error == 0 then
        local guid = luci.sys.exec("echo -n $(cat "..cookie.." | grep pt_key | awk '{print $7}')")
        return_json.cookie = 'zdmid=' .. guid .. ';'
    end

    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

--获取实时日志
function get_log()
    local fs = require "nixio.fs"
    local e = {}
    e.running = luci.sys.call("busybox ps -w | grep zdm-dailybonus | grep -v grep >/dev/null") == 0
    e.log = fs.readfile("/var/log/zdm-dailybonus.log") or ""
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
