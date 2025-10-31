#!/bin/sh

printInfo()
{
	CMD=$1
	echo ""
	echo "$CMD"
	$CMD
}

is_dhd()
{
	#which dhd > /dev/null 2>&1
	mainInf=$1
	dhd -i $mainInf dump > /dev/null 2>&1
	is_dhd=$?
	if [ $is_dhd -eq 0 ]; then
		echo "1"
	else
		echo "0"
	fi
}

getInfInfo()
{
	mainInf="wl$index"
	wdsInf="wl$index.$subIndex"
	MACs="`wl -i $mainInf wds | awk '{print $2}'`" 
	STA_MACs="`wl -i $mainInf assoclist | awk '{print $2}'`" 
	cnt=0
	
	printInfo "date"
	printInfo "wl -i $wdsInf wds"
	printInfo "wl -i $wdsInf status"
	printInfo "wl -i $mainInf assoclist"
	printInfo "wl -i $mainInf keys"
	printInfo "wl -i $mainInf cca_get_stats -i"
	printInfo "wl -i $mainInf chanim_stats"
	printInfo "wl -i $mainInf macmode"
	printInfo "wl -i $mainInf mac"
	printInfo "wl -i $mainInf curpower"
	echo ""
	echo "nvram show |grep $wdsInf|sort"
	nvram show |grep $wdsInf|sort
	
	local dhd_mode=`is_dhd $mainInf`
	for mac in $MACs
	do
		i=0
		let cnt=$cnt+1
		while [ $i -lt 3  ];
		do
			let i=$i+1
			inf="`wl -i $mainInf wds | grep $mac | awk -F ':' '{print $1}'`"
			printInfo "wl -i $wdsInf sta_info $mac"
			printInfo "ifconfig $inf"
			if [ "x$dhd_mode" = "x1" ]; then
				printInfo "dhd -i $mainInf dump"
			fi
			printInfo "wl -i $mainInf counters"
			printInfo "wl -i $mainInf pktq_stats"
			printInfo "wl -i $mainInf memuse"
			printInfo "wl -i $mainInf wme_counters"
			sleep 1
		done
		echo "" 
	done
	for stamac in $STA_MACs
	do
		printInfo "assoclist in interface $mainInf===============================start"
		printInfo "wl -i $mainInf sta_info $stamac"
		printInfo "assoclist in interface $mainInf=================================end"
	done
	if [ "x$dhd_mode" = "x1" ]; then
		printInfo "dhd -i $mainInf dconpoll 250"
		printInfo "dmesg -n 8"
		printInfo "dmesg -c"
		sleep 5
		printInfo "dmesg -c"
		printInfo "dhd -i $mainInf dconpoll 0"
	else
		printInfo "wl -i $mainInf msglevel +err"
		printInfo "dmesg -n 8"
		printInfo "dmesg -c"
		sleep 5
		printInfo "dmesg -c"
		printInfo "wl -i $mainInf msglevel 0"
	fi
}

collectLogFiles()
{
	fileNames="`ls /tmp/|grep wifi`"
	for file in $fileNames
	do
		file="/tmp/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		cat $file
	done

	fileNames="`ls /tmp/ |grep wds`"
	for file in $fileNames
	do
		file="/tmp/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		cat $file
	done

	echo ""
	echo "============Start AI log=================================="
	fileNames="`ls /tmp/ |grep ai`"
	for file in $fileNames
	do
		file="/tmp/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		cat $file
	done

	fileNames="`ls /tmp/whw/ai_engine/ |grep ai`"
	for file in $fileNames
	do
		file="/tmp/whw/ai_engine/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		cat $file
	done
	cat /tmp/historychop.txt
	cat /tmp/historychan.txt
	cat /tmp/channellocations.txt
	cat /tmp/channelsurvey.txt
	cat /tmp/whw/ai_engine/expected_chbw.txt
	echo "============End AI log=================================="

	echo ""
	echo ""
	echo "=============================="
	echo " /tmp/backhaul_selecter_log"
	echo "=============================="
	cat /tmp/backhaul_selecter_log
	cat /usr/etc/buildinfo
	ps
}

getOtherInfo()
{
	printInfo "ifconfig br0"
	printInfo "brctl showmacs br0"
	printInfo "brctl showstp br0"
	printInfo "ritool dump"
        echo ""                                                                         
        echo "netstat -apn | grep nas"                                                  
        netstat -apn | grep nas                                                         
                                                                                        
        echo ""                                                                         
        echo "netstat -apn | grep eapd"                                                 
        netstat -apn | grep eapd 
}

echo "=============================="
echo "         Get 5G info"
echo "=============================="

index=0
subIndex=4
getInfInfo


echo ""
echo ""
echo "=============================="
echo "         Get 2G info"
echo "=============================="

index=1
subIndex=4
getInfInfo

collectLogFiles
getOtherInfo
exit
