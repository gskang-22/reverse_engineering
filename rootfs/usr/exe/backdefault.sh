#!/bin/sh
## back to factory-default process, with uplayer compatible /flash folder
source $USR_EXE_DIR/logset.as
META_EXTRAS=/usr/cfg/meta.extras
META_CUSTOM=/usr/cfg/meta.custom
META_VENDOR=/usr/cfg/meta.vendor

revert_flashport()
{
    if grep -q "\<datafs\>" /proc/mtd || grep -q "\<data\>" /proc/mtd; then
        return
    fi

    # only for no datafs partition
    loop=0; MAXTRY=32
    while mount |grep -q "\<flash\>"
    do
        umount -ldrf /flash
        loop=$(($loop + 1))
        if [ $loop -ge $MAXTRY ]; then
            echo "[`date -u '+%F %T'`]MSG: umount -ldrf /flash exceed $loop times" |tee -a /tmp/${LOGDEFAULT}
            return
        fi
        usleep 200
    done
    echo "[`date -u '+%F %T'`]MSG: umount -ldrf /flash reach $loop times" |tee -a /tmp/${LOGDEFAULT}
}

regain_flashport()
{
    if grep -q "\<datafs\>" /proc/mtd || grep -q "\<data\>" /proc/mtd; then
        return
    fi

    # only for no datafs partition
    revert_flashport
    mkdir -p /logs/flash
    mount /logs/flash /flash
}

