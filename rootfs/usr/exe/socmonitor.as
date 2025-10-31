#!/bin/sh
## SoC monitor daemon, especailly for temperature monitor
source /usr/exe/defset.as

SOC_TEMP_TOP=125
SOC_TEMP_PRO=/sys/power/bpcm/select0
if [ ! -e $SOC_TEMP_PRO ]; then
    "[`date -u '+%F %T'`]MSG: SoC no temperature integrated" |tee -a /logs/${LOGDEFAULT}
    exit
fi

SOC_TEMP_NUM=$(grep DieTemp $SOC_TEMP_PRO|cut -d: -f2|cut -d. -f1|sed "s/[ \t]//g")
echo "[`date -u '+%F %T'`]MSG: SoC temperature is $SOC_TEMP_NUM @ $(date '+%F %T')" |tee -a /logs/${LOGDEFAULT}
while true
do
    SOC_TEMP_NUM=$(grep DieTemp $SOC_TEMP_PRO|cut -d: -f2|cut -d. -f1|sed "s/[ \t]//g")
    if [ "$SOC_TEMP_NUM" -ge $SOC_TEMP_TOP ]; then
        echo "[`date -u '+%F %T'`]MSG: SoC temperature is $SOC_TEMP_NUM @ $(date '+%F %T')" |tee -a /logs/${LOGDEFAULT}
        echo "[`date -u '+%F %T'`]MSG: SoC temperarure is over the threshold $SOC_TEMP_TOP, rebooting ..." |tee -a /logs/${LOGDEFAULT}
        reboot
        exit
    fi
    sleep 5
done

