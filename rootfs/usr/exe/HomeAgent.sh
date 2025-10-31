#! /bin/sh
# script to start L1/L2 processes for bcm boards #

UBUSD="/sbin/ubusd"
FONENDOSCOPE="/usr/bin/fonendoscope"
CLAIM="/etc/init.d/claim start"
#APCLOUD_WATCHDOG="/usr/bin/apcloud_watchdog"
#APCLOUD="/usr/bin/apcloud /etc/config/ apcloud"
UCI_CONFIG_DIR="/configs/etc/config"

#Calling Homeagent migration script
[ -f /usr/exe/home_agent_migration.sh ] && sh /usr/exe/home_agent_migration.sh

print_help()
{
    echo "Usage:"
    echo "$0 -[option] [value]"
    echo "-o <Start_L1/Start_L2/Restart_L1/Restart_L2/Stop_L1/Stop_L2>"
    echo "for L1 pass below params:"
    echo "-l L1url"
    echo "-u L1username"
    echo "-p L1password"
    echo "for L2 pass below params"
    echo "-m L2url"
    echo "-q L2username"
    echo "-t L2password"
    echo "-h help"
}

start_common_processes()
{
    if [ -z `ps w | grep $UBUSD | grep -v grep` ]
    then
        $UBUSD &
    fi

    if [ -z `ps w | grep $FONENDOSCOPE | grep -v grep` ]
    then
        $FONENDOSCOPE &
    fi

    sleep 5

    if [ -z `ps w | grep capin | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"capin"}'
    fi

    if [ -z `ps w | grep meshintf | grep -v grep` ]
    then
	ubus call fonendoscope start '{"process":"meshintf"}'
    fi

    if [ -z `ps w | grep dhcpmon | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"dhcpmon"}'
    fi

    if [ -z `ps w | grep rpcd | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"rpcd"}'
    fi

    $CLAIM &
}

start_fonendoscope_child_processes()
{
    if [ -z `ps w | grep boardd | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"boardd"}'
    fi

    if [ -z `ps w | grep plasmodium | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"plasmodium"}'
    fi

    if [ -z `ps w | grep wifimon | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"wifimon"}'
    fi

    if [ -z `ps w | grep nemo | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"nemo"}'
    fi

    if [ -z `ps w | grep ustatusd | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"ustatusd"}'
    fi

    if [ -z `ps w | grep bw_ookla | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"bw_ookla"}'
    fi
    
    if [ -z `ps w | grep log_agent | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"log_agent"}'
    fi
    
    if [ -z `ps w | grep dhcpmon | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"dhcpmon"}'
    else
        ubus call fonendoscope restart '{"process":"dhcpmon"}'
    fi
}

validate_url()
{
    mode=`echo "$1" | cut -d':' -f1`
    if [ $mode == "http" -o $mode == "https" ]
    then
        echo "" 
    else
        echo "provide full url with port"
        exit 1
    fi
}

start_L1_processes()
{
    validate_url $L1url

    mqtt_mode=`echo "$L1url" | cut -d':' -f1`
    mqtt_server=`echo "$L1url" | cut -d'/' -f3 | cut -d':' -f1`
    mqtt_port=`echo "$L1url" | cut -d':' -f3 | cut -d'/' -f1`

    if [ -z "$mqtt_port" ]
    then
        if [ "$mqtt_mode" == "http" ]
        then
            mqtt_port=80
        else
            mqtt_port=443
        fi
    fi

    iptables -D INPUT -j NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -F NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -X NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -N NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -I INPUT -j NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    l2_port=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get apcloud.main.port`
    if [ -z $l2_port ]
    then
        echo "L2 port is empty"
    else
        iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $l2_port -j ACCEPT 2> /var/rutIpt_updateACLRules
        iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $l2_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    fi
    old_port=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get plasmodium.mqtt.port`
    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $old_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $mqtt_port -j ACCEPT  2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT  2> /var/rutIpt_updateACLRules

    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.host=$mqtt_server
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.port=$mqtt_port
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.client_id=$L1username
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.user.username=$L1username
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.user.password=$L1password
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} commit plasmodium
    start_fonendoscope_child_processes   
}

restart_L1_processes()
{
    mqtt_server=`echo "$L1url" | cut -d'/' -f3 | cut -d':' -f1`
    mqtt_port=`echo "$L1url" | cut -d':' -f3 | cut -d'/' -f1`

    if [ -z "$mqtt_port" ]
    then
        if [ "$mqtt_mode" == "http" ]
        then
            mqtt_port=80
        else
            mqtt_port=443
        fi
    fi

    old_port=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get plasmodium.mqtt.port`

    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $old_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $mqtt_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $mqtt_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT  2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT  2> /var/rutIpt_updateACLRules
    
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.host=$mqtt_server
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.port=$mqtt_port
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.mqtt.client_id=$L1username
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.user.username=$L1username
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set plasmodium.user.password=$L1password
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} commit plasmodium
    if [ -z `ps w | grep plasmodium | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"plasmodium"}'
    else
        ubus call fonendoscope restart '{"process":"plasmodium"}'
    fi
    
    if [ -z `ps w | grep dhcpmon | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"dhcpmon"}'
    else
        ubus call fonendoscope restart '{"process":"dhcpmon"}'
    fi
    
    if [ -z `ps w | grep wifimon | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"wifimon"}'
    else
        ubus call fonendoscope restart '{"process":"wifimon"}'
    fi

    if [ -z `ps w | grep ustatusd | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"ustatusd"}'
    else
        ubus call fonendoscope restart '{"process":"ustatusd"}'
    fi

    if [ -z `ps w | grep boardd | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"boardd"}'
    fi

    if [ -z `ps w | grep nemo | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"nemo"}'
    fi

    if [ -z `ps w | grep bw_ookla | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"bw_ookla"}'
    fi
    
    if [ -z `ps w | grep log_agent | grep -v grep` ]
    then
        ubus call fonendoscope start '{"process":"log_agent"}'
    fi
    
}

start_L2_processes()
{
    validate_url $L2url
    apcloud_mode=`echo "$L2url" | cut -d':' -f1`
    apcloud_server=`echo "$L2url" | cut -d'/' -f3 | cut -d':' -f1`
    apcloud_port=`echo "$L2url" | cut -d':' -f3 | cut -d'/' -f1`

    if [ -z "$apcloud_port" ]
    then
        if [ "$apcloud_mode" == "http" ]
        then
            apcloud_port=80
        else
            apcloud_port=443
        fi
    fi

    iptables -D INPUT -j NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -F NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -X NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -N NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    iptables -I INPUT -j NOKIA_HA_L2_REMOTE_ACCESS 2> /dev/null
    l1_port=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get plasmodium.mqtt.port`
    if [ -z $l1_port ]
    then
        echo "L1 port empty"
    else
        iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $l1_port -j ACCEPT  2> /var/rutIpt_updateACLRules
        iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $l1_port -j ACCEPT  2> /var/rutIpt_updateACLRules
    fi
    old_port=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get apcloud.main.port`
    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $old_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport $apcloud_port -j ACCEPT 2> /var/rutIpt_updateACLRules
    iptables -D NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT  2> /var/rutIpt_updateACLRules
    iptables -I NOKIA_HA_L2_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT  2> /var/rutIpt_updateACLRules

    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set apcloud.main.server=$apcloud_server
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set apcloud.main.port=$apcloud_port
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set apcloud.main.username=$L2username
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} set apcloud.main.password=$L2password
    uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} commit apcloud

    [ -f /tmp/.ap_acs_triggered.txt ] && rm -rf /tmp/.ap_acs_triggered.txt

    #$APCLOUD_WATCHDOG &
    #$APCLOUD &
    ubus call fonendoscope start '{"process":"apcloud"}'
}

stop_processes()
{
    if [ $1 == 1 ]
    then
        ubus call fonendoscope stop '{"process":"rpcd"}'
        ubus call fonendoscope stop '{"process":"boardd"}'
        ubus call fonendoscope stop '{"process":"plasmodium"}'
        ubus call fonendoscope stop '{"process":"wifimon"}'
        ubus call fonendoscope stop '{"process":"nemo"}'
        ubus call fonendoscope stop '{"process":"ustatusd"}'
        ubus call fonendoscope stop '{"process":"bw_ookla"}'
        ubus call fonendoscope stop '{"process":"log_agent"}'
    else
        #killall -9 apcloud_watchdog &
        #killall -9 apcloud &
        ubus call fonendoscope stop '{"process":"apcloud"}'
    fi
}

restart_extender_process()
{
    sleep 5
    ubus call fonendoscope restart '{"process":"plasmodium"}'
    ubus call fonendoscope restart '{"process":"dhcpmon"}'
    ubus call fonendoscope restart '{"process":"wifimon"}'
    ubus call fonendoscope restart '{"process":"ustatusd"}'
}

if [ $# -gt 2 ]
then
    if [ $# -lt 8 ]
    then 
        echo "arguments provided to script are insufficient"
        print_help
    else
        while getopts 'o:l:u:p:m:q:t:h' c
        do
            case $c in
                o)
                    option=$OPTARG
                    if [ "$OPTARG" == "-l" -o "$OPTARG" == "-u" -o "$OPTARG" == "-p" -o "$OPTARG" == "-m" -o "$OPTARG" == "-q" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "option is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "option=$OPTARG"
                    fi
                    ;;
                l)
                    L1url=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-u" -o "$OPTARG" == "-p" -o "$OPTARG" == "-m" -o "$OPTARG" == "-q" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "L1url is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L1url=$OPTARG"
                    fi
                    ;;
                u)
                    L1username=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-l" -o "$OPTARG" == "-p" -o "$OPTARG" == "-m" -o "$OPTARG" == "-q" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "L1username is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L1username=$OPTARG"
                    fi
                    ;;
                p)
                    L1password=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-u" -o "$OPTARG" == "-l" -o "$OPTARG" == "-m" -o "$OPTARG" == "-q" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "L1password is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L1password=$OPTARG"
                    fi
                    ;;
                m)
                    L2url=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-u" -o "$OPTARG" == "-p" -o "$OPTARG" == "-l" -o "$OPTARG" == "-q" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "L2url is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L2url=$OPTARG"
                    fi
                    ;;
                q)
                    L2username=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-u" -o "$OPTARG" == "-p" -o "$OPTARG" == "-m" -o "$OPTARG" == "-l" -o "$OPTARG" == "-t" -o "$OPTARG" == "-h" ]
                    then
                        echo "L2username is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L2username=$OPTARG"
                    fi
                    ;;
                t)
                    L2password=$OPTARG
                    if [ "$OPTARG" == "-o" -o "$OPTARG" == "-u" -o "$OPTARG" == "-p" -o "$OPTARG" == "-m" -o "$OPTARG" == "-q" -o "$OPTARG" == "-l" -o "$OPTARG" == "-h" ]
                    then
                        echo "L2password is NULL"
                        OPTIND=$OPTIND-1
                    else
                        echo "L2password=$OPTARG"
                    fi
                    ;;
                h)
                    print_help;;
                *)
                    exit 1
                    ;;
            esac
        done

        if [ "$option" == "Start_L1" ]
        then
            echo "Starting L1 processes\n"
            start_common_processes
            start_L1_processes
        elif [ "$option" == "Start_L2" ]
        then
            echo "Starting L2 processes\n"
            start_common_processes
            start_L2_processes
        elif [ "$option" == "Restart_L1" ]
        then 
            echo "Restart L1 processes\n"
            start_common_processes
            restart_L1_processes
        elif [ "$option" == "Restart_L2" ]
        then
            echo "Restart L2 processes"
            stop_processes 2
            start_common_processes
            start_L2_processes
        elif [ "$option" == "Start_L1_L2" ]
        then
            echo "Start L1 and L2"
            start_common_processes
            start_L1_processes
            start_L2_processes
        else
            echo "Invalid first argument to script\n"
            print_help
        fi
    fi
else
    if [ "$2" == "Stop_L1" ]
    then
        stop_processes 1
    elif [ "$2" == "Stop_L2" ]
    then
        stop_processes 2
    elif [ "$2" == "Restart_EXTP" ]
    then
        restart_extender_process
    else
        echo "Invalid arguments to script"
        print_help
    fi
fi

