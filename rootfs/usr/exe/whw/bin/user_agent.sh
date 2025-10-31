#!/bin/sh

curtime=`date +%F.%T`
logfile=/tmp/ua.log

start_ua() {
    echo "$curtime Starting Useragent process..." | tee -a $logfile
    /usr/exe/whw/bin/ddm &
    /usr/exe/whw/bin/raccess &
    echo "$curtime Started Useragent process..." | tee -a $logfile
}

stop_ua() {
    echo "$curtime Stoping Useragent process..." | tee -a $logfile
    pid_ddm=`ps | grep ddm | grep -v grep | awk '{print $1}'`
    pid_raccess=`ps | grep raccess | grep -v grep | awk '{print $1}'`

    while :
    do
      if [[ "" !=  "$pid_ddm" ]]; then
        echo "$curtime killing $pid_ddm" | tee -a $logfile
        kill -SIGKILL $pid_ddm
      fi

      if [[ "" !=  "$pid_raccess" ]]; then
        echo "$curtime killing $pid_raccess" | tee -a $logfile
        kill -SIGKILL $pid_raccess
      fi

      test_ddm=0
      if [[ "" !=  "$pid_ddm" ]]; then
         test_ddm=`ps | grep $pid_ddm | grep -v grep | wc -l`
      fi

      test_raccess=0
      if [[ "" !=  "$pid_raccess" ]]; then
         test_raccess=`ps | grep $pid_raccess | grep -v grep | wc -l`
      fi

      if [[ $test_ddm == 0 ]] && [[ $test_raccess == 0 ]]; then
            echo "$curtime Useragent processes are killed" | tee -a $logfile
            break;
      fi
      
      echo "$curtime Waiting for 5 secs..." | tee -a $logfile
      sleep 5
    done
    echo "$curtime Stopped Useragent process..." | tee -a $logfile
}

case "$1" in 
    start)   start_ua ;;
    stop)    stop_ua ;;
    restart) stop_ua; start_ua ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac
