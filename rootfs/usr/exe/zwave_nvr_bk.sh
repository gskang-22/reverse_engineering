#!/bin/sh
backup_dir=/configs/backup
backup_file=/configs/backup/z-wave_nvr.bk
nvrdata=/tmp/nvrdata_tmp

#get nvr data
zprog enable
zprog getnvr > $nvrdata
zprog disable

#get the backup nvr data
swac1=`cat $nvrdata | grep 0x0010 | awk '{printf $6}' |sed "s/0x//"`
echo $swac1
swac2=`cat $nvrdata | grep 0x0010 | awk '{printf $7}' |sed "s/0x//"`
echo $swac2
swac3=`cat $nvrdata | grep 0x0010 | awk '{printf $8}' |sed "s/0x//"`
echo $swac3
swab=`cat $nvrdata | grep 0x0010 | awk '{printf $9}' |sed "s/0x//"`
echo $swab
ccal=`cat $nvrdata | grep 0x0010 | awk '{printf $3}' |sed "s/0x//"`
echo $ccal
txcal1=`cat $nvrdata | grep 0x0030 | awk '{printf $3}' |sed "s/0x//"`
echo $txcal1
txcal2=`cat $nvrdata | grep 0x0030 | awk '{printf $4}' |sed "s/0x//"`
echo $txcal2
#create nvr dir
mkdir -p $backup_dir

#detect ONT type
region=`ritool get CountryID`
region=`echo $region | grep -i ":" | cut -d':' -f2 | /usr/bin/tr "A-Z" "a-z"`
echo "region: $region"

if [ "$region" == "eu" ]
then
	if [ "$swac1" != "0D" ] || [ "$swac2" != "1B" ] || [ "$swac3" != "78" ]; then
		swac1=0D
		swac2=1B
		swac3=78
		swab=20
		ccal=04
		txcal1=16
		txcal2=13
		touch ${backup_dir}/backup_zwnvr_default
	fi
elif [ "$region" == "us" ]
then
        if [ "$swac1" != "0D" ] || [ "$swac2" != "E8" ] || [ "$swac3" != "8C" ]; then
                swac1=0D
                swac2=E8
                swac3=8C
                swab=1B
                ccal=02
                txcal1=19
                txcal2=15
		touch ${backup_dir}/backup_zwnvr_default
        fi
elif [ "$region" == "au" ]
then
        if [ "$swac1" != "0E" ] || [ "$swac2" != "19" ] || [ "$swac3" != "60" ]; then
                swac1=0E
                swac2=19
                swac3=60
                swab=08
                ccal=FF
                txcal1=17
                txcal2=13
		touch ${backup_dir}/backup_zwnvr_default
        fi
else
	touch ${backup_dir}/not_exist_ZW_region
fi

#create the backup nvr data file
printf "\x""${swac1}""\x""${swac2}""\x""${swac3}""\x""${swab}""\x""${ccal}""\x""${txcal1}""\x""${txcal2}" >$backup_file
#remove the nvrdata file
rm -r $nvrdata
