#!/bin/sh
#set -x
#
# script  : get-debug-info.sh
TOOL_VERSION="v0.4.1"
# 
# history : 
#  v0.0.1 - First draft version.
#  v0.0.2 - Deleted original output after making tar.gz file.
#           suppress tar error message.
#           moved parameter check to upper area
#  v0.0.3 - Fixed akm parameter return two or more words case.
#  v0.0.4 - Used $TEMP_DIR directory for processing files
#           .txt extension added for $output_file
#  v0.0.5 - Checked uniud.init file existence.
#  v0.0.6 - Added /sbin/cfgcli check
#  v0.0.7 - Changed TEMP_DIR from '/tmp/HA03_info' to '/tmp/system_info'
#           seperated the log message and REST API /network API outputs into their own files,
#               added process-time from REST API
#               added unium version from REST API
#           modified PS out to provide all proccess, not just unium
#           added check for is unium running from /flash or /usr 
#               - updated cli version output to execute from this location
#           added content of /config/unium to tar ball
#           added device model name and file name at the top of the generated files.
#  v0.0.8 - Changed tar output extention from ".tar.gz" to ".tgz".
#           Added checking /etc/buildinfo to verify running platform.    
#           Fixed getting uniumd version to check running uniumd version.
#  v0.0.9 - Fixed uniumd not running case 'cd error' message.
#  v0.1.0 - Added more uniumd not running case code.
#  v0.1.1 - Fixed get_wds_sta_info() to support hidden ssid and checking wrong wds interface.
#           Added contents of as part of file instead of cating into text.
#               /logs/messages*
#               /logs/beacon_syslog*
#           Collected TOP output for 10 times in every 1 sec to text file and Added
#               top -n 10 -d 1 > top10times.txt
#  v0.1.2 - Saparated ritool dump output to the .txt file.
#           Adjusted output file so that it does not try to cp the file to the current working directory as it will be run from a read only directory
#           Added a message at the end of the script that the .tgz file is avaliable at /tmp/system_info 
#  v0.1.3 - Added capture output for bs /b/e port to a new text file called bs_commands.txt
#                 capture output for bs /d/y/s to the bs_commands.txt file.
#                 capture output for uptime to uptime.txt
#                 capture output of lanhostd dump to lanhostd.txt file.
#                 capture output for cat /proc/<uniumd pid>/statm to proc_statm.txt
#                 capture output for http://localhost:8090/1/local/process-time to main .txt file. 
#                 capture output for netstat -anp to main .txt file. 
#           Fixed WDS station information bug.
#  v0.1.4 - Added bridge interface backbone check to main output file.
#  v0.1.5 - Added tool version and check /usr/exe/uniumd/ to see if the same script located in this directory is more up to date than the one they are executing, 
#           it could be they are running it from flash. If the tool has a more updated version in /usr/exe/uniumd - then the tool must provide feedback to the user telling them to use the more recent version.
#  v0.1.6 - Added wl1 interface wds link sta_info
#  v0.1.7 - Added ip link command result as separate file(ip_link.txt).
#  v0.1.8 - Fixed some commands for remote execution(via ssh...), Added nvram show results to separate file.
#           Added 2.4Ghz, 5Ghz ssid, chanspec and wpa_psk nvram value showing before showing wds link list.
#  v0.1.9 - Added to collect the messages_info logs in the /tmp directory.
#  v0.2.0 - Added wl -i {interface} chanim_stats.
#  v0.2.1 - Added Blacklist, route, iptables.txt, dmesg.txt, cfgcli_a.txt, logs.tgz, sys_class_net.tgz.
#  v0.2.2 - Replaced wget command to curl command to support timeout in case of uniumd REST server not responding.
#  v0.2.3 - Adjusted curl command option to specify timeout case and show the errors.
#  v0.2.4 - Changed $output_file to include YYY-MM-DD information and separated with $output_dir
#  v0.2.5 - Fixed uniumd version getting script missing part which was omitted by accident.
#  v0.2.6 - append LD_LIBRARY_PATH to support remote execution.
#  v0.2.7 - Added dhcp client connectivity - dhcp.leases,
#           Added clinets debug information.
#  v0.2.8 - Added DNS connectivity check by referring /tmp/resolv.conf,
#           Added Internet connectivity check with accessing www.google.com.
#  v0.2.9 - Added /usr/exe/whw_apps_log_collect.sh collecting logs,
#           Changed internet access checking url from www.google.com to www.nokia.com
#           Added tr069 logging toggle routine.
#           Updated iptables, ebtables logging with various kind of options to iptables.txt and ebtables.txt.
#           Collected and combined all ip link related command results to ip_link.txt.
#           Added comcli -m dnsproxy -u "view config, server, cache" to internet.txt which include all internet connectivity related status.
#           Added netstat -anp | grep dnsproxy to internet.txt.
#  v0.3.0 - Added /usr/exe/whw_apps_log_collect.sh corresponding logs to whw directory.
#           Separated bridge.txt process.txt netstat.txt ifconfig.txt buildinfo.txt for corresponding logs.
#           Added ai-engine corresponding logs to ai_engine directory.           
#  v0.3.1 - Added /usr/exe/whw/bin/get_wifi_logs.sh corresponding logs to get_wifi_logs.txt file.
#           Included /tmp/backhaul_select directory to output tgz file.
#  v0.3.2 - Added /tmp/aiq_debug_info_restart file at ai_engine directory.
#           Added "/sbin/airiqappcli show mem info" result to ai_engine/airiqappcli.txt file.
#
#           You can check more detailed working history & status at the below link.
#           https://nokia.sharepoint.com/:x:/r/sites/techteam/_layouts/15/Doc.aspx?sourcedoc=%7B92BE6A68-313D-40A1-82FA-D4BD4A8AA029%7D&file=log_collection_collaboration.xlsx&action=default&mobileredirect=true
#  v0.3.3 - Incorporate submission from yinzhew <yinzhe.wu@nokia-sbell.com> (FR ALU02563329: killall tr before restarting it.)
#  v0.3.4 - Added printInfo "wl -i $wdsInf wds" , printInfo "wl -i $mainInf keys" result in get_wifi_logs.txt according to Tong Bi's request.
#  v0.3.5 - Snapshot inspect-routing endpoint.
#  v0.3.6 - Probe Response Blocking feature debug support.
#  v0.3.7 - Removed references to specific bands, to support platforms where wl0/wl1 are assigned to different bands.
#  v0.3.8 - Removed '-9' option because of "FR ALU02579411: Correct TR-termination command.", yinzhew <yinzhe.wu@nokia-sbell.com> fixed it.
#  v0.3.9 - Update tr069 restarting script to remove only /sbin/tr process to avoid side effect.
#  v0.4.0 - Applied addtional debug log script from Tong Bi.
#  v0.4.1 - Applied omitted debug log script from Tong Bi and added curl error output redirection.
#
# Be sure to update TOOL_VERSION above after making changes.

