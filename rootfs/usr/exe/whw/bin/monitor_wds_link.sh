#!/bin/sh
#set -x

band_name="wl0"
band_wds_postfix=".4"
band_wds_wl_if="$band_name""$band_wds_postfix"
band_wds_mac_list=""
band_wds_if_prefix="wds0"

link_up_flag="WDS_LINKUP"
invalid_flag="4294967295"
auth_flag="AUTHORIZED"

BAD_RSSI=-78
MAX_FAIL_COUNT=6
MAX_OK_COUNT=3
monitor_count=0
wds_fail_count=0

MONITOR_LOG_PATH=/tmp/5g_wds_link_result.log

usage()
{
	echo "=======================================HELP============================================"
	echo "usage (monitor result is in $MONITOR_LOG_PATH):"
	echo "monitor_wds_link.sh start 2g &"
	echo "monitor_wds_link.sh start 5g &"
	echo "=======================================HELP============================================"
}

get_5G_radio_interface()
{
	ch_2g=`wl -i wl1 channels | cut -d ' ' -f 1`
	ch_5g=`wl -i wl0 channels | cut -d ' ' -f 1`
        if [ $ch_2g -ge 1 -a $ch_2g -le 14 -a $ch_5g -ge 36 -a $ch_5g -le 165 ]; then
		echo "wl0" 
	else
		echo "wl1"
	fi
}

get_work_role()
{
	while [ ! -e "/configs/workmode.txt" ]
	do
		sleep 2
	done
	work_role=`cat /configs/workmode.txt`
	if [ $work_role -eq 1 ]; then
		echo "Controller"
	elif [ $work_role -eq 0 ]; then
		echo "Agent"
	fi
}

init_wl_params()
{
	intf_5=`get_5G_radio_interface`
	if [ "$1" = "2g" ]; then
		if [ "$intf_5" = "wl0" ]; then
			band_name="wl1"
			band_wds_if_prefix="wds1"
		else
			band_name="wl0"
			band_wds_if_prefix="wds0"
		fi
		band_wds_postfix=".4"
		band_wds_wl_if="$band_name""$band_wds_postfix"
		band_wds_mac_list=`get_peer_wds_macs`
		MONITOR_LOG_PATH=/tmp/2g_wds_link_result.log
	else
		if [ "$intf_5" = "wl0" ]; then
			band_name="wl0"
			band_wds_if_prefix="wds0"
		else
			band_name="wl1"
			band_wds_if_prefix="wds1"
		fi
		band_wds_postfix=".4"
		band_wds_wl_if="$band_name""$band_wds_postfix"
		band_wds_mac_list=`get_peer_wds_macs`
		MONITOR_LOG_PATH=/tmp/5g_wds_link_result.log		
	fi
}

exe_cmd()
{
	cmd=$1
	echo "$1"
	echo "`$cmd`"
}

fail_print_to_log()
{
	fail_wds_mac=$1
	
	#let wds_fail_count=wds_fail_count+1
	#echo "===================wds fail count $wds_fail_count==================="
	echo "===================================================================="
	exe_cmd "date"
	#exe_cmd "cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole"
	#exe_cmd "ifconfig br0"
	#exe_cmd "wl -i $band_name status"
	#exe_cmd "wl -i $band_wds_wl_if status"
	exe_cmd "wl -i $band_wds_wl_if chanspec"
	exe_cmd "wl -i $band_name wds"
	exe_cmd "wl -i $band_wds_wl_if sta_info $fail_wds_mac"
	exe_cmd "wl -i $band_wds_wl_if rssi $fail_wds_mac"
	#exe_cmd "nvram show |grep $band_wds_wl_if"
	exe_cmd "brctl show"
	echo "===================================================================="
	echo ""
}

monitor_result_to_log()
{
	result=$1
	let monitor_count=monitor_count+1
	exe_cmd "date"
	echo "===================monitor count $monitor_count, result is $result==================="
}

is_wfd_mode()
{
	local chip_5g=`wl -i $band_name revinfo | grep chipnum | cut -d ' ' -f 2`
	which dhd > /dev/null 2>&1
	is_dhd=$?
	if [ "$chip_5g" = "0x4352" -o "$chip_5g" = "0x4360" -o $is_dhd -ne 0 ]; then
		echo 1
	else
		echo 0
	fi
}

is_wds_link_exist()
{
	if [ wl -i $band_name wds | grep wds >/dev/null ]; then
		echo 1
	else
		echo 0
	fi
}

