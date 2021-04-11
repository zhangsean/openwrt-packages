#!/bin/sh
#
# Copyright (C) 2020 luci-app-zdm-dailybonus <jerrykuku@qq.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
# 501 下载脚本出错
# 101 没有新版本无需更新
# 0   更新成功

NAME=zdm-dailybonus
LOG_FILE=/var/log/zdm-dailybonus.log
CRON_FILE=/etc/crontabs/root
ZDM_CREATE=http://www.zuidaima.com/mood/create.htm
ZDM_HOME=http://www.zuidaima.com/

usage() {
    cat <<-EOF
		Usage: app.sh [options]
		Valid options are:

		    -a                      Add Cron
		    -n                      Check
		    -r                      Run Script
		    -u                      Update Script From Server
		    -s                      Save Cookie And Add Cron
		    -w                      Background Run With Wechat Message
		    -h                      Help
EOF
    exit $1
}

# Common functions

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}

add_cron() {
    sed -i '/zdm-dailybonus/d' $CRON_FILE
    [ $(uci_get_by_type global auto_run 0) -eq 1 ] && echo $(uci_get_by_type global auto_run_time_m)' '$(uci_get_by_type global auto_run_time_h)' * * * sh /usr/share/zdm-dailybonus/app.sh -w' >>$CRON_FILE
    crontab $CRON_FILE
    /etc/init.d/cron restart
}

# Run Script

notify() {
    title="$(date '+%Y年%m月%d日') 最代码签到"
    grep "Cookie失效" ${LOG_FILE} >/dev/null
    if [ $? -eq 0 ]; then
        desc="Cookie 已失效"
    else
        desc=$(cat ${LOG_FILE} | grep -oE '共有(\d+)牛币')
    fi
    #serverchan
    sckey=$(uci_get_by_type global serverchan)
    if [ ! -z $sckey ]; then
        serverurlflag=$(uci_get_by_type global serverurl)
        serverurl=https://sc.ftqq.com/
        if [ "$serverurlflag" = "sct" ]; then
            serverurl=https://sctapi.ftqq.com/
        fi
        wget-ssl -q --output-document=/dev/null --post-data="text=$title~&desp=$desc" $serverurl$sckey.send
    fi

    #Dingding
    dtoken=$(uci_get_by_type global dd_token)
    if [ ! -z $dtoken ]; then
        DTJ_FILE=/tmp/zdm-djson.json
        echo "{\"msgtype\": \"markdown\",\"markdown\": {\"title\":\"${title}\",\"text\":\"### ${title}\n ${desc}\"}}" > ${DTJ_FILE}
        wget-ssl -q --output-document=/dev/null --header="Content-Type: application/json" --post-file=$DTJ_FILE "https://oapi.dingtalk.com/robot/send?access_token=${dtoken}"
    fi

    #telegram
    TG_BOT_TOKEN=$(uci_get_by_type global tg_token)
    TG_USER_ID=$(uci_get_by_type global tg_userid)
    API_URL="https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
    if [ ! -z $TG_BOT_TOKEN ] && [ ! -z $TG_USER_ID ]; then
        text="*$title*

\`\`\`
"$desc"
===============================
本消息来自最代码签到插件 zdm-dailybonus
\`\`\`"
        wget-ssl -q --output-document=/dev/null --post-data="chat_id=$TG_USER_ID&text=$text&parse_mode=markdownv2" $API_URL
    fi
}

run() {
    echo -e $(date '+%Y-%m-%d %H:%M:%S %A') >$LOG_FILE 2>/dev/null
    COOKIE=$(uci_get_by_type global Cookies)
    echo "Cookie: $COOKIE" >>$LOG_FILE 2>/dev/null
    SIGN_TEXT=$(uci_get_by_type global sign_text)
    echo "SIGN_TEXT: $SIGN_TEXT" >>$LOG_FILE 2>/dev/null
    curl -i "$ZDM_CREATE" \
        -H 'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryuZieHHYBAjr3r4Jc' \
        -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36' \
        -H "Referer: $ZDM_HOME" \
        -H "Cookie: $COOKIE" \
        --data-raw $'------WebKitFormBoundaryuZieHHYBAjr3r4Jc\r\nContent-Disposition: form-data; name="rdm"\r\n\r\n8ozHCudgul\r\n------WebKitFormBoundaryuZieHHYBAjr3r4Jc\r\nContent-Disposition: form-data; name="content"\r\n\r\n签到打卡\r\n------WebKitFormBoundaryuZieHHYBAjr3r4Jc\r\nContent-Disposition: form-data; name="file"; filename=""\r\nContent-Type: application/octet-stream\r\n\r\n\r\n------WebKitFormBoundaryuZieHHYBAjr3r4Jc--\r\n' \
        --insecure >>$LOG_FILE
    curl -i "$ZDM_HOME" \
        -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36' \
        -H "Referer: $ZDM_CREATE" \
        -H "Cookie: $COOKIE" \
        --insecure | grep -oE '共有(\d+)牛币' >>$LOG_FILE 2>/dev/null
    if [ $? -gt 0 ]; then
        echo "Cookie失效" >>$LOG_FILE 2>/dev/null
    fi
    notify &
    echo "The End" >>$LOG_FILE 2>/dev/null
}

save() {
    lua /usr/share/zdm-dailybonus/gen_cookieset.lua
    add_cron
}

while getopts ":alnruswh" arg; do
    case "$arg" in
    a)
        add_cron
        exit 0
        ;;
    l)
        notify
        exit 0
        ;;
    r)
        run
        exit 0
        ;;
    s)
        save
        exit 0
        ;;
    w)
        run
        exit 0
        ;;
    h)
        usage 0
        ;;
    esac
done