format_partition()
{
    echo "[`date -u '+%F %T'`]MSG: format partition $* ...." |tee -a /tmp/${LOGDEFAULT}
    if grep -q "\<datafs\>" /proc/mtd || grep -q "\<data\>" /proc/mtd; then
        echo "datafs exist"
        else
        if [ "X$1" = "Xlogs" ]; then
            ls -a /logs/ | grep -v '^flash$' | grep -v '^\.$' | grep -v '^\.\.$' | awk '{print "\/logs/"$1""}' | xargs rm -rf
            sync
            echo "[`date -u '+%F %T'`]MSG: format partition $* done" |tee -a /tmp/${LOGDEFAULT}
            if [ "X$1" = "Xconfigs" ]; then
                source /bcm/script/first_boot.sh
            fi
            return
        fi
    fi
    if [ "X$2" = "Xforce" ]; then
        if [ "X$1" = "Xconfigs" ]; then
            if grep "\<cfgfs\>" /proc/mtd; then
                ubi_part=cfgfs
            else
                ubi_part=cfg
            fi
            ubi_port=/configs
        fi

        if [ "X$1" = "Xlogs" ]; then
            if grep "\<logfs\>" /proc/mtd; then
                ubi_part=logfs
            else
                ubi_part=log
            fi
            ubi_port=/logs
        fi

        echo "depth format $1 ..."
        ubi_part_id=$(cat /proc/mtd |grep ${ubi_part} | head -n 1 | cut -d: -f1 |cut -c4-)
        echo "CMD: umount ${ubi_port}"
        umount -l ${ubi_port} &>/dev/null
        echo "CMD: $UBIDETACH $UBIDEVCTL -m ${ubi_part_id}"
        $UBIDETACH $UBIDEVCTL -m ${ubi_part_id} &>/dev/null
        echo "CMD: $UBIFORMAT /dev/mtd${ubi_part_id} -y"
        $UBIFORMAT /dev/mtd${ubi_part_id} -y &>/dev/null
        echo "CMD: $UBIATTACH $UBIDEVCTL -m ${ubi_part_id} -d ${ubi_part_id}"
        ubi_part_info=$($UBIATTACH $UBIDEVCTL -m ${ubi_part_id} -d ${ubi_part_id} 2>/dev/null)
        ubi_part_lebs=$(echo "${ubi_part_info}" |sed "s/^.*\(total\)\(.*\)\(LEBs\).*\(available\).*/\2/" |sed "s/[ \t\n]//g")
        ubi_part_aleb=$(echo "${ubi_part_info}" |sed "s/^.*\(available\)\(.*\)\(LEBs\).*/\2/" |sed "s/[ \t\n]//g")
        ubi_lebs_size=$(echo "${ubi_part_info}" |sed "s/^.*\(LEB size\).*\(bytes (\)\(.*\)\( KiB\).*/\3/" |sed "s/[ \t\n]//g" |cut -d. -f1)
        echo "MSG: ${ubi_part_info}"
        echo "MSG: ubi_part=${ubi_part} ubi_part_lebs=${ubi_part_lebs} ubi_part_aleb=${ubi_part_aleb}"
        ## Volume Size = Total - Total/32(Reserved for BEB) - 4(Reserved for Volume)
        ## ubi_part_aleb=$((${ubi_part_aleb} - 4)) ## Reserved only for more tolerance
        ubi_vols_lebs=$((${ubi_part_lebs} * 31 / 32 - 4))
        if [ ${ubi_part_aleb} -lt ${ubi_vols_lebs} ]; then ubi_vols_lebs=${ubi_part_aleb}; fi
        ubi_vols_size=$((${ubi_vols_lebs} * ${ubi_lebs_size}))
        echo "MSG: ubi_part=${ubi_part} ubi_vols_lebs=${ubi_vols_lebs} ubi_lebs_size=${ubi_lebs_size} ubi_vols_size=${ubi_vols_size}"
        mdev -s &>/dev/null

        ## try to make volume for the ${ubi_part}
        echo "CMD: $UBIMKVOL /dev/ubi${ubi_part_id} -t dynamic -n 0 -N ${ubi_part} -s ${ubi_vols_size}KiB"
        $UBIMKVOL /dev/ubi${ubi_part_id} -t dynamic -n 0 -N ${ubi_part} -s ${ubi_vols_size}KiB &>/dev/null
        if [ $? != 0 ]; then reboot; fi    #reboot and try again
        mdev -s &>/dev/null

        ## try to mount the ${ubi_part}
        echo "CMD: mount -t ubifs /dev/ubi${ubi_part_id}_0 ${ubi_port}"
        mount -t ubifs /dev/ubi${ubi_part_id}_0 ${ubi_port} &>/dev/null
    else
        rm -rf /$1/*
        sync
    fi

    echo "[`date -u '+%F %T'`]MSG: format partition $* done" |tee -a /tmp/${LOGDEFAULT}
    if [ "X$1" = "Xconfigs" ]; then
        source /bcm/script/first_boot.sh
    fi
}

backup_files()
{
    if [ "X$1" = "Xlogs" ] && [ "X$2" = "Xconfigs" ]; then
        srcdir=/logs/configs_key_data_bak
        dstdir=/configs
    elif [ "X$1" = "Xconfigs" ] && [ "X$2" = "Xlogs" ]; then
        srcdir=/configs
        dstdir=/logs/configs_key_data_bak
    else
        exit 1
    fi

    mkdir /logs/configs_key_data_bak &>/dev/null
    echo "[`date -u '+%F %T'`]MSG: backup ${srcdir} to ${dstdir} $3 ...." |tee -a /tmp/${LOGDEFAULT}
    while read LINE
    do
        line=$(echo $LINE |sed "s/#.*$//g")
        if [ -z "$(echo $line |sed 's/[ \t]//g')" ]; then
            continue
        elif [ -e "${srcdir}/$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')" ]; then
            echo "[`date -u '+%F %T'`]MSG: backup ${line} ..." |tee -a /tmp/${LOGDEFAULT}
	    cp -af "${srcdir}/$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')" ${dstdir}
        fi
    done < $META_VENDOR

    if [ "X$3" != "Xdepth" ]; then
        while read LINE
        do
            line=$(echo $LINE |sed "s/#.*$//g")
            if [ -z "$(echo $line |sed 's/[ \t]//g')" ]; then
                continue
            elif [ -e "${srcdir}/$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')" ]; then
                echo "[`date -u '+%F %T'`]MSG: backup ${line} ..." |tee -a /tmp/${LOGDEFAULT}
	        cp -af "${srcdir}/$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')" ${dstdir}
            fi
        done < $META_CUSTOM
    fi
    sync
    echo "[`date -u '+%F %T'`]MSG: backup ${srcdir} to ${dstdir} $3 done" |tee -a /tmp/${LOGDEFAULT}
}

delete_extra_list()
{
    if [ ! -f $META_EXTRAS ]; then return; fi
    while read LINE
    do
        line=$(echo $LINE |sed "s/#.*$//g")
	if [ -z "$(echo $line |sed 's/[ \t]//g')" ]; then
            continue
	elif [ -e "$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')" ]; then
	    echo "[`date -u '+%F %T'`]MSG: remove $line ..." |tee -a /tmp/${LOGDEFAULT}
            rm -rf "$(echo $line |sed 's/^[ \t]*//g'|sed 's/[ \t]*$//g')"
        fi
    done < $META_EXTRAS
    sync
}

