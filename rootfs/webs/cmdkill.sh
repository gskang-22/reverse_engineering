#! /bin/sh

tries=0
while [ $tries -lt 3 ]
   do
      proc_name=`ps | grep "ping\|traceroute" | grep -v grep | awk '{print $6}'`
      tries=`expr $tries + 1`
      for i in $proc_name
         do
         if [ $i == "traceroute" ]
         then
            killall traceroute
        fi
        if [ $i == "ping" ]
        then
           killall ping
        fi
      done
done
killall cmd.sh
killall cmdtrace.sh