is_link_rssi_good()
{
	wl_if=$1
	mac=$2
	
	rssi=`wl -i $wl_if rssi $mac`
	#echo "rssi=$rssi, peer mac=$mac"
	#echo "rssi=$rssi, peer mac=$mac" >>$MONITOR_LOG_PATH
	if [ $rssi -gt $BAD_RSSI ]; then
		echo 1
	else
		echo 0
	fi
}

is_invalid_wds_link()
{
	wl_if=$1
	mac=$2

	is_link_down=1
	is_valid_speed=1
	is_unauthed=0

	wl -i $wl_if sta_info $mac | grep "$auth_flag" > /dev/null 2>&1
	is_unauthed=$?
	wl -i $wl_if sta_info $mac | grep "$link_up_flag" > /dev/null 2>&1
	is_link_down=$?
	wl -i $wl_if sta_info $mac | grep "$invalid_flag" > /dev/null 2>&1
	is_valid_speed=$?

	rssi_stat=`is_link_rssi_good $band_wds_wl_if $mac`

	if [ $is_unauthed = 1 -a $is_link_down = 0 -a "x$rssi_stat" = "x1" ]; then
		echo "yes_unauthed"
	elif [ $is_link_down = 1 -o $is_valid_speed = 0 ]; then
		echo "yes"
	else
		echo "no"
	fi
}

get_peer_wds_macs()
{	
	wds_macs=`wl -i $band_name wds |grep wds | cut -d ' ' -f 2`
	if [ "x$wds_macs" = "x" ]; then
		echo "empty"
	else
		echo $wds_macs
	fi
}

check_rx_decrypt_fail_link()
{
	reg_mac=$1
	fake_fail_count=0
	rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
	sleep 2
	tmp_rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
	is_broken_link=`is_invalid_wds_link $band_wds_wl_if $reg_mac`

	echo "decrypt:mac=$reg_mac,rx_fail=$rx_decry_fail,tmp_rx_fail=$tmp_rx_decry_fail,link_failed=$is_broken_link" >> $MONITOR_LOG_PATH
	while [ "$is_broken_link" = "no" -a $tmp_rx_decry_fail -gt $rx_decry_fail ]
	do
		let fake_fail_count=fake_fail_count+1
		if [ $fake_fail_count -gt 3 ]; then
			fail_print_to_log $reg_mac >> $MONITOR_LOG_PATH
			touch /tmp/wds_processing
			echo "Renenerate FAKE wds link to $reg_mac -----start--------" >> $MONITOR_LOG_PATH
			wl -i $band_wds_wl_if deauthorize $reg_mac
			wl -i $band_wds_wl_if deauthenticate $reg_mac
			exe_cmd "date" >> $MONITOR_LOG_PATH
			echo "Renenerate FAKE wds link to $reg_mac-------end---------" >> $MONITOR_LOG_PATH
			sleep 30
			rm -fr /tmp/wds_processing
			break
		else
			sleep 2
			tmp_rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
			echo "decrypt2:mac=$reg_mac,rx_fail=$rx_decry_fail,tmp_rx_fail=$tmp_rx_decry_fail,link_failed=$is_broken_link" >> $MONITOR_LOG_PATH
		fi
		is_broken_link=`is_invalid_wds_link $band_wds_wl_if $reg_mac`
	done
	
}

