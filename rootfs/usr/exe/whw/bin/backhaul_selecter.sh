#!/bin/sh

#set -x

enable_debug=false
start_time=2                                                   #waiting for system stable, should set it to 120(s) when need auto run
interval=10                                                    #detect interval unit is second
check_flow_cache_interval=10                                   #check flow cache interval
stability_detect_count=5                                       #stability detect times to avoid snake

rssi_2g_thresh_low=-50                                         #2.4g RSSI threshold low
rssi_5g_thresh_low=-78                                         #5g RSSI threshold low

obss_5g_thresh_bad=85                                          #5g obss threshold bad
obss_5g_thresh_good=75                                         #5g obss threshold good
txop_5g_thresh_bad=3                                           #5g txop threshold bad
txop_5g_thresh_good=15                                         #5g txop threshold good

obss_2g_thresh_good=40                                         #2.4g obss threshold good
txop_2g_thresh_good=50                                         #2.4g txop threshold good

itf_5g="unknow"                                                # interface for 5G
itf_24g="unknow"                                               # interface for 2.4G

itf_5g_index="unknow"                                          # index(wlx) of 5G
itf_24g_index="unknow"                                         # index(wlx) of 2.4G

#total_2g_thresh_1s_bytes=7864320                              #60Mbps = 60*1024*1024/8 = 7864320
total_2g_thresh_1s_bytes=9830400                               #75Mbps = 75*1024*1024/8 = 9830400
#total_2g_thresh_1s_bytes=13107200                             #100Mbps = 100*1024*1024/8 = 13107200

detect_count=0                                                 #detect current environment count
switch_count=0                                                 #real switch backhaul count
default_dir=/tmp/backhaul_select/                              #work dir
auth_file=                                                     #to get basemac/routerid and wds macs map
work_role="UNSELECTED"                                      
sys_logger="logger -st script_backhaulselector "

rest_port=8090                                                 #Uniumd default api port
rest_addr="127.0.0.1"                                          #Uniumd default api addr
rest_listen_port_file="/configs/uniumd/rest_listen_port"       #Uniumd default get api port from file name
rest_listen_addr_file="/configs/uniumd/rest_listen_addr"       #Uniumd default get api addr from file name

parse_topo_result=${default_dir}basemac_router_2g_5g           #parse unium network topo result file
select_backhaul_result=${default_dir}select_result             #currentlly backhaul select result file
last_use_result=${default_dir}last_use_result                  #last time real used backhaul result file
disabled_links_result=${default_dir}disabled_links_result      #currentlly disabled backhaul links result file
current_using_backhaul_result=${default_dir}peer_router_ids_mediums  #currentlly using backhaul links result file
log_file=/tmp/backhaul_selecter_log                           #log file
#max_log_size=4194304   #4M Bytes
max_log_size=524288   #512K Bytes
#max_log_size=10240   #10K Bytes

print_cmd_and_result()
{
    cmd=$1
    echo "$1"
    echo "`$cmd`"
    echo
}

clear_last_files()
{
    cd ${default_dir} && rm -f topo router-ids mac-addresses basemac_router basemac wds_2g_macs wds_5g_macs basemac_2g basemac_2g_5g && cd -
    rm -f $parse_topo_result
    rm -f $select_backhaul_result
}

show_tmp_files()
{
    print_cmd_and_result "cat ${default_dir}router-ids"
    print_cmd_and_result "cat ${default_dir}mac-addresses"
    print_cmd_and_result "cat ${default_dir}basemac_router"
    print_cmd_and_result "cat ${default_dir}basemac"
    print_cmd_and_result "cat ${default_dir}wds_2g_macs"
    print_cmd_and_result "cat ${default_dir}wds_5g_macs"
    print_cmd_and_result "cat ${default_dir}basemac_2g"
    print_cmd_and_result "cat ${default_dir}basemac_2g_5g"
}

init_rest_unium_api()
{
    if [ -e $rest_listen_port_file ];then
        rest_port=$(cat $rest_listen_port_file)
    fi

    if [ -e $rest_listen_addr_file ];then
        rest_addr=$(cat $rest_listen_addr_file)
    fi
}

get_itf_5g()
{
        ch_2g=`wl -i wl1 channels | cut -d ' ' -f 1`
        ch_5g=`wl -i wl0 channels | cut -d ' ' -f 1`
        if [ $ch_2g -ge 1 -a $ch_2g -le 14 -a $ch_5g -ge 36 -a $ch_5g -le 165 ]; then
                echo "wl0" 
        else
                echo "wl1"
        fi
}
init()
{
    itf_5g=$(get_itf_5g)

    if [ $itf_5g = "wl0" ]; then
        itf_24g="wl1"
        itf_5g_index="0"
        itf_24g_index="1"
    else
        itf_24g="wl0"
        itf_5g_index="1"
        itf_24g_index="0"
    fi

    init_rest_unium_api

    if [ "x${default_dir}" == "x" ]
    then
        default_dir=./
    else
        mkdir -p ${default_dir}
    fi

    if [ "x$work_role" = "xController" ]
    then
        auth_file=/configs/auth_beacon
        parse_topo_result=${default_dir}basemac_router_2g_5g
    else
        parse_topo_result=${default_dir}beacon_peer_router_id
        auth_file=/configs/root_beacon
    fi

    #country_id=$(ritool dump |grep CountryID |awk -F ':' '{print $2}')
    #if [ "x$country_id" = "xus" ] ; then
    #    rssi_2g_thresh_low=-50                                         #2.4g RSSI threshold low
    #    rssi_5g_thresh_low=-75                                         #5g RSSI threshold low
    #elif [ "x$country_id" = "xeu" ] ; then
    #    rssi_2g_thresh_low=-50                                         #2.4g RSSI threshold low
    #    rssi_5g_thresh_low=-75                                         #5g RSSI threshold low
    #fi

    select_backhaul_result=${default_dir}select_result
    last_use_result=${default_dir}last_use_result
    disabled_links_result=${default_dir}disabled_links_result
    current_using_backhaul_result=${default_dir}peer_router_ids_mediums

    #if [ "x$work_role" != "xController" ]; then
    #    (sleep 120 ; ifconfig ${itf_24g}.4 down ; sleep 2; ifconfig ${itf_24g}.4 up) ; $sys_logger set ${itf_24g}.4 to down then up &
    #fi 
}

