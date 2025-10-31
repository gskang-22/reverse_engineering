#!/bin/sh
# File name: backup_recover_files.sh
# Description: This script used for backup and recover files.
#   This file referenced by configfs.sh data_guardian.sh and recoverOnce.sh.
#   This is part of UBIFS enhancement, after UBIFS crashed, recover the key files.
# Notice: If logs and configs crashed at the same time, the files cannot be recoverd.
# Author: xinpeng.cao@alcatel-sbell.com.cn
# History: 2016/4/25 Create file.
# 2016/09/26 ALU02276898 encrypted db files did not backup,add new db files to backup list(
#          2016/9/27 Add /configs/updtate_precfg_xml /configs/cfgmgr_cli_back.conf
# /configs/config_encryption.cfg,/configs/config_encryption.cfg.bak,/configs/precfg_remote_encryption.xml
# /configs/cfg_update_remote_encryption.kv)

source /usr/exe/defset.as
#Note: the $BAK_DIR should match the define in configfs.sh and cfgmgr, don't change!
BAK_DIR=/logs/configs_key_data_bak

#Static files only backup once after boot up.
BAK_STATIC_FILE_LIST="$(cat $USR_CFG_DIR/backup.outset)"

#Dynamic files backup periodically, every 1 hour.
BAK_DYNAMIC_FILE_LIST="$(cat $USR_CFG_DIR/backup.cyclic)"

#Return value
EINVAL=-1 #Invalid argument
EERROR=-2 #Error occured.

backup_prepare()
{
    #check BAK_DIR
    if [ ! -x ${BAK_DIR} ]
    then
        mkdir -p ${BAK_DIR};
    fi

    #check BAK_STATIC_FILE_LIST and BAK_DYNAMIC_FILE_LIST
    if [ "${BAK_STATIC_FILE_LIST}" == "" ]
    then
        return ${EINVAL};
    fi

    if [ "${BAK_DYNAMIC_FILE_LIST}" == "" ]
    then
        return ${EINVAL};
    fi

    return 0;
}

#This function need 1 parameter, the parameter is the file absolute path.
#backup /configs/config.cfg to /logs/configs_key_data_bak/config.cfg
#backup /configs/bosa/bosa.cfg to /logs/configs_key_data_bak/bosa/bosa.cfg
backup_file()
{
    #check file time stamp and backup file
    if [ $# != 1 ]
    then
        return ${EINVAL};
    fi

    src=$1
    dst=${BAK_DIR}/${src#/*/}    #${src#/*/} delete the first dir info, from /configs/bosa/bosa.cfg to bosa/bosa.cfg

    #check dir exist or not
    if [ ! -e ${src} ]
    then
        return 0;
    fi

    dir=$(dirname ${dst});
    if [ ! -e ${dir} ]
    then
        mkdir -p ${dir};
    fi

    if [ ! -e ${dst} ]
    then
        cp -rf ${src} ${dst};
    else
        if [ "${src}" -nt "${dst}" ]
        then
            cp -rf ${src} ${dst};
        fi
    fi

    return 0;
}

#This function need 1 parameter, the parameter is the dir absolute path.
#backup /configs/alcatel to /logs/configs_key_data_bak/alcatel
#backup /configs/bosa to /logs/configs_key_data_bak/bosa
backup_dir()
{
    #check file time stamp and backup file
    if [ $# != 1 ]
    then
        return ${EINVAL}
    fi

    src=$1

    #check dir exist or not
    if [ ! -e ${src} ]
    then
        return 0;
    fi
    
    cp -rf ${src} ${BAK_DIR}/

    return 0;
}

backup()
{
    if [ $# != 1 ]
    then
        return ${EINVAL}
    fi

    var=$1
    if [ ! -e ${var} ]
    then
        return 0;
    fi

    if [ -d ${var} ]
    then
        backup_dir ${var}
    elif [ -f ${var} ]
    then
        backup_file ${var}
    fi

    return 0;
}

backup_dynamic_files()
{
    backup_prepare
    if [ $? != 0 ]
    then
        echo "backup_prepare failed return:$?"
        return ${EERROR}
    fi

    #backup files
    for var in ${BAK_DYNAMIC_FILE_LIST}; do
        #if backup does not exist or out of date, update
        backup ${var}
    done

    return 0;
}

backup_static_files()
{
    backup_prepare
    #backup files
    for var in ${BAK_STATIC_FILE_LIST}; do
        backup ${var}
    done

    return 0;
}
