-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module('luci.controller.zdm-dailybonus', package.seeall)
function index()
    if not nixio.fs.access('/etc/config/zdm-dailybonus') then
        return
    end

    entry({'admin', 'services', 'zdm-dailybonus'}, alias('admin', 'services', 'zdm-dailybonus', 'client'), _('最代码签到'), 10).dependent = true -- 首页
    entry({'admin', 'services', 'zdm-dailybonus', 'client'}, cbi('zdm-dailybonus/client', {hidesavebtn = true, hideresetbtn = true}), _('设置'), 10).leaf = true -- 基本设置
    entry({'admin', 'services', 'zdm-dailybonus', 'log'}, form('zdm-dailybonus/log'), _('日志'), 30).leaf = true -- 日志页面
    entry({'admin', 'services', 'zdm-dailybonus', 'run'}, call('run')) -- 执行程序
    entry({'admin', 'services', 'zdm-dailybonus', 'qrcode'}, call('qrcode')) -- 获取二维码
    entry({'admin', 'services', 'zdm-dailybonus', 'check_login'}, call('check_login')) -- 获取二维码
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

--获取二维码
function qrcode()
    local url = 'http://www.zuidaima.com/user/weixin/login.htm'
    local referer = 'http://www.zuidaima.com/'
    local response = luci.sys.exec("echo -n $(wget-ssl --header='"..Accept.."' --header='"..Accept_Language.."' --referer='"..referer.."' --user-agent='"..User_Agent.."' --load-cookies="..cookie.." --save-cookies="..cookie.." --keep-session-cookies -q -O - '"..url.."')")
    local img = luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '<img src=\"data:(.+?)\"' | awk -F \\\" '{print $4}')")
    local ou_state = luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '\"ou_state\":(\\d+)' | awk -F : '{print $2}')")
    local okl_token = luci.sys.exec("echo -n $(cat "..cookie.." | grep okl_token | awk '{print $7}')")
    local return_json = {
        qrcode_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=' .. token,
        check_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=' .. token .. '&ou_state=' .. ou_state .. '&okl_token=' .. okl_token,
    }
    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

--检测登录
function check_login()
    local uci = luci.model.uci.cursor()
    local data = luci.http.formvalue()
    local post_data = 'lang=chs&appid=300&source=wq_passport&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=1100399130787&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action'
    local referer='https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state='
    local response = luci.sys.exec("echo -n $(wget-ssl --post-data='"..post_data.."' --header='"..Accept.."' --header='"..Accept_Language.."' --header='"..Host.."' --referer='"..referer.."' --user-agent='"..User_Agent.."' --load-cookies="..cookie.." --save-cookies="..cookie.." --keep-session-cookies -q -O - '"..data.check_url.."')")
    local return_json = {
        error = tonumber(luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '\"errcode\":(\\d+)' | awk -F : '{print $2}')")),
        msg = luci.sys.exec("echo -n $(echo \'"..response.."\' | grep -oE '\"message\":\"(.+?)\"' | awk -F \\\" '{print $4}')"),
    }
    if return_json.error == 0 then
        local pt_key = luci.sys.exec("echo -n $(cat "..cookie.." | grep pt_key | awk '{print $7}')")
        local pt_pin = luci.sys.exec("echo -n $(cat "..cookie.." | grep pt_pin | awk '{print $7}')")
        return_json.cookie = 'pt_key=' .. pt_key .. ';pt_pin=' .. pt_pin .. ';'
    end

    luci.http.prepare_content('application/json')
    luci.http.write_json(return_json)
end

function get_log()
    local fs = require "nixio.fs"
    local e = {}
    e.running = luci.sys.call("busybox ps -w | grep zdm-dailybonus | grep -v grep >/dev/null") == 0
    e.log = fs.readfile("/var/log/zdm-dailybonus.log") or ""
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