get_my_router_id()
{
    router_id=$(head -1 ${default_dir}router-ids)
    echo $router_id
}

parse_topo()
{
    init_rest_unium_api

    wget -q -O- http://$rest_addr:$rest_port/1/network > ${default_dir}topo
    cat ${default_dir}topo|grep 'hostname' -A 4  |grep router-id |awk '!a[$0]++' | awk -F '[:,]+' '{print $2}' > ${default_dir}router-ids
    cat ${default_dir}topo|grep 'hostname' -A 4  |grep mac-address |awk '!a[$0]++' | awk -F '[:,"]+' '{print toupper($3)}' | sed 's/-/:/g' > ${default_dir}mac-addresses
    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${default_dir}mac-addresses ${default_dir}router-ids > ${default_dir}basemac_router

    cat $auth_file |grep '"mac"' | awk -F '["]' '{print $4}' > ${default_dir}basemac
    cat $auth_file |grep '"wds_2g_mac"' | awk -F '["]' '{print $4}' > ${default_dir}wds_2g_macs
    cat $auth_file |grep '"wds_5g_mac"' | awk -F '["]' '{print $4}' > ${default_dir}wds_5g_macs

    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${default_dir}basemac ${default_dir}wds_2g_macs > ${default_dir}basemac_2g
    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${default_dir}basemac_2g ${default_dir}wds_5g_macs > ${default_dir}basemac_2g_5g

    #awk -F ' ' 'NR==FNR {a[$1]=$0;next}{print a[$1],$2}' ${default_dir}basemac_2g_5g ${default_dir}basemac_router > ${default_dir}basemac_2g_5g_router
    awk -F ' ' 'NR==FNR {a[$1]=$0;next}{print a[$1],$2,$3}' ${default_dir}basemac_router ${default_dir}basemac_2g_5g | sort -t ' ' -k 2n > $parse_topo_result

    if [ "x$enable_debug" = "xtrue" ]
    then
        show_tmp_files
    fi
}

parse_topo_in_bridge()
{
    init_rest_unium_api

    wget -q -O- http://$rest_addr:$rest_port/1/network > ${default_dir}topo
    cat ${default_dir}topo|grep 'hostname' -A 4  |grep router-id |awk '!a[$0]++' | awk -F '[:,]+' '{print $2}' > ${default_dir}router-ids
    cat ${default_dir}topo|grep 'hostname' -A 4  |grep mac-address |awk '!a[$0]++' | awk -F '[:,"]+' '{print toupper($3)}' | sed 's/-/:/g' > ${default_dir}mac-addresses
    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${default_dir}mac-addresses ${default_dir}router-ids > ${default_dir}basemac_router

    my_router_id=$(get_my_router_id)
    root_basemac=$(cat $auth_file |grep '"mac"' | awk -F '["]' '{print $4}')
    cat ${default_dir}basemac_router | grep -v "$root_basemac" | grep -v "$my_router_id" | awk -F ' ' '{print $2}' | sort -k 1n > $parse_topo_result

    if [ "x$enable_debug" = "xtrue" ]
    then
        show_tmp_files
    fi
}

check_wds_itf_status()
{
    band=$1
    mac=$2

    wds_itf=$(wl -i wl$band wds | grep $mac | awk -F ':' '{print $1}')
    if [ "$wds_if" = "" ]
    then
    echo none
    else
    ifconfig | grep $wds_if >/dev/null 2>&1 && echo up || echo down
    fi
}