is_fake_link()
{
	reg_mac=$1
	fake_fail_count=0
	rx_decry_suc=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt succeeds" | awk '{print $4}'`
	rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
	sleep 5
	tmp_rx_decry_suc=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt succeeds" | awk '{print $4}'`
	tmp_rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
	is_broken_link=`is_invalid_wds_link $band_wds_wl_if $reg_mac`

	echo "tb1:mac=$reg_mac,rx_fail=$rx_decry_fail,tmp_rx_fail=$tmp_rx_decry_fail,rx_suc=$rx_decry_suc,tmp_rx_suc=$tmp_rx_decry_suc,link_failed=$is_broken_link" >> $MONITOR_LOG_PATH
	while [ "$is_broken_link" = "no" -a $tmp_rx_decry_fail -gt $rx_decry_fail -a $rx_decry_suc -eq $tmp_rx_decry_suc ]
	do
		let fake_fail_count=fake_fail_count+1
		if [ $fake_fail_count -gt 3 ]; then
			fail_print_to_log $reg_mac >> $MONITOR_LOG_PATH
			touch /tmp/wds_processing
			echo "Renenerate FAKE wds link to $reg_mac -----start--------" >> $MONITOR_LOG_PATH
			wl -i $band_wds_wl_if deauthorize $reg_mac
			wl -i $band_wds_wl_if deauthenticate $reg_mac
			exe_cmd "date" >> $MONITOR_LOG_PATH
			echo "Renenerate FAKE wds link to $reg_mac-------end---------" >> $MONITOR_LOG_PATH
			sleep 30
			rm -fr /tmp/wds_processing
			break
		else
			sleep 10
			tmp_rx_decry_suc=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt succeeds" | awk '{print $4}'`
			tmp_rx_decry_fail=`wl -i $band_wds_wl_if sta_info $reg_mac | grep "rx decrypt failures" | awk '{print $4}'`
			echo "tb2:mac=$reg_mac,rx_fail=$rx_decry_fail,tmp_rx_fail=$tmp_rx_decry_fail,rx_suc=$rx_decry_suc,tmp_rx_suc=$tmp_rx_decry_suc,link_failed=$is_broken_link" >> $MONITOR_LOG_PATH
		fi
		is_broken_link=`is_invalid_wds_link $band_wds_wl_if $reg_mac`
	done
	
}

regenerate_wds_link()
{
	bad_mac=$1
	wl -i $band_wds_wl_if deauthenticate $bad_mac
	
	macs=`get_peer_wds_macs`
	if [ "x$macs" != "xempty" ]; then
		for tmp_mac in $macs
		do
			if [ "x$bad_mac" != "x$tmp_mac" ]; then
				is_bro_link=`is_invalid_wds_link $band_wds_wl_if $tmp_mac`
				if [ "$is_bro_link" = "yes_unauthed" ]; then
					break
				elif [ "$is_bro_link" = "no" ]; then
					sleep 10
					is_fake_link $tmp_mac
				fi
				break
			fi
		done
	fi
}

check_wds_links()
{
	wds_link_stat="wds_ok"

	macs=`get_peer_wds_macs`
	
	if [ "x$macs" != "xempty" ]; then
		for mac in $macs
		do
			fail_count=0
			
			is_link_failed=`is_invalid_wds_link $band_wds_wl_if $mac`
			#if [ "$is_link_failed" = "no" ]; then
			#	check_rx_decrypt_fail_link $mac
			#fi
			while [ "$is_link_failed" = "yes" -o "$is_link_failed" = "yes_unauthed" ]
			do
				if [ "$is_link_failed" = "yes_unauthed" ] ; then
					let fail_count=fail_count+1
				else
					wds_link_stat="wds_fail"
					break
				fi	

				if [ $fail_count -gt $MAX_FAIL_COUNT ]; then
					fail_print_to_log $mac >> $MONITOR_LOG_PATH
					#if wds link is not AUTHORIZED, we'll check 10 times in every 20 secs, 
					#60s later do regenarate, after regenarate we'll wait 60s for undless regenarate
					wds_link_stat="wds_regenerate"
					echo "Renenerate wds BROKEN link to $mac -----start--------" >> $MONITOR_LOG_PATH
					touch /tmp/wds_processing
					regenerate_wds_link  $mac > /dev/null 2>&1
					exe_cmd "date" >> $MONITOR_LOG_PATH
					echo "Renenerate wds BROKEN link to $mac------end----------" >> $MONITOR_LOG_PATH
					is_link_failed="no"
					check_log_size $MONITOR_LOG_PATH
					sleep 30
					rm -fr /tmp/wds_processing
				else
					sleep 20
					is_link_failed=`is_invalid_wds_link $band_wds_wl_if $mac`
				fi
			done
		done
	else
		wds_link_stat="no_wds_links"
	fi

	echo $wds_link_stat
}

#When log size is over 0.5M, we'll erase the old logs
check_log_size()
{
	if [ -e "$1" ]; then
		log_size=`ls -l $1 | awk '{ print $5 }'`
		if [ $log_size -gt 524288 ]; then
			monitor_count=0
			echo "" > $1
		fi
	fi
}