default_logs2tmp
ontType=`cat /usr/etc/buildinfo | grep ONT_TYPE | cut -c10-`
if [ "${ontType}" = "g010ga" ] || [ "${ontType}" = "g010pa" ]; then
    ls -A /configs > /tmp/remove.lst
    if [ -f /configs/flag.factory-default.dep ]; then
        echo "[`date -u '+%F %T'`]MSG: factory-default.dep ...." |tee -a /tmp/${LOGDEFAULT}
        while read line
        do
            grep "\<${line}\>" $META_VENDOR || rm -rf /configs/${line}
        done < /tmp/remove.lst
        echo "[`date -u '+%F %T'`]MSG: factory-default.dep done ...." |tee -a /tmp/${LOGDEFAULT}
    elif [ -f /configs/flag.factory-default ]; then
        echo "[`date -u '+%F %T'`]MSG: factory-default ...." |tee -a /tmp/${LOGDEFAULT}
        while read line
        do
            grep "\<${line}\>" $META_VENDOR || grep "\<${line}\>" $META_CUSTOM || rm -rf /configs/${line}
        done < /tmp/remove.lst
        echo "[`date -u '+%F %T'`]MSG: factory-default done ...." |tee -a /tmp/${LOGDEFAULT}
    fi

    default_tmp2logs
    rm -rf /tmp/remove.lst
    sync
    exit
fi

if [ -f /configs/flag.factory-default* -o -f /logs/flag.factory-default* ]; then
    echo "[`date -u '+%F %T'`]MSG: remove the $(basename $META_EXTRAS) content ...." |tee -a /tmp/${LOGDEFAULT}
    regain_flashport
    delete_extra_list
    echo "[`date -u '+%F %T'`]MSG: remove the $(basename $META_EXTRAS) content done" |tee -a /tmp/${LOGDEFAULT}
fi

## release /flash port before factory-default process
revert_flashport

if [ -f /configs/flag.factory-default.dep ]; then
    echo "[`date -u '+%F %T'`]MSG: factory-default.dep ...." |tee -a /tmp/${LOGDEFAULT}
    rm -rf /configs/flag.factory-default /configs/flag.format /configs/flag.backup*
    format_partition logs force
    backup_files configs logs depth
    touch /logs/flag.format
    touch /logs/flag.backup.dep
    echo "[`date -u '+%F %T'`]MSG: factory-default.dep done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

if [ -f /configs/flag.factory-default ]; then
    echo "[`date -u '+%F %T'`]MSG: factory-default ...." |tee -a /tmp/${LOGDEFAULT}
    rm -rf /configs/flag.format /configs/flag.backup*
    format_partition logs
    backup_files configs logs
    touch /logs/flag.format
    touch /logs/flag.backup
    echo "[`date -u '+%F %T'`]MSG: factory-default done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

if [ -f /logs/flag.factory-default.dep ]; then
    echo "[`date -u '+%F %T'`]MSG: factory-default.dep in logs ...." |tee -a /tmp/${LOGDEFAULT}
    rm -rf /logs/flag.factory-default /logs/flag.format /logs/flag.backup*
    backup_files configs logs depth
    format_partition configs force
    backup_files logs configs depth
    touch /configs/flag.format
    touch /configs/flag.backup.dep
    echo "[`date -u '+%F %T'`]MSG: factory-default.dep in logs done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

if [ -f /logs/flag.factory-default ]; then
    echo "[`date -u '+%F %T'`]MSG: factory-default in logs ...." |tee -a /tmp/${LOGDEFAULT}
    rm -rf /logs.format /logs/flag.backup*
    backup_files configs logs
    format_partition configs
    backup_files logs configs
    touch /configs/flag.format
    touch /configs/flag.backup
    echo "[`date -u '+%F %T'`]MSG: factory-default in logs done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

if [ -f /configs/flag.format ]; then
    echo "[`date -u '+%F %T'`]MSG: flag.format ...." |tee -a /tmp/${LOGDEFAULT}
    if [ ! -f /configs/flag.backup ] && [ ! -f /configs/flag.backup.dep ]; then
        touch /configs/flag.backup
    fi

    if [ -f /configs/flag.backup ]; then
        format_partition logs
        backup_files configs logs
        rm -rf /configs/flag.backup
    else
        format_partition logs force
        backup_files configs logs depth
        rm -rf /configs/flag.backup.dep
    fi

    rm -rf /configs/flag.format
    echo "[`date -u '+%F %T'`]MSG: flag.format done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

if [ -f /logs/flag.format ]; then
    echo "[`date -u '+%F %T'`]MSG: flag.format in logs ...." |tee -a /tmp/${LOGDEFAULT}
    if [ ! -f /logs/flag.backup ] && [ ! -f /logs/flag.backup.dep ]; then
        touch /logs/flag.backup
    fi

    if [ -f /logs/flag.backup ]; then
        format_partition configs
        backup_files logs configs
        rm -rf /logs/flag.backup
    else
        format_partition configs force
        backup_files logs configs depth
        rm -rf /logs/flag.backup.dep
    fi

    rm -rf /logs/flag.format
    echo "[`date -u '+%F %T'`]MSG: flag.format in logs done" |tee -a /tmp/${LOGDEFAULT}
    sync
fi

## recover /flash port after factory-default process
regain_flashport

## default logs setup
default_tmp2logs