check_link_available()
{
    wl -i wl$1.4 isup |grep 1 >/dev/null 2>&1 && wl -i wl$1 wds |grep $2 >/dev/null 2>&1 && wl -i wl$1.4 sta_info $2 |grep AUTHORIZED >/dev/null 2>&1 && wl -i wl$1.4 sta_info $2 |grep WDS_LINKUP >/dev/null 2>&1
    res=$?
    [ "$res" = "0" ] && echo " wl$1.4 wds to mac: $2 is OK" >>$log_file || echo "wl$1.4 wds to mac: $2 is INVALID" >>$log_file

    return $res #exist here, no need to check tx,rx; if need to check tx,rx, need to comment this line

    if [ "$res" = "0" ]; then
        wl -i wl$1.4 sta_info $2 > ${default_dir}wds_link_sta_info
        tx_bytes_1=$(cat ${default_dir}wds_link_sta_info | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
        rx_bytes_1=$(cat ${default_dir}wds_link_sta_info | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')

        sleep 1

        wl -i wl$1.4 sta_info $2 > ${default_dir}wds_link_sta_info
        tx_bytes_2=$(cat ${default_dir}wds_link_sta_info | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
        rx_bytes_2=$(cat ${default_dir}wds_link_sta_info | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')

        tx_delta=$((tx_bytes_2-tx_bytes_1))
        rx_delta=$((rx_bytes_2-rx_bytes_1))

        if [ "$tx_delta" = "" -o $tx_delta -le 0 ] || [ "$rx_delta" = "" -o $rx_delta -le 0 ]; then
            res=1
            echo "wl$1.4 wds to mac: $2 status is OK, but tx $tx_delta or rx $rx_delta is INVALID" >>$log_file
            
        else
            res=0
            echo "wl$1.4 wds to mac: $2 status is OK, and tx $tx_delta or rx $rx_delta is OK" >>$log_file
        fi
    fi

    return $res
}

check_link_rssi()
{
    if [ "$1" = "$itf_5g_index" ] ; then
        rssi_thresh_low=$rssi_5g_thresh_low
    else
        rssi_thresh_low=$rssi_2g_thresh_low
    fi

    rssi=`wl -i wl$1.4 rssi $2`
    #rssi=`wl -i wl$1 rssi $2`
    
    echo "wl$1.4 station mac $2 rssi=$rssi" >>$log_file
    echo "rssi_thresh_low is $rssi_thresh_low" >>$log_file
        
    if [ $rssi -ge $rssi_thresh_low -a $rssi -lt 0 ]; then
        return 0
    else
        return 1
    fi
}

check_channel_utilization()
{
    last_backbaul=$1

    channel_utilization_24_obss=$(wl -i $itf_24g chanim_stats |awk 'NR==3' | awk '{printf "%d",$2+$3+$4+$5+$6;}')
    channel_utilization_24_txop=$(wl -i $itf_24g chanim_stats |awk 'NR==3' | awk '{printf "%d",$8;}')
    channel_utilization_5_obss=$(wl -i $itf_5g chanim_stats |awk 'NR==3' | awk '{printf "%d",$2+$3+$4+$5+$6;}')
    channel_utilization_5_txop=$(wl -i $itf_5g chanim_stats |awk 'NR==3' | awk '{printf "%d",$8;}')

    echo channel_utilization_24_obss=$channel_utilization_24_obss >>$log_file
    echo channel_utilization_24_txop=$channel_utilization_24_txop >>$log_file
    echo channel_utilization_5_obss=$channel_utilization_5_obss >>$log_file
    echo channel_utilization_5_txop=$channel_utilization_5_txop >>$log_file
    echo last_backbaul=$last_backbaul  >>$log_file

    if [ "$channel_utilization_24_obss" = "" -o "$channel_utilization_24_txop" = "" -o "$channel_utilization_5_obss" = "" -o "$channel_utilization_5_txop" = "" ] ; then
        echo $itf_5g_index
        return
    fi

    if [ "$channel_utilization_24_obss" -lt "$obss_2g_thresh_good" -a "$channel_utilization_24_txop" -gt "$txop_2g_thresh_good" ] ; then
    #if [ "$channel_utilization_24_obss" -lt "$obss_2g_thresh_good" ] ; then
        is_2g_free="yes"
    else
        is_2g_free="no"
    fi

    if [ "$channel_utilization_5_obss" -lt "$obss_5g_thresh_good" -a "$channel_utilization_5_txop" -gt "$txop_5g_thresh_good" ] ; then
    #if [ "$channel_utilization_5_obss" -lt "$obss_5g_thresh_good" ] ; then
        is_5g_free="yes"
    else
        is_5g_free="no"
    fi

    if [ "$channel_utilization_5_obss" -gt "$obss_5g_thresh_bad" -o "$channel_utilization_5_txop" -lt "$txop_5g_thresh_bad" ] ; then
    #if [ "$channel_utilization_5_obss" -gt "$obss_5g_thresh_bad" ] ; then
        is_5g_busy="yes"
    else
        is_5g_busy="no"
    fi 

    if [ "$is_2g_free" = "yes" -a "$is_5g_busy" = "yes" ] ; then
        echo $itf_24g_index
    elif [ "$last_backbaul" = "$itf_24g_index" -a "$is_5g_free" = "no" ] ; then
        echo $itf_24g_index
    else
        echo $itf_5g_index
    fi
}

get_total_speed()
{
    router_id=$1
    mac_2g=$2
    mac_5g=$3
    
    wl -i ${itf_5g}.4 sta_info $mac_5g > ${default_dir}wds_5g_sta_info_1
    wl -i ${itf_24g}.4 sta_info $mac_2g > ${default_dir}wds_2g_sta_info_1
    wds_5g_total_tx_bytes_1=$(cat ${default_dir}wds_5g_sta_info_1 | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
    wds_5g_total_rx_bytes_1=$(cat ${default_dir}wds_5g_sta_info_1 | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')
    wds_2g_total_tx_bytes_1=$(cat ${default_dir}wds_2g_sta_info_1 | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
    wds_2g_total_rx_bytes_1=$(cat ${default_dir}wds_2g_sta_info_1 | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')

    sleep 1

    wl -i ${itf_5g}.4 sta_info $mac_5g > ${default_dir}wds_5g_sta_info_2
    wl -i ${itf_24g}.4 sta_info $mac_2g > ${default_dir}wds_2g_sta_info_2
    wds_5g_total_tx_bytes_2=$(cat ${default_dir}wds_5g_sta_info_2 | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
    wds_5g_total_rx_bytes_2=$(cat ${default_dir}wds_5g_sta_info_2 | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')
    wds_2g_total_tx_bytes_2=$(cat ${default_dir}wds_2g_sta_info_2 | grep "tx total bytes" | awk -F '[: ]+' '{print $5}')
    wds_2g_total_rx_bytes_2=$(cat ${default_dir}wds_2g_sta_info_2 | grep "rx data bytes" | awk -F '[: ]+' '{print $5}')
    
    total_bytes=$(((wds_5g_total_tx_bytes_2-wds_5g_total_tx_bytes_1) + (wds_5g_total_rx_bytes_2-wds_5g_total_rx_bytes_1) + (wds_2g_total_tx_bytes_2-wds_2g_total_tx_bytes_1) + (wds_2g_total_rx_bytes_2-wds_2g_total_rx_bytes_1)))
    
    echo $total_bytes
}

get_last_backhaul()
{
    peer_router_id=$1
    if [ -e $last_use_result ]; then
        medium=$(cat $last_use_result | grep $peer_router_id | awk -F ' ' '{print $3}')
        if [ "$medium" = "wifi-24" ]; then
            echo $itf_24g_index
        elif [ "$medium" = "wifi-5" ]; then
            echo $itf_5g_index
        else
            echo "-1"
        fi
    else
        echo "-1"
    fi
}

waiting_for_wds_recover()
{
    wait_count=0
    max_wait_cout=2
    band=$1   #itf_5g_index means 5g, itf_24g_index means 2.4g
    peer_wds_mac=$2
    
    #5s is OK for most case 
    while [ $wait_count -lt $max_wait_cout ]
    do
        sleep 2
        check_link_available $band $peer_wds_mac && break
        wait_count=$((wait_count+1))
    done
}


#bh_decision route-id xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx
#
# itf_24g_index : 2.4G prefer
# itf_5g_index : 5G prefer
# output: string "band_index flow_size"
bh_decision()
{
    res=$itf_5g_index
    link_ready_24=1
    link_ready_5=1
    
    router_id=$1
    mac_24g=$2
    mac_5g=$3
    
    last_backbaul=$(get_last_backhaul $router_id)
    
    check_link_available $itf_24g_index $mac_24g || link_ready_24=0
    check_link_available $itf_5g_index $mac_5g || link_ready_5=0
    
    total_bytes=$(get_total_speed $router_id $mac_24g $mac_5g) 

    #why I don't move check_link_rssi check_channel_utilization and wds intf link status here? To avoid call every time to cause cpu busy!
    
    echo "chuangyz=================handle router_id $router_id" >>$log_file    

    if [ $link_ready_24 -eq 1 -a $link_ready_5 -eq 1 ]; then #both 2.4g and 5g and OK
        check_link_rssi $itf_24g_index $mac_24g && rssi_24g_good=1 || rssi_24g_good=0
        check_link_rssi $itf_5g_index $mac_5g && rssi_5g_good=1 || rssi_5g_good=0
        if [ $rssi_24g_good -eq $rssi_5g_good ]; then #both 2.4g and 5g rssi are ok or nok
            utilization=$(check_channel_utilization $last_backbaul)
            [ "$utilization" = "$itf_24g_index" ] && res=$itf_24g_index || res=$itf_5g_index
            [ "$last_backbaul" != "$itf_24g_index" -a "$res" = "$itf_24g_index" -a $total_bytes -gt $total_2g_thresh_1s_bytes ] && echo "$itf_5g_index" "$total_bytes" || echo "$res" "$total_bytes"    
            echo "[1]res is $res, speed is $total_bytes" >>$log_file
        elif [ $rssi_24g_good -eq 1 ]; then #only 2.4g rssi is ok, so have to select 2.4g
            res=$itf_24g_index
            echo "$res" "0"
        else       #only 5g rssi is ok
            res=$itf_5g_index
            echo "$res" "$total_bytes"
        fi
    elif [ $link_ready_5 -eq 1 ]; then #only 5g is ok, but may be 2.4 is down because 2.4g wds intf init status is down, so need to check if need to enable it.
        check_link_rssi $itf_24g_index $mac_24g && rssi_24g_good=1 || rssi_24g_good=0
        check_link_rssi $itf_5g_index $mac_5g && rssi_5g_good=1 || rssi_5g_good=0
        if [ $rssi_24g_good -eq $rssi_5g_good ]; then #both 2.4g and 5g rssi are ok or nok
            utilization=$(check_channel_utilization $last_backbaul)
            [ "$utilization" = "$itf_24g_index" ] && res=$itf_24g_index || res=$itf_5g_index
            [ "$last_backbaul" != "$itf_24g_index" -a "$res" = "$itf_24g_index" -a $total_bytes -gt $total_2g_thresh_1s_bytes ] && res=$itf_5g_index    
            
            wds_2g_if_status="none" #init to none
            if [ "$res" = "$itf_24g_index" ]; then #prefer 2.4g
                wds_2g_if=$(wl -i $itf_24g wds | grep $mac_24g | awk -F ':' '{print $1}')
                if [ "$wds_2g_if" == "" ]; then
                    wds_2g_if_status="none"
                else
                    ifconfig |grep $wds_2g_if >/dev/null 2>&1 && wds_2g_if_status="up" || wds_2g_if_status="down"
                fi
            fi
            if [ "$wds_2g_if_status" = "down" ]; then  #when prefer 2.4g, and 2.4g wds intf is down
                echo "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[only 5g wds ok, but 2.4g utilization is free, 5g is busy]" >>$log_file
                $sys_logger "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[only 5g wds ok, but 2.4g utilization is free, 5g is busy]" >/dev/null 2>&1  
 
                ifconfig $wds_2g_if up
                waiting_for_wds_recover $itf_24g_index $mac_24g #waiting for 2.4g wds stable
                bh_decision $router_id $mac_24g $mac_5g   #up 2.4g wds intf and re-check
            else  #2.4g wds is maybe not caused by 2.4g wds intf down, because currently 5g is OK, so select 5g
                echo "$itf_5g_index" "$total_bytes"
            fi  
        elif [ $rssi_24g_good -eq 1 ]; then #only 2.4g rssi is ok
            wds_2g_if_status="none" #init to none
            wds_2g_if=$(wl -i $itf_24g wds | grep $mac_24g | awk -F ':' '{print $1}')
            if [ "$wds_2g_if" == "" ]; then
                wds_2g_if_status="none"
            else
                ifconfig |grep $wds_2g_if >/dev/null 2>&1 && wds_2g_if_status="up" || wds_2g_if_status="down"
            fi
            if [ "$wds_2g_if_status" = "down" ]; then #prefer 2.4g, and 2.4g wds intf is down
                echo "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[only 5g wds ok, but 2.4g rssi is good, 5g rssi is bad]" >>$log_file    
                $sys_logger "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[only 5g wds ok, but 2.4g rssi is good, 5g rssi is bad]" >/dev/null 2>&1
                
                ifconfig $wds_2g_if up
                waiting_for_wds_recover $itf_24g_index $mac_24g #waiting for 2.4g wds stable
                bh_decision $router_id $mac_24g $mac_5g #up 2.4g wds intf and re-check
            else    #2.4g wds is maybe not caused by 2.4g wds intf down, because currently 5g is OK, so select 5g
                echo "$itf_5g_index" "$total_bytes"
            fi
        else   #only 5g rssi is ok
            res=$itf_5g_index
            echo "$res" "$total_bytes"
        fi
    
    elif [ $link_ready_24 -eq 1 ]; then  #only 2.4g is ok, because currently 5g always init to up, so no need to check 5g wds intf link status here.
        res=$itf_24g_index
        echo "$res" "0"
    else   #both 2.4g and 5g are down
        #if [ "$total_bytes" = "0" -o "$total_bytes" = "" ];  then #maybe peer is power down or offline
        #    echo "$itf_5g_index" "$total_bytes"  #set 5g as default.
        #else   #may be 2.4 is down because 2.4g wds intf init status is down, so need to check if need to enable it.
            wds_2g_if_status="none" #init to none
            wds_2g_if=$(wl -i $itf_24g wds | grep $mac_24g | awk -F ':' '{print $1}')
            if [ "$wds_2g_if" == "" ]; then
                wds_2g_if_status="none"
            else
                ifconfig |grep $wds_2g_if >/dev/null 2>&1 && wds_2g_if_status="up" || wds_2g_if_status="down"
            fi
            if [ "$wds_2g_if_status" = "down" ]; then
                echo "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[both 2.4g and 5g wds failed]" >>$log_file    
                $sys_logger "To $router_id 2.4g down maybe because 2.4g wds interface down, so up it and waiting 5s for wds stable. and re-check bh_decision[both 2.4g and 5g wds failed]" >/dev/null 2>&1 
                local radio_2g_isup=`wl -i $itf_24g isup`
                if [ "x$radio_2g_isup" = "x1" ]; then
                    echo "2.4G radio is up, so we can up 2.4G wds interface" >>$log_file
                    ifconfig $wds_2g_if up
                    waiting_for_wds_recover $itf_24g_index $mac_24g #waiting for 2.4g wds stable
                    bh_decision $router_id $mac_24g $mac_5g
                else
                    echo "2.4G radio is down, so we can NOT up 2.4G wds interface" >>$log_file
                fi
            else
                echo "$itf_5g_index" "$total_bytes"
            fi
        #fi
    fi
}

set_backhaul_link()
{
    enable=$1
    medium="wifi-5"

    if [ "x$2" = "xwifi-24" ]
    then
        medium="wifi-24"
    fi

    router1_id=$3
    router2_id=$4

    init_rest_unium_api

    if [ "x$enable" = "xdisable" ]
    then
        echo "====Disable $router1_id and $router2_id $medium"
        echo
        echo "curl -is -X PUT -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links"

        $sys_logger "====Disable $router1_id and $router2_id $medium"
        $sys_logger "curl -is -X PUT -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links"
        
        curl -is -X PUT -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links

    else
        echo "====Enable $router1_id and $router2_id $medium"
        echo
        echo "curl -is -X DELETE -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links"

        $sys_logger "====Enable $router1_id and $router2_id $medium"
        $sys_logger "curl -is -X DELETE -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links"
        
        curl -is -X DELETE -H "Content-Type: application/json" -d "{\"router1\":$router1_id,\"router2\":$router2_id,\"medium\":\"$medium\"}" http://$rest_addr:$rest_port/1/disabled-links

    fi
}

select_backhaul()
{
    selected_2g=0
    selected_5g=0
    parse_file=$1

    my_router_id=$(get_my_router_id)

    while read basemac router_id wds_2g_mac wds_5g_mac
    do
        if [ "x$basemac" != "x" -a "x$wds_2g_mac" != "x" -a "x$wds_5g_mac" != "x" -a "x$router_id" != "x" -a "x$my_router_id" != "x" ]
        then
            res=$(bh_decision "$router_id" "$wds_2g_mac" "$wds_5g_mac")
            
            echo "$router_id" "$res" >>${select_backhaul_result}sbh_tmp
            
            #select=$(bh_decision "$router_id" "$wds_2g_mac" "$wds_5g_mac")
            #if [ "$selected_2g"="1" -a "$select" = "$itf_24g_index" ]
            #then
            #    echo "$my_router_id" "$router_id" "wifi-5" >>$select_backhaul_result
            #else
            #    if [ "$select" = "$itf_24g_index" ]
            #    then
            #        selected_2g=1
            #        echo "$my_router_id" "$router_id" "wifi-24" >>$select_backhaul_result
            #    else
            #        echo "$my_router_id" "$router_id" "wifi-5" >>$select_backhaul_result
            #    fi
            #fi
        fi

    done < $parse_file

    test -e ${select_backhaul_result}sbh_tmp && sort -t ' ' -k 3n ${select_backhaul_result}sbh_tmp > ${select_backhaul_result}sbh_tmp_sort

    print_cmd_and_result "cat ${select_backhaul_result}sbh_tmp_sort"

    beacons_num=$(cat ${select_backhaul_result}sbh_tmp_sort | grep ' ' -c)
    beacon_count=0


    while read router_id band_index flow_size
    do
        if [ "x$router_id" != "x" -a "x$band_index" != "x" -a "x$flow_size" != "x" ] ; then
            
            let beacon_count=beacon_count+1
        
            if [ "$band_index" = "$itf_24g_index" -a "$flow_size" = "0" ] ; then
                echo "$my_router_id" "$router_id" "wifi-24" >>${select_backhaul_result}no_sort
                selected_2g=1
            elif [ "$band_index" = "$itf_24g_index" -a "$selected_2g" = "0" ] ; then
                echo "$my_router_id" "$router_id" "wifi-24" >>${select_backhaul_result}no_sort
                selected_2g=1
            elif [ "$band_index" = "$itf_5g_index" -a "$flow_size" = "0" ] ; then
                echo "$my_router_id" "$router_id" "wifi-5" >>${select_backhaul_result}no_sort
            elif [ "$band_index" = "$itf_5g_index" ] ; then
                echo "$my_router_id" "$router_id" "wifi-5" >>${select_backhaul_result}no_sort
                selected_5g=1
            #elif [ "$band_index" = "2" -a "$selected_2g" = "0" ] && [ "$selected_5g" = "1" -o $beacon_count -lt $beacons_num ] ; then
            #    echo "$my_router_id" "$router_id" "wifi-24" >>${select_backhaul_result}no_sort
            #    selected_2g=1
            else
                echo "$my_router_id" "$router_id" "wifi-5" >>${select_backhaul_result}no_sort
                selected_5g=1
            fi
        else
            let beacons_num=beacons_num-1
        fi    
    done < ${select_backhaul_result}sbh_tmp_sort

    cat ${select_backhaul_result}no_sort | sort -t ' ' -k 2n >${select_backhaul_result}

    rm -f ${select_backhaul_result}sbh_tmp ${select_backhaul_result}sbh_tmp_sort ${select_backhaul_result}no_sort
}

select_backhaul_in_bridge_between_beacon()
{
    parse_file=$1
    medium=$2

    my_router_id=$(get_my_router_id)

    touch $select_backhaul_result

    while read router_id
    do
        echo "$my_router_id" "$router_id" "$medium" >>$select_backhaul_result
    done < $parse_file

}

get_disabled_links()
{
    result_file=$1
   
    init_rest_unium_api
 
    wget -q -O- http://$rest_addr:$rest_port/1/disabled-links >${result_file}tmp

    cat ${result_file}tmp |grep "router1" | awk -F '[:,]+' '{print $2}' >${result_file}router1
    cat ${result_file}tmp |grep "router2" | awk -F '[:,]+' '{print $2}' >${result_file}router2
    cat ${result_file}tmp |grep "medium" | awk -F '[":,]+' '{print $3}' >${result_file}medium

    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${result_file}router1 ${result_file}router2 > ${result_file}router1_router2
    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${result_file}router1_router2 ${result_file}medium | sort -t ' ' -k 1n > ${result_file}

    rm -f ${result_file}tmp ${result_file}router1 ${result_file}router2  ${result_file}medium ${result_file}router1_router2
}

set_peer_router_wds_itf_status()
{
    peer_router=$1
    medium=$2
    enable=$3

    #if [ "x$work_role" != "xController" ]; then
    #    return
    #fi
  
    if [ $medium = "wifi-24" ]; then
        wds_mac=$(cat $parse_topo_result | grep $peer_router | awk -F ' ' '{print $3}')
        [ "$wds_mac" != "" ] && wds_itf=$(wl -i $itf_24g wds | grep $wds_mac | awk -F ':' '{print $1}')
    else
        wds_mac=$(cat $parse_topo_result | grep $peer_router | awk -F ' ' '{print $4}')
        [ "$wds_mac" != "" ] && wds_itf=$(wl -i $itf_5g wds | grep $wds_mac | awk -F ':' '{print $1}')
    fi

    if [ "$wds_itf" != "" ]; then
        if [ "$enable" = "enable" ]; then

            #! (ifconfig | grep $wds_itf >/dev/null 2>&1) && ifconfig $wds_itf up && sleep 1 && wl -i $wds_itf up && echo "set $peer_router $medium $wds_itf to up !!!"
            ! (ifconfig | grep $wds_itf >/dev/null 2>&1) && ifconfig $wds_itf up && sleep 1 && echo "set $peer_router $medium $wds_itf to up !!!" && $sys_logger "set $peer_router $medium $wds_itf to up !!!"
        else

            #ifconfig | grep $wds_itf >/dev/null 2>&1 && ifconfig $wds_itf down && sleep 1 && wl -i $wds_itf down && echo "set $peer_router $medium $wds_itf to down !!!"
            ifconfig | grep $wds_itf >/dev/null 2>&1 && ifconfig $wds_itf down && sleep 1 && echo "set $peer_router $medium $wds_itf to down !!!" && $sys_logger "set $peer_router $medium $wds_itf to down !!!"
        fi
    fi
}

check_peer_router_wds_link()
{
    peer_router=$1
    medium=$2

    if [ $medium = "wifi-24" ]; then
        wds_mac=$(cat $parse_topo_result | grep $peer_router | awk -F ' ' '{print $3}')
        [ "$wds_mac" != "" ] && check_link_available $itf_24g_index $wds_mac && return 0 || return 1
    else
        wds_mac=$(cat $parse_topo_result | grep $peer_router | awk -F ' ' '{print $4}')
        [ "$wds_mac" != "" ] && check_link_available $itf_5g_index $wds_mac && return 0 || return 1
    fi
}


backhaul_switch()
{
    parse_file=$1

    let switch_count=switch_count+1
    echo "================switch_count=$switch_count"
    echo

    while read my_router_id peer_router_id medium
    do
        if [ "x$my_router_id" != "x" -a "x$peer_router_id" != "x" -a "x$medium" != "x" ];then

            get_disabled_links $disabled_links_result

            if [ "x$medium" = "xwifi-24" ];then
                set_peer_router_wds_itf_status $peer_router_id "wifi-24" "enable"         
                #if (check_peer_router_wds_link $peer_router_id "wifi-24" >/dev/null 2>&1); then
                    cat $disabled_links_result |grep "wifi-24" |grep $my_router_id |grep  $peer_router_id && set_backhaul_link enable "wifi-24" $my_router_id $peer_router_id && sleep 2
                    ! cat $disabled_links_result |grep "wifi-5" |grep $my_router_id |grep  $peer_router_id && set_backhaul_link disable "wifi-5" $my_router_id $peer_router_id && sleep 2
                    #set_peer_router_wds_itf_status $peer_router_id "wifi-5" "disable"
                #fi
            else
                #set_peer_router_wds_itf_status $peer_router_id "wifi-5" "enable"
                #if [ "$work_role" != "Controller" ] || (check_peer_router_wds_link $peer_router_id "wifi-5" >/dev/null 2>&1); then  #we always select 5g between beacons
                    cat $disabled_links_result |grep "wifi-5" |grep $my_router_id |grep  $peer_router_id && set_backhaul_link enable "wifi-5" $my_router_id $peer_router_id && sleep 2
                    ! cat $disabled_links_result |grep "wifi-24" |grep $my_router_id |grep  $peer_router_id && set_backhaul_link disable "wifi-24" $my_router_id $peer_router_id && sleep 2
                    [ "$work_role" = "Controller" ] && (check_peer_router_wds_link $peer_router_id "wifi-5" >/dev/null 2>&1) && set_peer_router_wds_itf_status $peer_router_id "wifi-24" "disable"
                #fi
            fi
        fi
    done < $parse_file

    cp $parse_file $last_use_result

    echo "=========================================="
}

save_main_log()
{
    print_cmd_and_result "cat $parse_topo_result"
    print_cmd_and_result "cat $disabled_links_result"
    print_cmd_and_result "cat $select_backhaul_result"
    print_cmd_and_result "cat $last_use_result"
}

get_work_role()
{
    while [ "x$work_role" != "xAgent" -a "x$work_role" != "xController" ]
    do
        sleep $interval
        work_role=`cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole | cut -d = -f 2`
    done
    echo $work_role
}

check_log_file()
{
    log_size=$(ls -all $log_file | awk -F ' ' '{print $5}')
    if [ $log_size -ge $max_log_size ]
    then
        more >$log_file
    fi
}

detect_current_env()
{
    let detect_count=detect_count+1
    echo "==========================detect_count=$detect_count=========================="

    clear_last_files

    if [ "x$work_role" = "xController" ]
    then
        parse_topo
        select_backhaul $parse_topo_result
    else
        parse_topo_in_bridge
        select_backhaul_in_bridge_between_beacon $parse_topo_result "wifi-5"
    fi
    get_disabled_links $disabled_links_result
    save_main_log

    #echo "==========================detect_count=$detect_count=========================="    
}

waiting_for_stabilizing()
{
    count=0
    last_result_tmp=${default_dir}last_result_tmp

    cp $select_backhaul_result $last_result_tmp

    while [ $count -lt $stability_detect_count ]
    do
        sleep $interval
        check_log_file

        detect_current_env #will get new $select_backhaul_result

        is_change=$(diff $last_result_tmp $select_backhaul_result >/dev/null 2>&1 ;echo $?)
        if [ "$is_change" = "0" ]
        then
            let count=count+1
        else
            count=0
        fi

        echo chuangyz count=$count !!!!!!!!!!!!!!!!!

        cp $select_backhaul_result $last_result_tmp

    done

    rm -f $last_result_tmp
}

get_using_backhaul() 
{
    init_rest_unium_api

    wget -q -O- http://$rest_addr:$rest_port/1/network >${default_dir}topo_tmp
    cat ${default_dir}topo_tmp | awk '/mesh-peers/{p=1} /links/{print;exit}p' | grep router-id | awk -F '[:,]+' '{print $2}' > ${default_dir}peer_router_ids
    cat ${default_dir}topo_tmp | awk '/mesh-peers/{p=1} /links/{print;exit}p' | grep medium | awk -F '"' '{print $4}' > ${default_dir}peer_mediums

    awk 'NR==FNR {a[NR]=$0} NR>FNR {print a[FNR],$0}' ${default_dir}peer_router_ids ${default_dir}peer_mediums | sort -t ' ' -k 1n > $current_using_backhaul_result

    cp $current_using_backhaul_result $1

    rm -f ${default_dir}peer_router_ids ${default_dir}peer_mediums ${default_dir}topo_tmp
}

#base on using backhaul or disabled backhaul changed
check_set_flow_cache()
{

    last_result_tmp=${default_dir}last_using_backhaul
    current_result=${default_dir}current_using_backhaul

    my_router_id=$(get_my_router_id)
    all_disabled_link=${default_dir}all_disabled_link
    last_my_disabled_link=${default_dir}last_my_disabled_link
    current_my_disabled_link=${default_dir}current_my_disabled_link


    get_using_backhaul $last_result_tmp
    get_disabled_links $all_disabled_link
    cat $all_disabled_link |grep $my_router_id  >$last_my_disabled_link

    while true
    do
        sleep $check_flow_cache_interval
        check_log_file

        get_using_backhaul $current_result
        get_disabled_links $all_disabled_link
        cat $all_disabled_link |grep $my_router_id  >$current_my_disabled_link        

        print_cmd_and_result "cat $current_result"
        print_cmd_and_result "cat $current_my_disabled_link"

        is_using_backhaul_change=$(diff $current_result $last_result_tmp >/dev/null 2>&1 ;echo $?)
        is_my_disabled_backhaul_change=$(diff $current_my_disabled_link $last_my_disabled_link >/dev/null 2>&1 ;echo $?)

        # Only when both changed we'll flush flow cache
        if [ "$is_using_backhaul_change" = "0" -o "$is_my_disabled_backhaul_change" = "0" ]
        then
            echo "My Backhaul is the same as last time, no need flush flow cache."
        else
            echo "My Backhaul is changed, is_using_backhaul_change=$is_using_backhaul_change, is_my_disabled_backhaul_change=$is_my_disabled_backhaul_change. flush flow cache!!!!!!!!!!!!!!!!!!!!!!!"
            $sys_logger "My Backhaul is changed, is_using_backhaul_change=$is_using_backhaul_change, is_my_disabled_backhaul_change=$is_my_disabled_backhaul_change. flush flow cache!!!!!!!!!!!!!!!!!!!!!!!" 
            fcctl flush
        fi

        cp $current_result $last_result_tmp
        cp $current_my_disabled_link $last_my_disabled_link
    done
}

#base on disabled links
check_set_flow_cache_base_on_disabled_links()
{
    my_router_id=$(get_my_router_id)

    all_disabled_link=${default_dir}all_disabled_link
    last_result_tmp=${default_dir}my_disabled_links_tmp
    current_result=${default_dir}my_disabled_links

    get_disabled_links $all_disabled_link
    cat $all_disabled_link |grep $my_router_id  >$last_result_tmp

    while true
    do
        sleep $check_flow_cache_interval
        check_log_file

        get_disabled_links $all_disabled_link
        cat $all_disabled_link |grep $my_router_id  >$current_result

        is_change=$(diff $current_result $last_result_tmp >/dev/null 2>&1 ;echo $?)
        if [ "$is_change" = "0" ]
        then
            echo "My Backhaul is the same as last time, no need flush flow cache."
        else
            echo "My Backhaul is changed, flush flow cache!!!!!!!!!!!!!!!!!!!!!!!"
            fcctl flush
        fi

        cp $current_result $last_result_tmp
    done
}

backhaul_with_root_heal()
{
    if [ "x$work_role" = "xAgent" ]; then
        my_router_id=$(get_my_router_id)
        root_basemac=$(cat $auth_file |grep '"mac"' | awk -F '["]' '{print $4}')
        root_router_id=$(cat ${default_dir}basemac_router |grep $root_basemac | awk '{print $2}')
        root_wds_5g_mac=$(cat $auth_file |grep wds_5g_mac |  awk -F '["]' '{print $4}')
        root_wds_2g_mac=$(cat $auth_file |grep wds_2g_mac |  awk -F '["]' '{print $4}')

        get_disabled_links $disabled_links_result
        cat $disabled_links_result |grep "wifi-24" |grep $my_router_id |grep $root_router_id && {
            ! (check_link_available $itf_5g_index $root_wds_5g_mac) || ! (ifconfig br0 |grep "inet addr" >/dev/null 2>&1)
        } && check_link_available $itf_24g_index $root_wds_2g_mac && set_backhaul_link enable "wifi-24" $my_router_id $root_router_id
        cat $disabled_links_result |grep "wifi-5" |grep $my_router_id |grep $root_router_id && {
            ! (check_link_available $itf_24g_index $root_wds_2g_mac) || ! (ifconfig br0 |grep "inet addr" >/dev/null 2>&1)
        } && check_link_available $itf_5g_index $root_wds_5g_mac && set_backhaul_link enable "wifi-5" $my_router_id $root_router_id

    fi
}

set_slave_role_wds_if()
{
    if [ "x$work_role" = "xAgent" ]; then

        #root_wds_5g_mac=$(cat $auth_file |grep wds_5g_mac |  awk -F '["]' '{print $4}')
        #root_wds_5g_if=$(wl -i $itf_5g wds |grep -i $root_wds_5g_mac | awk -F ':' '{print $1}')
        
        root_wds_2g_mac=$(cat $auth_file |grep wds_2g_mac |  awk -F '["]' '{print $4}')
        root_wds_2g_if=$(wl -i $itf_24g wds |grep -i $root_wds_2g_mac | awk -F ':' '{print $1}')
        
        wds_2g_ifs=$(wl -i $itf_24g wds | grep wds | awk -F ':' '{print $1}')
        
        for itf in $wds_2g_ifs
        do
            #set all 2.4g wds interface between beacons to down
            #[ "$root_wds_2g_if" != "" ] && [ "$itf" != "$root_wds_2g_if" ] && ifconfig $itf down && echo set wds interface $itf to beacon down && $sys_logger "set wds interface $itf to beacon down"
            [ "$root_wds_2g_if" != "" ] && [ "$itf" != "$root_wds_2g_if" ] && ifconfig | grep $itf >/dev/null 2>&1 && ifconfig $itf down && echo set wds interface $itf to beacon down && $sys_logger "set wds interface $itf to beacon down"
        done    
    fi
}

recover_wds_if()
{
    echo "Recover wds interface..."
    $sys_logger "Recover wds interface..."

    wds_2g_ifs=$(wl -i $itf_24g wds | grep wds | awk -F ':' '{print $1}')

    for itf in $wds_2g_ifs
    do
        #set all 2.4g wds interface up
        ifconfig $itf up && echo set wds interface $itf to up && $sys_logger "set wds interface $itf to up" && sleep 2
    done    
}

check_backhaul_main_loop()
{
    echo "Start backhaul selector main loop, current work role is $work_role"
    $sys_logger "Start backhaul selector main loop, current work role is $work_role"

    detect_current_env    
    waiting_for_stabilizing

    check_set_flow_cache &

    backhaul_switch $select_backhaul_result

    while true
    do
        sleep $interval
        check_log_file

        waiting_for_stabilizing

        backhaul_switch $select_backhaul_result #will check unium disabled-links inner

        backhaul_with_root_heal

        set_slave_role_wds_if

        #is_change=$(diff $last_use_result $select_backhaul_result >/dev/null 2>&1 ;echo $?)
        #if [ "$is_change" = "0" ]
        #then
        #    echo "Backhaul is the same as last time, no need switch."
        #else    
        #    backhaul_switch $select_backhaul_result
        #fi

    done
}


if [ $# -eq 1 -o $# -eq 0 ]; then
    [ $# -eq 1 ] && start_time=$1

    echo "Enter startup backhaul selector script. Include adapt 2.4g/5g inteface version" >>$log_file 2>&1
    $sys_logger "Enter startup backhaul selector script. Include adapt 2.4g/5g inteface version"

    get_work_role
    sleep $start_time
    init

    check_backhaul_main_loop >>$log_file 2>&1 &
elif [ $# -eq 2 -a "$1" = "recover" -a "$2" = "quit" ]; then
    #get_work_role
    init
    recover_wds_if >>$log_file 2>&1 &

    echo "Quit backhaul selector script. Include adapt 2.4g/5g inteface version" >>$log_file 2>&1
    $sys_logger "Quit backhaul selector script. Include adapt 2.4g/5g inteface version"
fi


