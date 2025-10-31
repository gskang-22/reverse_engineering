#!/bin/sh
## startupdone helper, for triggering those daemon and/or process while the cfgmgr ready
source /usr/exe/defset.as

while read LINE
do
    line=$(echo $LINE |sed "s/#.*$//g")
    if [ -z "$(echo $line |sed 's/[ \t]//g')" ]; then
        continue
    elif [ -e "$(echo $line |cut -d " " -f1)" ]; then
        echo "[`date -u '+%F %T'`]MSG: tigger $line ..." |tee -a /logs/${LOGDEFAULT}
        $line &
    fi
done < /usr/cfg/startuphelper.cfg

