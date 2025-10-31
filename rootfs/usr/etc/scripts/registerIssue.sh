cat /usr/etc/buildinfo
loglevel=`cat /proc/sys/kernel/printk|cut -b 1`
dmesg -n 8
hcfgtool
dmesg -n $loglevel
ritool dump
ps
omcli omciMgr redirect `tty`
cat /tmp/omci.log.bak
cat /tmp/omci.log
cat /logs/omci.log.bak
cat /logs/omci.log

