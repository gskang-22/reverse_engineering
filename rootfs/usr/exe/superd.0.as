#!/bin/sh

source /usr/exe/defset.as
echo "[`date -u '+%F %T'`]MSG: superd factory reset with key params ...." |tee -a /logs/${LOGDEFAULT}
if [ -f /configs/restore_default_flag ]; then
    echo 1 > /configs/restore_default_flag
fi

rm -rf /configs/etc/*
rm -rf /configs/confignew.cfg*
rm -rf /configs/config.cfg*
rm -rf /configs/config_encryption.cfg*

echo "[`date -u '+%F %T'`]MSG: superd factory reset with key params done" |tee -a /logs/${LOGDEFAULT}
sync

