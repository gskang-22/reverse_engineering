#!/bin/sh

WIFI_CALIB_FILE=""

#Wifi calibration file name keep same for
#HA-030W-B
HA030WB_WIFI_CALIB_FILE="bcm4363_map.bin|bcm43664_map.bin|bcmcmn_nvramvars.bin|bcm4363_nvramvars.bin|bcm43664_nvramvars.bin"

if [ "$ONT_TYPE"=="" ];then
	ONT_TYPE=`ritool get Mnemonic | cut -d: -f 2`
fi
echo "ONT_TYPE : $ONT_TYPE"

WIFI_CALIB_FILE=$HA030WB_WIFI_CALIB_FILE
echo "WIFI_CALIB_FILE : $WIFI_CALIB_FILE"

#prevent create files in /logs during rm procedure
killall syslogd
rm -rvf /logs/*; sync; sync

#rm content of /configs execpt wifi_calibration_file
if [ "$WIFI_CALIB_FILE" != "" ]; then
	cd /configs/; ls | grep -vE bcm  | xargs rm -vrf; sync; sync
	cd /configs/bcm; ls | grep -vE $WIFI_CALIB_FILE | xargs rm -vrf; sync; sync
else
	rm -rvf /configs/*; sync; sync
fi
cd /configs/; ReservedFile=`ls`
cd /logs/; logReservedFile=`ls`

if [ "$ReservedFile" != "" ];then
	echo -e "\nreserve file in /configs/:\n$ReservedFile\n"
else
	echo -e "\nNo file reserved in /configs/\n"
fi

if [ "$logReservedFile" != "" ];then
	echo -e "\nreserve file in /logs/:\n$logReservedFile\n"
else
	echo -e "\nNo file reserved in /logs/\n"
fi

#echo "prepare customer's restoration!"
#touch /configs/flag.factory-default
#touch /logs/flag.factory-default

echo "FITS:reset to default end !"

