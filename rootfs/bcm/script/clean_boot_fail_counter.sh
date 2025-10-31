# called by /etc/init.d/rcS. used to clean boot fail counter.
# xufuguo, 2014.03.25
count=`nvram_tool --getbfc`
active_img=`swug --im active --si fs --bank`
echo "INFO: boot fail count: $count"

# record some log, if board can run to here before dead fortunatelly.
echo "`date '+%Y-%m-%d %H:%M:%S'` [alert] boot image$active_img fail count: $count" >> /logs/customer
echo "`date '+%Y-%m-%d %H:%M:%S'` [alert] boot image$active_img fail count: $count" >> /logs/messages
swug --info >> /logs/messages

sleep 70  # wait for service recovery
nvram_tool --setbfc 0  # clean counter
echo "INFO: clean boot fail counter done"
