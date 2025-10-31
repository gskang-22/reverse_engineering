#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 

if [ "$1" = "on" ];then
    pkill telnetd
    /usr/sbin/telnetd -l /bin/sh&
    echo {\"ret\":1}
    exit 0
elif [ "$1" = "st" ];then
    str=`ps|grep "telnetd -l /bin/sh"|grep -v "grep"`
    if [ "$str" != "" ];then
        echo {\"ret\":1}
        exit 0
    fi
fi
echo {\"ret\":0}
    
