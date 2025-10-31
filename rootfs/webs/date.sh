#! /bin/sh
[ ! "$1" ] && exit 1;
if [  "$1" = "set" ];then
    echo -n { 
    echo -n \"ret\":
    result=`date -s $2 2>&1`
    echo -n $?,
    echo -n \"msg\":
    echo -n \"
    echo ${result} | awk '{ printf "%s", $0 }'
    echo -n \"
    echo -n }
    #/sbin/wkick.cgi 1 1>/dev/null
elif [ "$1" = "get" ];then
    echo -n { 
    echo -n \"ret\":
    result=`date +%m/%d/%Y`
    result1=`date +%r`
    
    echo -n $?,
    echo -n \"msg\":
    echo -n \"
    echo ${result} ${result1} | awk '{ printf "%s", $0 }'
    echo -n \"
    echo -n }
fi
