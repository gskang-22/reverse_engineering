#!/bin/sh
CRASHCOUNTER=0
CFGCLICMD=$(which cfgcli)
test -z "$CFGCLICMD" && exit
source /usr/exe/defset.as

until cfgcli -t
do
    CRASHCOUNTER=$(($CRASHCOUNTER + 1))
    echo "[`date -u '+%F %T'`]MSG: cfgmgr crash or block $CRASHCOUNTER times" |tee -a /logs/${LOGDEFAULT}
    if [ $CRASHCOUNTER -ge 120 ]; then
        echo "[`date -u '+%F %T'`]MSG: cfgmgr crash or block $CRASHCOUNTER times, reboot ..." |tee -a /logs/${LOGDEFAULT}
        reboot
        exit
    fi
    sleep 5
done

echo "[`date -u '+%F %T'`]MSG: cfgmgr is working well" |tee -a /logs/${LOGDEFAULT}
touch /tmp/startupdone
sync

if [ -f /usr/exe/startuphelper.as ]; then
    sh /usr/exe/startuphelper.as
    echo "[`date -u '+%F %T'`]MSG: startupdone helper triggered" |tee -a /logs/${LOGDEFAULT}
fi

