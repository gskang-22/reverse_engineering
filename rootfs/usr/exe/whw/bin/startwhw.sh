#!/bin/sh

waiting_for_ready()
{
    #waiting for cfgmgr done
    while [ ! -e /tmp/cfg_boot_for_middleware_done ]
    do
    	sleep 1
    done
	
    #waiting for init scan done
    t=60
    while [ $t -gt 0 ]
    do
    	let t=t-1
    	echo $t
    	if [ ! -e /tmp/candidates.json -o ! -e /tmp/candidates24.json ]
    	then
    	    sleep 1
    	else
    	    t=0
    	fi
    done
}

start_ai()
{
    export LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):/usr/exe/whw/lib
    export PATH=$PATH:/usr/exe/whw/bin

    #waiting for init scan done
    t=30
    while [ $t -gt 0 ]
    do
    	let t=t-1
    	echo $t
    	if [ ! -e /tmp/candidates.json -o ! -e /tmp/candidates24.json ]
    	then
    	    sleep 1
    	else
    	    t=0
    	fi
    done   

    echo "Starting AI !"
    if [ -e "/etc/startup_airiqapp.sh" ] ; then
        /etc/startup_airiqapp.sh &
    fi

    sleep 1
    
    if [ -e "/usr/exe/whw/bin/aiengine.load" ] ; then
        echo "Starting aiengine.load !"
        (/usr/exe/whw/bin/aiengine.load start) &
    fi
}

start_whw()
{
    export LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):/usr/exe/whw/lib
    export PATH=$PATH:/usr/exe/whw/bin

    #waiting_for_ready   

    echo "Starting onboarding!"
    if [ -e "/flash/onboarding" ] ; then
        /flash/onboarding &
    else
        /usr/exe/whw/bin/onboarding &
    fi

    waiting_for_ready   
    #echo "Starting whwrapper!"
    #/usr/exe/whw/bin/whwrapper &

    #echo "starting set_wds_mac_ebos.sh!"
    #/usr/exe/whw/bin/set_wds_mac_ebos.sh 60 &

    #echo "starting recover_wds.sh!"
    #/usr/exe/whw/bin/recover_wds.sh &
    
    #if [ -e "/configs/auto_start_backhaul_selecter" ] ; then
    #if [ ! -e "/configs/disable_backhaul_selecter" ] ; then
    #	echo "starting backhaul_selecter.sh!"
    #	/usr/exe/whw/bin/backhaul_selecter.sh 120 &
    #fi
    
    if [ ! -e "/configs/stop_monitor_wds_link" ] ; then
    echo "start monitor_wds_link.sh!"
    /usr/exe/whw/bin/monitor_wds_link.sh start 5g &
    #/usr/exe/whw/bin/monitor_wds_link.sh start 2g &
    fi
    
    mnemonic=$(ritool get Mnemonic|cut -d: -f2)
    if [ ! -e "/configs/stop_monitor_rdi" -a "$mnemonic" == "G-140W-H" ] ; then
    echo "start monitor_rdi.sh!"
    /usr/exe/whw/bin/monitor_rdi.sh start &
    fi
}
