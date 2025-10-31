#!/bin/sh

source $USR_EXE_DIR/logset.as
echo "[`date -u '+%F %T'`]MSG: system starting" |tee -a /tmp/${LOGDEFAULT}
UBI_MAP_LIST="logfs:0:/logs cfgfs:0:/configs datafs:0:/flash log:0:/logs cfg:1:/configs data:0:/flash"
for ubi_map in ${UBI_MAP_LIST}
do
  ubi_part=$(echo "${ubi_map}" |cut -d: -f1)
  ubi_seed=$(echo "${ubi_map}" |cut -d: -f2)
  ubi_port=$(echo "${ubi_map}" |cut -d: -f3)
  echo "MSG: ubi_part=${ubi_part} ubi_port=${ubi_port}"
  if grep -q "\<${ubi_part}\>" /proc/mtd; then
    ubi_part_id=$(cat /proc/mtd |grep "\<${ubi_part}\>"|head -n 1 |cut -d: -f1 |cut -c4-)
    echo "CMD: $UBIATTACH $UBIDEVCTL -m ${ubi_part_id} -d ${ubi_part_id}"
    $UBIATTACH $UBIDEVCTL -m ${ubi_part_id} -d ${ubi_part_id} &>/dev/null
    mdev -s &>/dev/null

    ## try to mount the ${ubi_part} to the ${ubi_port}
    echo "CMD: mount -t ubifs /dev/ubi${ubi_part_id}_${ubi_seed} ${ubi_port}"
    mount -t ubifs /dev/ubi${ubi_part_id}_${ubi_seed} ${ubi_port} &>/dev/null
    ubi_err=$?
    echo "MSG: mount /dev/ubi${ubi_part_id}_${ubi_seed} ${ubi_port} with ubi_err=${ubi_err}"
    if [ "${ubi_err}" != "0" -a "${ubi_seed}" != "0" ]; then
      mount -t ubifs /dev/ubi${ubi_part_id}_0 ${ubi_port} &>/dev/null
      ubi_err=$?
      echo "MSG: mount /dev/ubi${ubi_part_id}_${ubi_seed} ${ubi_port} with ubi_err=${ubi_err}"
    fi
    ## check the mount ${ubi_port} size
    ubi_size=$(df -k |grep "\<ubi${ubi_part_id}_[012]\>" |sed "s/[ \t]*/:/g"|cut -d: -f3)
    echo "MSG: ${ubi_port} size is ${ubi_size}KB"
    if [ "0${ubi_size}" -lt 768 ]; then ubi_err=$((${ubi_err} + 1)); fi

    ## try to touch/write the mounted folder ${ubi_port}
    touch ${ubi_port}/${TAGUBIFSWR}
    ubi_err=$((${ubi_err} + $?))
    echo "MSG: touch ${ubi_port}/${TAGUBIFSWR} with ubi_err=${ubi_err}"

    ## check whether here is any error to try to recover
    if [ ${ubi_err} != 0 ]; then
      echo "[`date -u '+%F %T'`]MSG: Partition ${ubi_part} is damaged! Try to recover ..." |tee -a /tmp/${LOGDEFAULT}
      echo "CMD: umount ${ubi_port}"
      umount -l ${ubi_port} &>/dev/null
      echo "CMD: $UBIDETACH $UBIDEVCTL -m ${ubi_part_id}"
      $UBIDETACH $UBIDEVCTL -m ${ubi_part_id} &>/dev/null
      echo "CMD: $UBIFORMAT /dev/mtd${ubi_part_id} -y"
      $UBIFORMAT /dev/mtd${ubi_part_id} -y &>/dev/null
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
      echo "[`date -u '+%F %T'`]MSG: Partition ${ubi_part} is damaged! And auto recovered." |tee -a /tmp/${LOGDEFAULT}

      if [ "${ubi_port}" == "/configs" ]; then
        #set flag for recover data after mount /logs
        touch /tmp/configs_key_data
        #set first boot flag for recover other normal data.
        source /bcm/script/first_boot.sh
      fi
    fi
  fi
done

default_tmp2logs

