#!/bin/sh

source /usr/exe/defset.as
echo "[`date -u '+%F %T'`]MSG: superd factory reset ...." |tee -a /logs/${LOGDEFAULT}
if [ -f /configs/restore_default_flag ]; then
    echo 1 > /configs/restore_default_flag
fi

rm -rf /logs/*
rm -rf /configs/etc/*
rm -rf /configs/confignew.cfg*
rm -rf /configs/config.cfg*
rm -rf /configs/config_encryption.cfg*
rm -rf /configs/hgu_slid
rm -rf /configs/hgu_loginid
rm -rf /configs/precfg_remote_flag
rm -rf /configs/precfg_remote_avalible
rm -rf /configs/precfg_remote_encryption.xml
rm -rf /configs/precfg_remote.xml
rm -rf /configs/cfg_update_remote_avalible
rm -rf /configs/cfg_update_remote_encryption.kv
rm -rf /configs/configs/cfg_update_remote.kv

echo "[`date -u '+%F %T'`]MSG: superd factory reset done" |tee -a /logs/${LOGDEFAULT}
sync

