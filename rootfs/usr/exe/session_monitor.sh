#!/bin/bash

    cmd_help()
	{
        echo "$0 <session_limit> <sleep_time>"
        echo "Example: $0 1000 10 ---- The system will switch to test mode when SYN > 1000/s, checked every 10sec. "
    }


    init_iptables()
    {
        iptables -N SYN_MONITOR > /dev/null 2>&1
    
	    iptables -C SYN_MONITOR -p tcp -m tcp --syn > /dev/null 2>&1
	    check=$?
	    if [ "$check" != 0 ]; then
            iptables -A SYN_MONITOR -p tcp -m tcp --syn
	    fi
	
	    iptables -C FORWARD -j SYN_MONITOR > /dev/null 2>&1
	    check=$?
	    if [ "$check" != 0 ]; then
	    iptables -I FORWARD 1 -j SYN_MONITOR
	    fi  
    }

    clear_count()
	{
	    iptables -Z SYN_MONITOR
	}

    switch_to_test_mode()
    {
	
	    echo "$DATE fc disable"   >> /logs/sessionmonitor.log 2>&1
	    fc disable
		echo "$DATE fc flush"    >> /logs/sessionmonitor.log 2>&1
		fc flush
		
		echo "$DATE cpu meter"   >> /logs/sessionmonitor.log 2>&1
		bs /b/c cpu/index=host reason_cfg[{dir=us,reason=ip_flow_miss}]={meter=-1}
        bs /b/c cpu/index=host reason_cfg[{dir=ds,reason=ip_flow_miss}]={meter=-1}
		   
        echo "$DATE skip iptables rules" >> /logs/sessionmonitor.log 2>&1

        iptables -D FORWARD -j SYN_MONITOR
        iptables -I FORWARD 1 -j SYN_MONITOR

        iptables -C FORWARD -p tcp -j ACCEPT > /dev/null 2>&1
	    check=$?
	    if [ "$check" != 0 ]; then	
		iptables -I FORWARD 2 -p tcp -j ACCEPT
		fi
		
        iptables -t mangle -C FORWARD -p tcp -j ACCEPT > /dev/null 2>&1
	    check=$?
	    if [ "$check" != 0 ]; then		
		iptables -t mangle -I FORWARD 1 -p tcp -j ACCEPT
		fi
		
        iptables -t mangle -C SNIFFER -p tcp -j ACCEPT > /dev/null 2>&1
	    check=$?
	    if [ "$check" != 0 ]; then			
        iptables -t mangle -I SNIFFER 1 -p tcp -j ACCEPT
		fi
		
        TEST_MODE=1
		echo "$DATE TEST_MODE STARTED"    >> /logs/sessionmonitor.log 2>&1
    }

    recover_rule()
    {
	    echo "$DATE recover:"   >> /logs/sessionmonitor.log 2>&1
	    echo "$DATE fc enable"   >> /logs/sessionmonitor.log 2>&1
	    fc enable
		
        echo "$DATE cpu meter"   >> /logs/sessionmonitor.log 2>&1
		bs /b/c cpu/index=host reason_cfg[{dir=us,reason=ip_flow_miss}]={meter=4}
        bs /b/c cpu/index=host reason_cfg[{dir=ds,reason=ip_flow_miss}]={meter=3}		

        echo "$DATE del iptables rules"    >> /logs/sessionmonitor.log 2>&1
        iptables -C FORWARD -p tcp -j ACCEPT
	    check=$?
	    if [ "$check" = 0 ]; then	
		iptables -D FORWARD -p tcp -j ACCEPT
		fi

        iptables -t mangle -C FORWARD -p tcp -j ACCEPT
	    check=$?
	    if [ "$check" = 0 ]; then		
		iptables -t mangle -D FORWARD -p tcp -j ACCEPT
		fi
		
        iptables -t mangle -C SNIFFER -p tcp -j ACCEPT
	    check=$?
	    if [ "$check" = 0 ]; then			
        iptables -t mangle -D SNIFFER -p tcp -j ACCEPT
		fi
		
        TEST_MODE=0
		echo "$DATE TEST_MODE CLOSED"    >> /logs/sessionmonitor.log 2>&1
		
    }
	
    monitor_tcp_sessions()
	{
		while true
		do
		    FILE_SIZE=`ls -l /logs/sessionmonitor.log|awk '{print $5}'`
			if [ $FILE_SIZE -gt $MAX_FILE_SIZE ] ;then
			    `cat /dev/null > /logs/sessionmonitor.log`
			fi
			
            DATE="[`date "+%Y-%m-%d %H:%M:%S"` NAT SESSION]"
            value_string==`iptables -n -v -L SYN_MONITOR | awk 'NR==3 {print $1}'`    #get the count
			ret=`awk 'BEGIN{print match("'$value_string'","M")}'`   #serch 'M'
			if [ $ret != 0 ] ;then
			    clear_count
			fi
			
            value_string=`iptables -n -v -L SYN_MONITOR | awk 'NR==3 {print $1}'`    #get the count			
            ret=`awk 'BEGIN{print match("'$value_string'","K")}'`   #serch 'K'

            if [ $ret != 0 ] ;then    # 'Kpkts"
	            SESSION_CURRENT=`echo $value_string |awk '{sub(/.{1}$/,"")}1'` # strip K	  
				new_session=$SESSION_CURRENT
				
                if [ $new_session -gt $MAX_SESSION_K ]; then
				    echo "$DATE new_session(k):$new_session ----"   >> /logs/sessionmonitor.log 2>&1
	                if [ $TEST_MODE = 0 ]; then
                        echo "$DATE switch to test mode(K)"   >> /logs/sessionmonitor.log 2>&1
					    switch_to_test_mode
		            fi
				else
				    if [ $TEST_MODE = 1 ]; then
					    echo "$DATE leave test mode(K)"   >> /logs/sessionmonitor.log 2>&1
                        recover_rule
                    fi					
                fi
				clear_count
	        else    # 'pkts' 
	            SESSION_CURRENT=$value_string
				new_session=$SESSION_CURRENT			
                
	            if [ $new_session -gt $MAX_SESSION ] ;then
				    echo "$DATE new_session:$new_session ----"	  >> /logs/sessionmonitor.log 2>&1
	                if [ $TEST_MODE = 0 ]; then
                        echo "$DATE switch to test mode"   >> /logs/sessionmonitor.log 2>&1
					    switch_to_test_mode
		            fi
				else
				    if [ $TEST_MODE = 1 ]; then
					    echo "$DATE leave test mode"   >> /logs/sessionmonitor.log 2>&1
                        recover_rule
                    fi					
	            fi
				clear_count	
            fi
			
            sleep $SLEEP_TIME
			
        done
	}

