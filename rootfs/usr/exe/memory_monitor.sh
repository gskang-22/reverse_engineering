#!/bin/sh
loadfs=/logs/memory_monitor.log
while true
do
size=`du -k $loadfs |awk '{print $1}'`
if [ $size -gt 1024 ]; then
	mv $loadfs $loadfs.old
fi
echo ~~~~~~~~~~~~~~~~~~ >> $loadfs
uptime >> $loadfs
cat /proc/meminfo >> $loadfs
cat /proc/slabinfo >> $loadfs
#top -m >> $loadfs
ps >> $loadfs
ps > /tmp/ps
while read line
do
       echo -n $line\  >> $loadfs
       echo $line |awk '{print "\/proc\/"$1"\/statm"}' | xargs cat >> $loadfs
done < /tmp/ps
sleep 60m
done
