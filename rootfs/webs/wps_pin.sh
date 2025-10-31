#! /bin/sh
output_file=/tmp/wps_pin_result
if [ $# -eq 1 ];then
    pkill wpatalk
    /sbin/wpatalk /tmp/hostapd/ath0 configme pin=$1 > ${output_file}
    sleep 10 
    rm ${output_file}
    exit 0
fi
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 
pstr=`ps w|grep wpatalk.*configme|grep -v 'grep'`
echo {

echo \"status\":
[ "$pstr" != "" ]&&echo 1, || echo 0,

echo \"pin\":\"${pstr##*=}\",

echo \"result\":
if [ -f ${output_file} ];then
    if [ `grep "\[Success\]" ${output_file} -c` -gt 0 ] ;then
        echo 1 #success
    elif [ `grep "\[Timeout\]" ${output_file} -c` -gt 0 ] ;then
        echo 2 #timeout
    else
        echo 3 #probably wpatalk is running
    fi
else
    echo 0 #no result
fi

echo }