#=====MAIN=============================================================================

    if [ $# -lt 2 ]; then
        cmd_help
        exit 0
    fi


    if [ -n "$(echo $1| sed -n "/^[0-9]\+$/p")" ];then 
        SESSION_LIMIT=$1	 
    else 
        echo '<session_limit> is not a number'
        exit 0	  
    fi 
    if [ -n "$(echo $2| sed -n "/^[0-9]\+$/p")" ];then 
        SLEEP_TIME=$2	 
    else 
        echo '<sleep_time> is not a number'
        exit 0		
    fi
	  

    SESSION_LIMIT_K=`expr $SESSION_LIMIT / 1000`	
	MAX_SESSION=`expr $SESSION_LIMIT \* $SLEEP_TIME`
    MAX_SESSION_K=`expr $SESSION_LIMIT_K \* $SLEEP_TIME`
    DATE="[`date "+%Y-%m-%d %H:%M:%S"` NAT SESSION]"


    echo "$DATE started with SLEEP_TIME: $SLEEP_TIME s SESSION_LIMIT:$SESSION_LIMIT /sec"  >> /logs/sessionmonitor.log 2>&1

	TEST_MODE=0	
    SESSION_CURRENT=0	
    FILE_SIZE=0
	MAX_FILE_SIZE=2000000
	
    #add iptables chain/rule
	init_iptables
	
	
	#monitor tcp sessions
    monitor_tcp_sessions
	
	exit 0
	
 