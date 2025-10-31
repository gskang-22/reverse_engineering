#!/bin/sh

get_work_role()
{
    work_role="Controller"

    while [ "x$work_role" != "xAgent" -a "x$work_role" != "xController" ]
    do
        sleep 5
        work_role=`cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole | cut -d = -f 2`
    done

    echo $work_role
}

assert()
{
    role=`get_work_role`

    if [ "$role" = "Controller" ]; then
        echo "Device is running as $role role, so put wds link into EBOS..."
    else
        echo "Device is running as $role role, so exit..."
        exit
    fi

    taf=`wl taf enable`

    if [ "$taf" != "1" ]; then
        echo "TAF is disabled, so exit..."
        exit
    fi
}

ebos_threshold=500 # 5Mbit/s (unit 10K)
sta_threshold=200  # 20Mbit/s (unit 100K)
sta_low_threshold=50  # 5Mbit/s (unit 100K)
active_5g=3
active_24g=1

check_ebos_available()
{
	row=0
	rate=0
	rate_sum=0
	wl -i wl$2.4 pktq_stats a:$1 > /dev/null
	sleep 1
	wl -i wl$2.4 pktq_stats a:$1 > /tmp/ebos.tmp

	while read line; do
		row=$(expr $row + 1 )
		[ $row -lt 3 -o "$line" == "" ] && continue
		rate=`echo $line | awk -F, '{ printf $11}' | awk -F. '{ print $1$2}'`
		rate_sum=$(expr $rate_sum + $rate )
		#echo rate_sum=$rate_sum
	done < /tmp/ebos.tmp

	if [ $rate_sum -ge $ebos_threshold ]; then
		return 1
	else
		return 0
	fi
}

check_active_sta()
{
	active_num=0
	
	wl -i wl$1 bs_data > /tmp/ebos.tmp
	exec < /tmp/ebos.tmp

	while read line; do
		if echo $line |grep station -i; then
			continue;
		fi
		rate=`echo $line | awk '{ printf $3}' | awk -F. '{ print $1$2}'`
		#echo bs_data=$rate
		if (wl -i wl$1 taf ebos list |grep "No assigned entries"); then
			[ $rate -ge $sta_threshold ] && active_num=$(($active_num+1))
		else
			[ $rate -ge $sta_low_threshold ] && active_num=$(($active_num+1))
		fi

	done
	
	[ $1 -eq 0 ] && active=$active_5g || active=$active_24g
	if [ $active_num -ge $active ]; then
		return 1
	else
		return 0
	fi
}

[ $# -eq 2 ] && assert || exit

interval=$1
index=$(echo $2 | cut -c 3-3)

while sleep $interval; do

    check_active_sta $index
    flag=$?

    prio=0
    wl -i $2 wds | while read line; 
	do
        prio=$(expr $prio + 1 )
        mac=$(echo $line |cut -d ' ' -f 2)

		if [ $flag -eq 1 ]; then
			check_ebos_available $mac $index
			if [ $? -eq 1 ]; then
				if (wl -i $2 taf ebos list |grep -i $mac)
				then
					echo "ebos already exist wds mac $mac"
				else
					wl -i $2 taf $mac ebos $prio
					echo "new set wds mac $mac, priority is $prio"
				fi
			else
				wl -i $2 taf $mac atos
			fi
		else
			wl -i $2 taf $mac atos
		fi
    done
    if wl -i $2 taf ebos list |grep "No assigned entries"; then
    	wl -i $2 atf 0
    else
    	wl -i $2 atf 1
    fi

done