export LD_LIBRARY_PATH=/usr/exe/whw/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

REST_PORT_FILE="/configs/uniumd/rest_listen_port"
if [ -f "$REST_PORT_FILE" ]; then
	REST_PORT=`cat "$REST_PORT_FILE"`
else
	REST_PORT="8090"
fi


# parameter check
if [ 1 -ne $# ]      
then                    
    echo ""
    echo "tool version : $TOOL_VERSION"
    echo ""
    echo "$0 [FR#]";
    echo ""
    exit
else
    if [ ! -f /etc/buildinfo ]
    then
        echo 'Cannot find "/etc/buildinfo" !, this script only available on Nokia devices.'
        exit                                                                
    else
        if [ ! -f /sbin/cfgcli ]
        then  
            echo 'Cannot find "/sbin/cfgcli" !, this script only available on Nokia devices.'
            exit                                                                
        fi
    fi                                                                          
fi

# version check with /usr/exe/unium/...
OTHER_SCRIPT=/usr/exe/unium/support_collector_tool.sh
if [ -f $OTHER_SCRIPT ]
then
    OTHER_VERSION=$( sh $OTHER_SCRIPT | grep "tool version" | awk '{print $4}' | sed -e "s/v//" | sed -e "s/\.//g")
    MY_VERSION=$( echo "$TOOL_VERSION"  | sed -e "s/v//" | sed -e "s/\.//g")
    if [ $OTHER_VERSION ]
    then
        if [ $OTHER_VERSION -gt $MY_VERSION ]
        then
            OTHER_VERSION_FULL=$( sh $OTHER_SCRIPT | grep "tool version" | awk '{print $4}')
            echo ""
            echo "$OTHER_SCRIPT is more latest version($OTHER_VERSION_FULL), please use that one !"
            echo ""
            exit                                                                
        fi
    fi
fi

get_br0_ip_address()
{
    echo $(/usr/sbin/ip route | grep br0 | awk '{print $9}')
}

get_workmode()
{
	WORKMODE=$(/sbin/cfgcli get InternetGatewayDevice.X_ALU-COM_Wifi.WorkMode)
	echo $WORKMODE | sed -e "s/InternetGatewayDevice.X_ALU-COM_Wifi.WorkMode=//"
}
			
			
get_br0mac()
{
	first_mac=$( /sbin/ifconfig br0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' )
	echo  $first_mac | sed -e "s/://g"
}

echo -n "Collecting."


output_file=FR$1_$( get_workmode )-$(date +'%Y-%m-%d_%H-%M')-$( get_br0mac )
output_dir=FR$1_$( get_workmode )-$( get_br0mac )
#echo $output_file

TEMP_DIR=/tmp/system_info/$output_dir

mkdir -p $TEMP_DIR

cur_dir=$(pwd)
#echo "$cur_dir"

# clear temp dir
\rm -rf $TEMP_DIR/*

echo -n "."

# get top command result first
top -b -n 10 -d 1 > $TEMP_DIR/top10times.txt

echo -n "."

ping_check()
{
    Count=$(($2))
    while [ $Count != 0 ] ; do
        /bin/ping -c1 $1 &> /dev/null
        if [ $? -eq 0 ] ; then
            echo "OK"
            return
        fi
        Count=$((Count-1))                  # So we don't go forever.
    done
    echo "NOK"
}


check_dns_connectivity()
{
    # check /tmp/resolv.conf exist first
    if [ ! -f /tmp/resolv.conf ]; then
        echo "could not find /tmp/resolv.conf"
        return
    fi

    # ping each dns ip address
    for i in $(cat /tmp/resolv.conf | awk '{print$2}'); do
        # ping
        echo "${i} - ping $(ping_check ${i} 2)"
    done

}

get_valide_wds_sta_info()
{
    for i in $(/sbin/ifconfig | grep wl | awk '{print $1}' | grep -v v); do 
        #echo "$(wl -i ${i} sta_info $1 2>/dev/null )"
        echo "$(wl -i ${i} sta_info $1 2>&1 )"
    done
}

get_wds_sta_info()
{
	#for i in $(wl wds | grep -o -E '([[:xdigit:]]{1,2,3,4,5,6,7,8}:){5}[[:xdigit:]]{1,2,3,4,5,6,7,8}'); do
	for i in $(wl wds | awk '{print $2}'); do
		if [ "$(get_valide_wds_sta_info ${i})" == "" ]
        then
            echo "${i} is bad address !"
        else
            echo "$(get_valide_wds_sta_info ${i})"
		echo
        fi
	done

	for i in $(wl -i wl1 wds | awk '{print $2}'); do
		if [ "$(get_valide_wds_sta_info ${i})" == "" ]
        then
            echo "${i} is bad address !"
        else
            echo "$(get_valide_wds_sta_info ${i})"
		echo
        fi
	done
}

get_enabled_wl_interface_assoclist()
{
	for i in  $(/sbin/ifconfig | grep wl | awk '!a[$5]++' | awk '{print $1}' ); do
		echo "[ wl -i ${i} assoclist ]"
		echo "$(wl -i ${i} assoclist 2>&1 )"
	done
}

get_sta_info_of_assoclist()
{
	for i in  $(/sbin/ifconfig | grep wl | awk '!a[$5]++' | awk '{print $1}' ); do
		for j in $(wl -i ${i} assoclist | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' ); do
			echo "[ wl -i ${i} sta_info ${j} ]"
			echo "$(wl -i ${i} sta_info ${j} 2>&1 )"
			echo
		done
	done
}

check_wl_interface_enabled()
{
	 wl_bssid=$(wl -i $1 status | grep BSSID | awk '{print $2}')
	 if [ "$wl_bssid" == "00:00:00:00:00:00" ]
	 then
	 	echo "disbled"
	 else
	 	echo "enabled"
	 fi
}

get_status_of_wl_interface()
{
	for i in  $(/sbin/ifconfig | grep wl | awk '!a[$5]++' | awk '{print $1}' ); do
		if [ "$(check_wl_interface_enabled ${i})" == "enabled" ]
		then
			echo "[ wl -i ${i} status ]"
			echo "$(wl -i ${i} status 2>&1 )"
		    #echo "$(wl -i ${i} chanim_stats)"
			echo
		else
			echo "##############################  Warning !  ##################################"
			echo "ifconfig showing ${i} enabled but actually it is not enabled with wl driver !"
			echo "#############################################################################"
		fi
	done
}

get_chanspec_of_wl_interface()
{
	if [ "$(check_wl_interface_enabled $1)" == "enabled" ]
	then
        echo "chanspec : $(wl -i $1 chanspec)"
		echo "$(wl -i $1 chanim_stats 2>&1 )"
		echo
	else
		echo "##############################  Warning !  ##################################"
		echo "$1 interface is not enabled with wl driver !                                 "
		echo "#############################################################################"
	fi
}


get_ssids_info()
{
	ssids_info=$(/sbin/cfgcli get InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.$2 |  sed -e "s/InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.$2=//")
	echo $ssids_info
}

check_encryption()
{
	result=$(/bin/nvram get $1_akm)
	if [ "$result" == "" ]
	then
		echo "none"
	else
		result=$(wl -i $1 wpa_auth | awk '{print $2}' )
		#result=$(wl -i $1 wpa_auth)
		echo "$result"
	fi
}

get_password()
{
	result=$(/bin/nvram get $1_wpa_psk)
	echo $result
}

get_encryption_mode()
{
	result=$(/bin/nvram get $1_akm)
	if [ "$result" == "" ]
	then
		echo "none"
	else
		result=$(wl -i $1 wpa_auth | awk '{print $2}' )
		echo "$result"
	fi
}

check_enabled_ssids()
{
	for i in 1 2 3 4 5 6 7 8  ; do
		ssid_enabled=$(get_ssids_info ${i} Enable)
		if [ "$ssid_enabled" == "true" ]
		then
			interface_name=$(get_ssids_info ${i} Name)
			#echo " interface : $interface_name "
			echo "SSID${i}"
			echo "    SSID      : $(get_ssids_info ${i} SSID)"
			echo "    Channel   : $(get_ssids_info ${i} Channel)"
			echo "    Bandwidth : $(get_ssids_info ${i} X_ASB_COM_CurrentOperatingChannelBandwidth )"
			echo "    Tx Power  : $(get_ssids_info ${i} TransmitPower )"
			echo "    Enc. Mode : $(get_encryption_mode $interface_name  )"
			if [ $(check_encryption $interface_name) == "none" ]
			then
				echo "    Password  : none"
			else
				echo "    Password  : $(get_password $interface_name)"
			fi
			
			
			if [ $(get_ssids_info ${i} WPSEnable ) == "1" ]
			then
				echo "    Enable WPS: yes "
				echo "    WPS mode  : $(get_ssids_info ${i} WPSMode )"
			else
				echo "    Enable WPS: no "
			fi
			
			echo
			
		fi
	done
}


get_running_uniumd_position()
{
    result=$(/bin/ps -ww | grep uniumd | grep -v WATCHDOG | grep -v grep | awk '{print $5}')
    if [ "$result" == "" ]
    then
        echo "uniumd is not running !"
    else
        echo $result
    fi
}

check_uniumd_is_running()
{
    result=$(/bin/ps -ww | grep uniumd | grep -v WATCHDOG | grep -v grep | awk '{print $5}')
    if [ "$result" == "" ]
    then
        echo "false"
    else
        echo "true"
    fi
}

get_model_name()
{
    result=$(/sbin/ritool dump | grep Mnemonic: | awk '{print $2}' | sed -e "s/Mnemonic://")
    echo $result
}

get_uniumd_cli_string()
{
    if [ $(check_uniumd_is_running) == "false" ]
    then
        echo "uniumd is not running !"
    else
        result=$(/bin/ps -ww | grep uniumd | grep -v WATCHDOG | grep -v grep | awk '{ $1=""; $2=""; $3=""; $4=""; print}')
        echo $result
    fi
}

get_network_information_from_uniumd()                             
{                                                                    
    if [ $(check_uniumd_is_running) == "true" ]                          
    then                                                     
        echo ""                                     
        echo "[ Network AP Information ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/network -m 2 -S 2>&1  )"
        echo ""
        echo "[ Routing Information ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/inspect-routing -m 2 -S 2>&1 )"
        echo ""
        echo "[ Clients debug information ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/debug/network/clients -m 2 -S 2>&1  )"
        echo ""
        echo "[ List of authenticated devices ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/authenticated-devices -m 2 -S 2>&1  )"
        echo ""
        echo "[ process-time from REST API ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/local/process-time -m 2 -S 2>&1  )"
        echo ""
        echo "[ uniumd version from REST API ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/version -m 2 -S 2>&1  )"
        echo ""
        echo "[ uniumd process time from REST API ]"
        echo "$( /sbin/curl -s http://localhost:${REST_PORT}/1/local/process-time -m 2 -S 2>&1  )"
    else
        echo ""
        echo "uniumd is not running !"
        echo ""
    fi
} 

get_running_uniumd_version()
{
    if [ $(check_uniumd_is_running) == "false" ]
    then
        echo "uniumd is not running !"
    else
        uniumd_position=$(get_running_uniumd_position)   
        uniumd_path=$( echo $uniumd_position | sed -e 's/uniumd//')
        if [ -e $uniumd_position ]
        then
            result=$( LD_LIBRARY_PATH=$uniumd_path $uniumd_position --version)
            echo $result
        else
            echo "cannot get version information from $uniumd_position "
            echo "please check $uniumd_position is moved or deleted."
        fi
    fi
}

check_bridge_interface_backbone()
{
    echo "Brideg_iface Backbone" |  awk '{ printf "%-20s %-40s\n", $1, $2}'
    echo "============================="
    for i in $(ls /sys/class/net); do
        if [ -e /sys/class/net/${i}/brport/backbone ]
        then
            result=$(cat /sys/class/net/${i}/brport/backbone | awk '{print $1}' )
            if [ $result != "cat" ]
            then
                #echo "${i} $result" |  awk '{ print $1"\t\t" $2}'
                echo "${i} $result" |  awk '{ printf "%-20s %-40s\n", $1, $2}'
            fi
        fi
    done
}

check_lanhostd(){
    echo "$(/bin/ps | /bin/grep lanhostd | /bin/grep -v grep | /usr/bin/awk '{print $5}')" 
}

# NONE or FILE
check_tr069_logging_status(){
    echo "$(cat /configs/tr069_conf/tr.conf | grep LogMode | cut -d'=' -f2 | sed -e 's/ //g')"
}

enable_tr069_logging(){
    /bin/sed -i 's/LogMode = NONE/LogMode = FILE/' /configs/tr069_conf/tr.conf
}

restart_tr069(){
    /bin/kill $(/bin/ps | grep "/sbin/tr "  | grep -v grep | /usr/bin/awk '{print $1}')
    /sbin/tr -d /configs/tr069_conf/ &> /logs/tr069_process_restart_message.txt &
}

TR069_STATUS="TR069 logging was not enabled"
tr069_logging(){
    #check it is enable
    if [ "$(check_tr069_logging_status)" != "FILE" ]; then
        #if it is not enabled, show message
        enable_tr069_logging
        TR069_STATUS="TR069 logging was not enabled but now it is enabled but logging just started !"
        restart_tr069
    else
        #if it is enabled, check log file
        if [ ! -f /logs/tr.log ]; then
            #if there is no log file, restart process and show message
            restart_tr069
            TR069_STATUS="TR069 logging was enabled but logging just started !"
        else
            #if there is log file, collect it
            TR069_STATUS="TR069 logging was enabled and logging will be included in logs.tgz !"
        fi
        #actually entire /logs directory will be collected so tr069 log file will be included there
    fi

    echo $TR069_STATUS >> /logs/tr069_process_restart_message.txt 
}

tr069_status(){
    echo $TR069_STATUS 
}

# referring whw_apps_log_collect.sh
collect_whw_apps_log(){
    DDMCLI=/usr/exe/whw/bin/ddmcli
    FPCLI=/bin/fpcli
    CFGCLI=/sbin/cfgcli

    #mkdir whw
    /bin/mkdir -p $TEMP_DIR/whw
    WHW_APPS_LOG_DIR=$TEMP_DIR/whw

    echo "[1] ps | grep ddm:"                       >> $WHW_APPS_LOG_DIR/ddm.txt
    /bin/ps | /bin/grep ddm                         >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[2] uptime:"                         >> $WHW_APPS_LOG_DIR/ddm.txt
    /usr/bin/uptime                                 >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[3] date:"                           >> $WHW_APPS_LOG_DIR/ddm.txt
    /bin/date                                       >> $WHW_APPS_LOG_DIR/ddm.txt

    echo -e "\n[4] ddmcli show thread info:"        >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI show thread info                        >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[5] ddmcli show debug info:"         >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI show debug info                         >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[6] ddmcli show session info:"       >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI show session info                       >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[7] ddmcli get queue info:"          >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get queue info                          >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[8] ddmcli dump dev stats:"          >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI dump dev stats                          >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[9] ddmcli get btree stats:"         >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get btree stats                         >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[10] dmcli get btree analytics:"     >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get btree analytics                     >> $WHW_APPS_LOG_DIR/ddm.txt 
    echo -e "\n[11] ddmcli get btree devintf:",     >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get btree devintf                       >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[12] ddmcli get btree fp:"           >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get btree fp                            >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[13]ddmcli get btree unium:"         >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get btree unium                         >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[14]ddmcli get mesh capability:"     >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get mesh capability                     >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[15]ddmcli get mem profile info:"    >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get mem profile info                    >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[16]ddmcli dump wan stats:"          >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI dump wan stats                          >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[17]ddmcli get async profile info:"  >> $WHW_APPS_LOG_DIR/ddm.txt
    $DDMCLI get async profile info                  >> $WHW_APPS_LOG_DIR/ddm.txt

    echo -e "\n[18] fpcli show config:"             >> $WHW_APPS_LOG_DIR/ddm.txt
    $FPCLI show config                              >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[19] fpcli show devinfo:"            >> $WHW_APPS_LOG_DIR/ddm.txt
    $FPCLI show devinfo                             >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[20] fpcli show alldevinfo:"         >> $WHW_APPS_LOG_DIR/ddm.txt
    $FPCLI show alldevinfo                          >> $WHW_APPS_LOG_DIR/ddm.txt

    echo -e "\n[21] cfgcli -e Hosts.:"              >> $WHW_APPS_LOG_DIR/ddm.txt
    $CFGCLI -e Hosts.                               >> $WHW_APPS_LOG_DIR/ddm.txt

    echo -e "\n[22] cfgcli -e X_ALU_WLANForGuest.1" >> $WHW_APPS_LOG_DIR/ddm.txt
    $CFGCLI -e X_ALU_WLANForGuest.1                 >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[23] cfgcli -e X_ALU_WLANForGuest.2" >> $WHW_APPS_LOG_DIR/ddm.txt
    $CFGCLI -e X_ALU_WLANForGuest.2                 >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n[24] cfgcli -e Hosts.:"              >> $WHW_APPS_LOG_DIR/ddm.txt
    $CFGCLI -e Hosts.                               >> $WHW_APPS_LOG_DIR/ddm.txt

    
    echo -e "\n"                                         >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "iptables            --> ../iptables.txt"    >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "ebtables            --> ../ebtables.txt"    >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "brctl               --> ../bridge.txt"      >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "ps                  --> ../process.txt"     >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "lanhostd            --> ../lanhostd.txt"    >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "dumpleases          --> ../dhcp.leases"     >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "netstat             --> ../netstat.txt"     >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "ifconfig            --> ../ifconfig.txt"    >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "/etc/buildinfo      --> ../buildinfo.txt"   >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "/tmp/messages_info* --> ../messages_info*"  >> $WHW_APPS_LOG_DIR/ddm.txt
    echo -e "\n"                                         >> $WHW_APPS_LOG_DIR/ddm.txt

    /bin/cp -a /flash/whw/edge_analytics/analytics.db   $TEMP_DIR/whw  2>>$WHW_APPS_LOG_DIR/ddm.txt 
    /bin/cp -a /flash/whw/cma/hie_timestamp.txt         $TEMP_DIR/whw  2>>$WHW_APPS_LOG_DIR/ddm.txt 
    /bin/cp -a /tmp/meshctl_dump.txt                    $TEMP_DIR/whw  2>>$WHW_APPS_LOG_DIR/ddm.txt 

    /bin/cp -a /tmp/.meshGwinfo*                        $TEMP_DIR/whw  2>>$WHW_APPS_LOG_DIR/ddm.txt 
    /bin/cp -a /tmp/internetstatus                      $TEMP_DIR/whw  2>>$WHW_APPS_LOG_DIR/ddm.txt 
}

# based on Xin, Zhen's feedback
collect_ai_engine_log(){
    #mkdir ai_engine
    /bin/mkdir -p $TEMP_DIR/ai_engine

    /bin/cp -a /tmp/ai-engine.log               $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/channelationprob.txt        $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/channelationprob5.txt       $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/channellocations.txt        $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/channellocationscorrect.txt $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/channelsurvey.txt           $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/historychop.txt             $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/historychan.txt             $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/aiq_debug_info_restart      $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt

    /bin/cp -a /tmp/whw/ai-agent.log            $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/whw/ai-agent.log.old        $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/whw/ai-healing.log          $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
    /bin/cp -a /tmp/whw/ai-healing.log.old      $TEMP_DIR/ai_engine  2>>$TEMP_DIR/ai_engine/log_collect_status.txt
}



printInfo()
{
	CMD=$1
	echo ""
	echo "[ $CMD ]"
	$CMD 2>&1
}

getInfInfo()
{
	mainInf="wl$index"
	wdsInf="wl$index.$subIndex"
	MACs="`/bin/wl -i $mainInf wds | /usr/bin/awk '{print $2}'`" 
	cnt=0
	
    printInfo "/bin/wl -i $wdsInf wds"
	printInfo "/bin/wl -i $wdsInf status"
	printInfo "/bin/wl -i $mainInf assoclist"
    printInfo "/bin/wl -i $mainInf keys"
	printInfo "/bin/wl -i $mainInf cca_get_stats -i"
	printInfo "/bin/wl -i $mainInf chanim_stats"
	echo ""
	echo "nvram show | grep $wdsInf | sort"
	/bin/nvram show | grep $wdsInf | /usr/bin/sort
	
	for mac in $MACs
	do
		i=0
		let cnt=$cnt+1
		echo "Info about $mac($cnt):" 
		while [ $i -lt 3  ];
		do
			let i=$i+1
			inf="`/bin/wl -i $mainInf wds | grep $mac | /usr/bin/awk -F ':' '{print $1}'`"
			printInfo "/bin/wl -i $wdsInf sta_info $mac"
			printInfo "/sbin/ifconfig $inf"
            if [ "x$dhd_mode" = "x1" ]; then
				printInfo "/bin/dhd -i $mainInf dump"
			fi
			printInfo "/bin/wl -i $mainInf counters"
			printInfo "/bin/wl -i $mainInf pktq_stats"
			printInfo "/bin/wl -i $mainInf memuse"
			printInfo "/bin/wl -i $mainInf wme_counters"
			sleep 1
		done
		echo "" 
	done
	if [ "x$dhd_mode" = "x1" ]; then
		printInfo "/bin/dhd -i $mainInf dconpoll 250"
		printInfo "/bin/dmesg -n 8"
		printInfo "/bin/dmesg -c"
		sleep 5
		printInfo "/bin/dmesg -c"
		printInfo "/bin/dhd -i $mainInf dconpoll 0"
	else
		printInfo "/bin/wl -i $mainInf msglevel +err"
		printInfo "/bin/dmesg -n 8"
		printInfo "/bin/dmesg -c"
		sleep 5
		printInfo "/bin/dmesg -c"
		printInfo "/bin/wl -i $mainInf msglevel 0"
	fi
}

collectLogFiles()
{
	fileNames="`/bin/ls /tmp/ | grep wifi`"
	for file in $fileNames
	do
		file="/tmp/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		/bin/cat $file
	done

	fileNames="`/bin/ls /tmp/ | grep wds`"
	for file in $fileNames
	do
		file="/tmp/$file"
		echo ""
		echo ""
		echo "=============================="
		echo "       $file"
		echo "=============================="
		/bin/cat $file
	done

	echo ""
	echo ""
    echo "============Start AI log=================================="
	fileNames="`/bin/ls /tmp/ | grep ai`"
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

	fileNames="`/bin/ls /tmp/whw/ai_engine/ |grep ai`"
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


    LOG_FILES_TO_CAT="/tmp/historychop.txt /tmp/historychan.txt /tmp/channellocations.txt /tmp/channelsurvey.txt /tmp/whw/ai_engine/expected_chbw.txt"
    for log_file_to_cat in $LOG_FILES_TO_CAT
    do
        /bin/cat $log_file_to_cat 2>&1
    done
	echo "============End AI log=================================="

	echo ""
	echo ""
	echo "=============================="
	echo " /tmp/backhaul_selecter_log"
	echo "=============================="
	/bin/cat /tmp/backhaul_selecter_log 2>&1
	echo ""
	echo ""
	/bin/cat /usr/etc/buildinfo 2>&1
}

#
get_wifi_5g_info()
{
    echo ""
    echo ""
    echo "=============================="
    echo "         Get wl0 info"
    echo "=============================="

    index=0
    subIndex=4
    getInfInfo
}

#
get_wifi_2g_info()
{
    echo ""
    echo ""
    echo ""
    echo "=============================="
    echo "         Get wl1 info"
    echo "=============================="
    echo ""

    index=1
    subIndex=4
    getInfInfo
}

airiqappcli_info(){
   printInfo "/sbin/airiqappcli show mem info"
}

probe_response_blocking_info(){

    echo ""
    if [ ! -z "$(wl -i wl1 probresp_rtx_limit 2>&1 | grep  Unsupported 2>/dev/null)" ]; then
			echo "[[ wl probresp_rtx_limit not capable device ! ]]"
	else
			echo "[[ wl probresp_rtx_limit capable device ]]"
			printInfo "wl -i wl0 probresp_rtx_limit "
			printInfo "wl -i wl1 probresp_rtx_limit"
			printInfo "wl -i wl0 probresp_sw"
			printInfo "wl -i wl1 probresp_sw"
	fi

    echo ""
    echo ""
    if [ ! -z "$(wl -i wl1 rssimac 2>&1 | grep  Unsupported 2>/dev/null)" ]; then
			echo "[[ wl rssimac not capable device ! ]]"
	else
			echo "[[ wl rssimac capable device ]]"
			printInfo "wl -i wl0 rssimac"
			printInfo "wl -i wl1 rssimac"
	fi
    echo ""
    echo ""

}


#
# End of functions
#

echo -n "."

#Creat dhcp.leases file
cat > $TEMP_DIR/dhcp.leases << EOF
$( /usr/bin/dumpleases 2>&1 )
EOF


#put log messages as separate file
#cp /logs/messages*          $TEMP_DIR/  2>/dev/null
#cp /logs/beacon_syslog*     $TEMP_DIR/  2>/dev/null
cp /tmp/messages_info*      $TEMP_DIR/  2>/dev/null
cp -a /tmp/backhaul_select  $TEMP_DIR/  2>/dev/null

echo -n "."

#REST API output as separate file
cat > $TEMP_DIR/$output_file.network << EOF
$(get_model_name):$output_file.network 

DATE : $(date), $(date +'%Y-%m-%d_%H-%M')
UTC  : $(date -u), $(date -u +'%Y-%m-%d_%H-%M')
$(get_network_information_from_uniumd)

EOF

echo -n "."

#save ri dump result as separated output file.
cat > $TEMP_DIR/ri_dump.txt << EOF
[ ritool dump ]
$( /sbin/ritool dump 2>&1 )

EOF

echo -n "."

#capture output for uptime to uptime.txt
cat > $TEMP_DIR/uptime.txt << EOF
[ uptime ]
$( uptime 2>&1 )

EOF

echo -n "."

#This should be called only at RGW
if [ $(check_lanhostd) ]; then
#capture output for lanhostd dump to lanhostd.txt
cat > $TEMP_DIR/lanhostd.txt << EOF
[ lanhostd dump ]
$( /usr/sbin/lanhostd dump 2>&1 )

EOF
fi

echo -n "."

#capture output for cat /proc/<uniumd pid>/statm to proc_statm.txt
UNIUMD_PID=$(/bin/ps | grep uniumd | grep -v grep | awk '{print $1}')
cat > $TEMP_DIR/proc_statm.txt << EOF
[ cat /proc/<uniumd pid>/statm  ]
$( cat /proc/$UNIUMD_PID/statm 2>&1 )

EOF

echo -n "."

#capture output for bs commands  to  bs_commands.txt
cat > $TEMP_DIR/bs_commands.txt << EOF
[ bs /b/e port ]
$( bs /b/e port 2>&1 )

[ bs /d/y/s ]
$( bs /d/y/s 2>&1 )

EOF

echo -n "."

#capture output of "ip link" command to ip_link.txt
cat > $TEMP_DIR/ip_link.txt << EOF
[ ip link ]
$( /usr/sbin/ip link 2>&1 )

[ ip neigh ]
$( /usr/sbin/ip neigh 2>&1 )

[ ip addr show ]
$( /usr/sbin/ip addr show 2>&1 )

[ ip route ]
$( /usr/sbin/ip route show 2>&1 )

[ route -n ]
$( /sbin/route -n 2>&1 )

EOF

echo -n "."

#capture output of "nvram show" command to nvram.txt
cat > $TEMP_DIR/nvram.txt << EOF
[ NVRAM ]
$( /bin/nvram show 2>&1 )

EOF

echo -n "."

#capture output of all sort of using ebtables command to ebtables.txt
cat > $TEMP_DIR/ebtables.txt << EOF
[ ebtables -Lc ]
$( /bin/ebtables -Lc 2>&1 )

[ ebtables -t nat -Lc ]
$( /bin/ebtables -t nat -Lc 2>&1 )

[ ebtables -t broute -Lc ]
$( /bin/ebtables -t broute -Lc 2>&1 )

EOF

echo -n "."

#capture output of all sort of using iptables command to iptables.txt
cat > $TEMP_DIR/iptables.txt << EOF
[ iptables -L INPUT ]
$( /bin/iptables -L INPUT 2>&1 )

[ iptables -L FORWARD ]
$( /bin/iptables -L FORWARD 2>&1 )

[ iptables -L -nv ]
$( /bin/iptables -L -nv 2>&1 )

[ iptables -t mangle -L SNIFFER_FILTER -nv ]
$( /bin/iptables -t mangle -L SNIFFER_FILTER -nv 2>&1 )

[ iptables  -t mangle -L PREROUTING  -nv ]
$( /bin/iptables  -t mangle -L PREROUTING  -nv  2>&1 )

[ iptables  -t nat -L -nv ]
$( /bin/iptables  -t nat -L -nv 2>&1 )

[ iptables  -t mangle -L FORWARD ]
$( /bin/iptables -t mangle -L FORWARD 2>&1 )

EOF

echo -n "."

#capture output of "dmesg" command to dmesg.txt
cat > $TEMP_DIR/dmesg.txt << EOF
[ dmesg ]
$( /bin/dmesg 2>&1 )

EOF

echo -n "."

#capture output of "cfgcli -a" command to cfgcli_a.txt
cat > $TEMP_DIR/cfgcli_a.txt << EOF
[ cfgcli -a ]
$( /sbin/cfgcli -a 2>&1 )

EOF

echo -n "."

#capture output of "cfgcli -a" command to cfgcli_a.txt
cat > $TEMP_DIR/cfgcli_dumpwan.txt << EOF
[ cfgcli dumpwan 10101 ]
$( /sbin/cfgcli dumpwan 10101 2>&1 )

[ cfgcli dumpwan 10201 ]
$( /sbin/cfgcli dumpwan 10201 2>&1 )

[ cfgcli dumpwan 10301 ]
$( /sbin/cfgcli dumpwan 10301 2>&1 )

EOF

echo -n "."

#capture output of "brctl" command related logs
cat > $TEMP_DIR/bridge.txt << EOF
[ brctl show ]
$(brctl show 2>&1 )

[ brctl showmacs br0 ]
$(brctl showmacs br0 2>&1 )

[ brctl showstp br0 ]
$(brctl showstp br0 2>&1 )

[ Bridge interface backbone check ]
$(check_bridge_interface_backbone)

EOF

echo -n "."

#capture output of "ps" command related logs
cat > $TEMP_DIR/process.txt << EOF
[ process status ]
$(/bin/ps)

EOF

echo -n "."

#capture output of "netstat" command related logs
cat > $TEMP_DIR/netstat.txt << EOF
[ netstat -anp ]
$(/bin/netstat -anp 2>&1 )

EOF

echo -n "."

#capture output of "ifconfig" command related logs
cat > $TEMP_DIR/ifconfig.txt << EOF
[ ifconfig ]
$(/sbin/ifconfig 2>&1 )

[ ifconfig -a ]
$(/sbin/ifconfig -a 2>&1 )

EOF

echo -n "."


#cat "/etc/buildinfo" 
cat > $TEMP_DIR/buildinfo.txt << EOF
[ /etc/buildinfo ]
$(/bin/cat /etc/buildinfo 2>&1 )

EOF

echo -n "."

# main output file
cat > $TEMP_DIR/$output_file.txt << EOF
$(get_model_name):$output_file.txt 

[ uniumd version ]
$(get_running_uniumd_version)

[ running uniumd position ]
$(get_running_uniumd_position)

[ uniumd cli command string ]
$(get_uniumd_cli_string)

[ Software version ]
$(/sbin/cfgcli get InternetGatewayDevice.DeviceInfo.SoftwareVersion | sed -e 's/InternetGatewayDevice.DeviceInfo.SoftwareVersion=//')

[ Device work mode ]
$( /sbin/cfgcli get InternetGatewayDevice.X_ALU-COM_Wifi.WorkMode | sed -e 's/InternetGatewayDevice.X_ALU-COM_Wifi.WorkMode=//' )

[ wl1 chanspec & chanim_stats ]
$(get_chanspec_of_wl_interface wl1)
nvram get wl1.4_wpa_psk : $(/bin/nvram get wl1.4_wpa_psk)

[ wl1 WDS list ]
$(wl -i wl1 wds 2>&1 )

[ wl0 chanspec & chanim_stats ]
$(get_chanspec_of_wl_interface wl0)
nvram get wl0.4_wpa_psk : $(/bin/nvram get wl0.4_wpa_psk)

[ wl0 WDS list ]
$(wl -i wl0 wds 2>&1 )

[ WDS station information ]
$(get_wds_sta_info)

$(get_enabled_wl_interface_assoclist)

$(get_sta_info_of_assoclist)

$(get_status_of_wl_interface)

[ Network configurations of all user enabled SSIDs ]
$(check_enabled_ssids)

# Hidden SSIDs information can be seen above [ wl -i wlx.4 status ] command result.

[ Blacklist for wl0 ]
$(wl -i wl0 mac 2>&1 )

[ Blacklist for wl1 ]
$(wl -i wl1 mac 2>&1 )

EOF

echo -n "."

# internet connectivity logging
#$( /sbin/comcli -m dnsproxy -o 3    )
cat > $TEMP_DIR/internet.txt << EOF
[ DNS connectivity check ]
$(check_dns_connectivity)

[ Internet connectivity check ]
$(/bin/ping -c 5 -I "$(get_br0_ip_address)" www.webgui.Nokiawifi.com  2>&1 )

[ netstat -anp | grep dnsproxy ]
$(/bin/netstat -anp 2>/dev/null | grep dnsproxy  2>&1 )

EOF

/bin/touch $TEMP_DIR/internet1.txt 
echo -n "."
$( /sbin/comcli -m dnsproxy -u "view config" -p $TEMP_DIR/internet1.txt  )
/bin/touch $TEMP_DIR/internet2.txt 
echo -n "."
$( /sbin/comcli -m dnsproxy -u "view server" -p $TEMP_DIR/internet2.txt )
/bin/touch $TEMP_DIR/internet3.txt 
echo -n "."
$( /sbin/comcli -m dnsproxy -u "view cache" -p $TEMP_DIR/internet3.txt )
echo -n "."

sleep 2

echo -n "."
echo "" >>  $TEMP_DIR/internet.txt 
echo "[ comcli -m dnsproxy -u \"view config\" ]" >> $TEMP_DIR/internet.txt
/bin/sed -i '1d' $TEMP_DIR/internet1.txt
cat  $TEMP_DIR/internet1.txt >>  $TEMP_DIR/internet.txt 
echo "" >>  $TEMP_DIR/internet.txt 
echo "[ comcli -m dnsproxy -u \"view server\" ]" >> $TEMP_DIR/internet.txt
/bin/sed -i '1d' $TEMP_DIR/internet2.txt
cat  $TEMP_DIR/internet2.txt >>  $TEMP_DIR/internet.txt 
echo "" >>  $TEMP_DIR/internet.txt 
echo "[ comcli -m dnsproxy -u \"view cache\" ]" >> $TEMP_DIR/internet.txt
/bin/sed -i '1d' $TEMP_DIR/internet3.txt
cat  $TEMP_DIR/internet3.txt >>  $TEMP_DIR/internet.txt 
echo "" >>  $TEMP_DIR/internet.txt 

\rm -rf $TEMP_DIR/internet1.txt $TEMP_DIR/internet2.txt $TEMP_DIR/internet3.txt 

echo -n "."

collect_whw_apps_log

echo -n "."

collect_ai_engine_log

echo -n "."

if [ -x /usr/exe/whw/bin/get_wifi_logs.sh ]
then
    echo "[ Result of script get_wifi_logs.sh ]" > $TEMP_DIR/get_wifi_logs.txt
    /bin/sh /usr/exe/whw/bin/get_wifi_logs.sh >> $TEMP_DIR/get_wifi_logs.txt
else
#
# /usr/exe/whw/bin/get_wifi_logs.sh corresponding logs
#
cat > $TEMP_DIR/get_wifi_logs.txt << EOF
$( get_wifi_5g_info )
EOF

echo -n "."

cat >> $TEMP_DIR/get_wifi_logs.txt << EOF
$( get_wifi_2g_info )
EOF

echo -n "."

cat >> $TEMP_DIR/get_wifi_logs.txt << EOF
$( collectLogFiles )
EOF

fi # End of if no script get_wifi_logs.sh

echo -n "."

cat >> $TEMP_DIR/probe_response_info.txt << EOF
$(probe_response_blocking_info)
EOF

echo -n "."

#
# this should be after the "collect_ai_engine_log" 
#
cat > $TEMP_DIR/ai_engine/airiqappcli.txt << EOF
$( airiqappcli_info )

EOF

echo -n "."

tr069_logging


default_uniumd_init_copy()
{
    if [ -f /flash/unium/uniumd.init ] 
    then
        cp /flash/unium/uniumd.init $TEMP_DIR
    else
        if [ -f /usr/exe/unium/uniumd.init ]
        then
            cp /usr/exe/unium/uniumd.init $TEMP_DIR
        else
            echo "error ! cannot find unium.init !"
        fi
    fi
}

if [ $(check_uniumd_is_running) == "false" ]
then
    default_uniumd_init_copy
else
    uniumd_position=$(get_running_uniumd_position)
    if [ -f $uniumd_position.init ]
    then
        cp $uniumd_position.init $TEMP_DIR
    else
        default_uniumd_init_copy
    fi
fi

output_tar_file=$output_file.tgz

cd $TEMP_DIR


# archiving some directories
tar zcf configs.tgz /configs >/dev/null 2>&1
tar zcf logs.tgz /logs >/dev/null 2>&1
tar zcf sys_class_net.tgz /sys/class/net >/dev/null 2>&1

echo -n "."

#tar zcf pwd/$output_file.tar.gz $output_file uniumd.init &>/dev/null
tar zcf $output_tar_file $output_file.txt uniumd.init $output_file.network messages* beacon_syslog* configs.tgz logs.tgz sys_class_net.tgz top10times.txt ri_dump.txt bs_commands.txt lanhostd.txt proc_statm.txt uptime.txt ip_link.txt nvram.txt iptables.txt ebtables.txt dmesg.txt cfgcli_a.txt dhcp.leases cfgcli_dumpwan.txt internet.txt bridge.txt process.txt netstat.txt ifconfig.txt buildinfo.txt get_wifi_logs.txt probe_response_info.txt  whw ai_engine backhaul_select >/dev/null 2>&1

echo -n "done"

echo ""
tr069_status

rm $output_file.txt uniumd.init $output_file.network configs.tgz logs.tgz sys_class_net.tgz beacon_syslog* messages* top10times.txt ri_dump.txt bs_commands.txt lanhostd.txt proc_statm.txt uptime.txt ip_link.txt nvram.txt iptables.txt ebtables.txt dmesg.txt cfgcli_a.txt dhcp.leases cfgcli_dumpwan.txt internet.txt bridge.txt process.txt netstat.txt ifconfig.txt buildinfo.txt get_wifi_logs.txt probe_response_info.txt  >/dev/null 2>&1
\rm -rf whw
\rm -rf ai_engine
\rm -rf backhaul_select

cd $cur_dir

echo ""
echo "Successfully generated [ $output_tar_file ] at [ $TEMP_DIR/ ]"
echo "Please check ---> $TEMP_DIR/$output_tar_file"                       
#tar tf $TEMP_DIR/$output_tar_file                    
#cp -f $TEMP_DIR/$output_tar_file .

#cat $output_file