monitor_wds_link()
{
	ok_count=0
	while [ "x$1" = "x1" ]
	do
		result=`check_wds_links`
		if [ "x$result" = "xwds_ok" ]; then
			let ok_count=ok_count+1
			check_log_size $MONITOR_LOG_PATH
			sleep 10
			if [ $ok_count -eq $MAX_OK_COUNT ]; then
				ok_count=0
				#echo "everything is OK, wait 10s to re-check"
				monitor_result_to_log $result >> $MONITOR_LOG_PATH
				echo "Checking WDS link in every 10s, in the past 30s WDS link is OK." >> $MONITOR_LOG_PATH
			fi
		elif [ "x$result" = "xwds_fail" ]; then
			ok_count=0
			#echo "wds link is NOK, regenarate wds link to check whether can recover (wait 10s to re-check)"
			echo "WDS link is NOT LINKUP, we'll not regenarate the wds links(wait 10s to re-check)." >> $MONITOR_LOG_PATH
			let wds_fail_count=wds_fail_count+1
			echo "==========================wds fail count $wds_fail_count=====================" >> $MONITOR_LOG_PATH
			check_log_size $MONITOR_LOG_PATH
			sleep 10
		elif [ "x$result" = "xwds_regenerate" ]; then
			ok_count=0
			#echo "wds link is NOK, regenarate wds link to check whether can recover (wait 10s to re-check)"
			echo "WDS link is LINKUP but not AUTHORIZED, we'll regenarate wds links (wait 10s to re-check)." >> $MONITOR_LOG_PATH
			let wds_fail_count=wds_fail_count+1
			echo "===================wds fail count $wds_fail_count============================" >> $MONITOR_LOG_PATH
			check_log_size $MONITOR_LOG_PATH
			sleep 10
		else
			ok_count=0
			check_log_size $MONITOR_LOG_PATH
			#echo "no wds links, wait 50s to re-check"
			monitor_result_to_log $result >> $MONITOR_LOG_PATH
			echo "NO WDS links, wait for 90s to re-check." >> $MONITOR_LOG_PATH
			sleep 90
		fi
		
	done	
}

manu_regenerate_wds()
{
	local all_macs=`get_peer_wds_macs`
	local link_down=1
	if [ "x$all_macs" != "xempty" ]; then
		for tmp_mac in $all_macs
		do
			local fail_cnt=0
			wl -i $band_wds_wl_if sta_info $tmp_mac | grep "$link_up_flag" > /dev/null 2>&1
			link_down=$?
			while [ $link_down = 1 ]
			do
				let fail_cnt=fail_cnt+1
				if [ $fail_cnt -gt 5 ]; then
					break
				fi
				sleep 6
				echo "[manually-wds]wds link to $tmp_mac flag is not LINKUP, sleep 6 secs then check again" >> $MONITOR_LOG_PATH
				wl -i $band_wds_wl_if sta_info $tmp_mac | grep "$link_up_flag" > /dev/null 2>&1
				link_down=$?
			done
			if [ $link_down = 0 ]; then
				echo "[manually-wds] regenerate wds link to $tmp_mac------start----------" >> $MONITOR_LOG_PATH
				wl -i $band_wds_wl_if deauthenticate $tmp_mac
				echo "[manually-wds] regenerate wds link to $tmp_mac------end----------" >> $MONITOR_LOG_PATH
			fi
		done
	else
		echo "[manually-wds] try to regenerate wds link, but no peer macs" >> $MONITOR_LOG_PATH
	fi
}

start()
{
	if [ "$1" = "5g" ]; then
		work_role=`get_work_role`

		init_wl_params $1
		echo "start monitor $1 wds script..." >> $MONITOR_LOG_PATH
		exe_cmd "date" >> $MONITOR_LOG_PATH
		echo "current work role is $work_role" >> $MONITOR_LOG_PATH
		echo "$band_name mac_list is $band_wds_mac_list" >> $MONITOR_LOG_PATH
		exe_cmd "ifconfig br0" >> $MONITOR_LOG_PATH
		exe_cmd "wl -i $band_name status" >> $MONITOR_LOG_PATH
		exe_cmd "wl -i $band_wds_wl_if status" >> $MONITOR_LOG_PATH
		monitor_wds_link 1
	elif [ "$1" = "ai_regen_wds" ]; then
		#For AI healing case
		init_wl_params $1
		local work_rl=`get_work_role`
		local wfd_mode=`is_wfd_mode`
		if [ "x$work_rl" = "xController" -a $wfd_mode -eq 1 ]; then
			manu_regenerate_wds
		fi
	else
		return
	fi
}

if [ "$1" == "" ] ; then
        usage
fi

[ "$1" = "start" ] && start $2
