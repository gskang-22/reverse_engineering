#!/bin/sh
#set -x

MAX_FAIL_COUNT=3
MAX_OK_COUNT=450
MAX_CH36_FAIL_COUNT=20
RDI_FILE_PATH="/tmp/RDI_Alarm"
AI_USE_FLAG="/tmp/RDI_fail"
AI_CH112_FLAG="/flash/ch112_first"

is_high_band_ch()
{
	ch=$1
	if [ $ch -ge 149 -a $ch -le 165 ]; then
		echo 1
	else
		echo 0
	fi
}

monitor_rdi_status()
{
	switch_channel_flag=0
	monitor_ch36_flag=1
	is_ch36_ok=1
	is_hw_ok=0
	old_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
	if [ $old_channel -eq 0 ]; then
		old_channel=`wl -i wl1 chanspec | cut -d / -f 1`
	fi
	
	while [ $is_ch36_ok -eq 1 -a $is_hw_ok -eq 0 ]
	do
		sleep 2
		cur_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
		is_auto=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.AutoChannelEnable| cut -d = -f 2`
		if [ $cur_channel -eq 0 ]; then    
			cur_channel=`wl -i wl1 chanspec | cut -d / -f 1`
		fi
		is_high_band_channel=`is_high_band_ch $cur_channel`
			if [ -e $RDI_FILE_PATH ]; then
				rdi_flag=`cat $RDI_FILE_PATH`
				fail_count=0
				ch36_fail_count=0
				ok_count=0

				#NO RDI alarm in 15mins on ch149, we'll stop monitoring.
				while [ "x$rdi_flag" = "x0" -a "x$is_high_band_channel" = "x1" ]
				do
					let ok_count=ok_count+1
					if [ $ok_count -ge $MAX_OK_COUNT ]; then
						echo " RDI alarm is 0 for 15mins on ch149, we'll stop monitoring."
						is_hw_ok=1
						break;
					else
						sleep 2
						rdi_flag=`cat $RDI_FILE_PATH`
						cur_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
						if [ $cur_channel -eq 0 ]; then 
							cur_channel=`wl -i wl1 chanspec | cut -d / -f 1`
						fi
						is_high_band_channel=`is_high_band_ch $cur_channel`
					fi
				done
				
				#NO RDI alarm after switch to ch36 15mins, we'll not exit even after that we detected RDI alarm,just monitor the first time
				while [ "x$rdi_flag" = "x0" -a "x$cur_channel" = "x36" -a $switch_channel_flag -eq 1 -a $monitor_ch36_flag -eq 1 ]
				do
					let ok_count=ok_count+1
					if [ $ok_count -ge $MAX_OK_COUNT ]; then
						echo "HW is NOK, but ch36 is ok in 15mins, so we'll keep on monitor but not exit"
						monitor_ch36_flag=0
						break
					else
						sleep 2
						rdi_flag=`cat $RDI_FILE_PATH`
						cur_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
						if [ $cur_channel -eq 0 ]; then 
							cur_channel=`wl -i wl1 chanspec | cut -d / -f 1`
						fi
					fi
				done
				
				#RDI alarm detected
				while [ "x$rdi_flag" = "x1" ]
				do
					let fail_count=fail_count+1
					if [ $fail_count -ge $MAX_FAIL_COUNT ]; then
						if [ "x$cur_channel" != "x36" ]; then
							old_channel=$cur_channel
							echo "RDI failed detected, set channel from old channel $old_channel to ch36."
							switch_channel_flag=1
							wl -i wl1 csa 1 5 36/80
							echo "[RDI monitor]5G changed $cur_channel/80 --> 36/80 checked on `date`" >> /tmp/historychan.txt
							if [ -e $AI_USE_FLAG ]; then
							    rdi_fail_ch=`cat $AI_USE_FLAG`
								echo "rdi_fail_ch $rdi_fail_ch"
								if [ $rdi_fail_ch -ge $old_channel -a $old_channel -ne 0 ]; then
									echo $old_channel >$AI_USE_FLAG
								fi
							else							
							    touch $AI_USE_FLAG
							    echo $old_channel >$AI_USE_FLAG
							fi
							if [ ! -e $AI_CH112_FLAG ]; then
								touch $AI_CH112_FLAG
							fi
							sleep 20
							break
						else
							if [ $switch_channel_flag -eq 1 -a $monitor_ch36_flag -eq 1 ]; then
								rdi_flag=`cat $RDI_FILE_PATH`
								while [ "x$rdi_flag" = "x1"  -a "x$cur_channel" = "x36" ]
								do
									let ch36_fail_count=ch36_fail_count+1
									if [ $ch36_fail_count -ge $MAX_CH36_FAIL_COUNT ]; then
										echo "As ch36 is RDI NOK, so set fixed channel back to original user setting channel $old_channel"
										wl -i wl1 csa 1 5 $old_channel/80
										echo "[RDI monitor exit]5G changed back 36/80 --> $old_channel/80 checked on `date`" >> /tmp/historychan.txt
										if [ -e $AI_USE_FLAG ]; then
											rm -f $AI_USE_FLAG
										fi
										if [ -e $AI_CH112_FLAG ]; then
											rm -f $AI_CH112_FLAG
										fi
										is_ch36_ok=0
										break
									else
										sleep 2
										rdi_flag=`cat $RDI_FILE_PATH`
										cur_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
										if [ $cur_channel -eq 0 ]; then 
											cur_channel=`wl -i wl1 chanspec | cut -d / -f 1`
										fi
									fi
								done
							else
								echo "User set original channel to fixed 36, we'll do nothing, wait for 2s to check"
								sleep 2
								break
							fi
						fi
						break
					else
						sleep 2
						rdi_flag=`cat $RDI_FILE_PATH`
						cur_channel=`cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.Channel | cut -d = -f 2`
						if [ $cur_channel -eq 0 ]; then 
							cur_channel=`wl -i wl1 chanspec | cut -d / -f 1`
						fi
					fi
				done
			else
				echo "RDI file $RDI_FILE_PATH is not exist, wait for 10s to check"
				sleep 10
			fi
	done
}

start()
{                
	monitor_rdi_status
}
[ "$1" = "start" ] && start
