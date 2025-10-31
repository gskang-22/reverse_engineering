#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 
if [ $# -ne 3 ];then
    echo -n { \"ret\":11,\"msg\":\"insufficient parameters\"}
    exit 1
fi
cfg_file=/configs/config.cfg
bak_file=/mnt/$1/e8_Config_Backup/$2

if [ ! $3 -eq 1 ];then
    if [ -f $bak_file ] ;then
        echo -n { \"ret\":12,\"msg\":\"file exist\"}
        exit 1
    fi
fi

if [ ! -d /mnt/$1 ];then
    echo -n { \"ret\":15,\"msg\":\"error,partion not found\"}
fi

mkdir /mnt/$1/e8_Config_Backup

if [ -f $cfg_file ];then
    cp $cfg_file $bak_file >/dev/null 2>&1 && /bin/sync
    if [ $? -eq 0 ];then
        echo -n { \"ret\":0,\"msg\":\"backup done\"}
    else
        echo -n { \"ret\":14,\"msg\":\"error backup config file\"}
    fi
fi

