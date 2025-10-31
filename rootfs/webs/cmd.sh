#! /bin/sh
end()
{
	rm ${fifo}
	exit 0
}
fifo=/tmp/$1.cmd
mkfifo $fifo
trap end SIGINT
trap end SIGTERM
trap "" SIGPIPE
while read line;do
    (echo "${line}" >>${fifo}) &
    cmdpid=$!    
    (sleep 12; kill -9 ${cmdpid}) &
    wpid=$!
    if wait $cmdpid; then
    	kill -9 $wpid
    fi
done
rm $fifo

[ -f /tmp/upgrade_done_reboot ] && reboot
