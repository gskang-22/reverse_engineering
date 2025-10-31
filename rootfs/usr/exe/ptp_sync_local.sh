#!/bin/sh

#Usage:
#    ptp_sync_local.sh start eth0 /etc/brcm0.conf
#    ptp_sync_local.sh stop eth0

get_prg() {
	if [ -n "$2" ]; then
		echo `ps | grep "$1" | grep "$2" | grep -v grep`
	else
		echo `ps | grep "$1" | grep -v grep`
	fi
}

start() {
	local prg

	# check if already running
	prg=`get_prg "ptp4l " $1" "`
	if [ -n "$prg" ]; then
		prg=`echo $prg | grep -o ptp4l.*`
		echo "ptp4l already running: $prg"
		echo "Leaving..."
		return 0
	fi

	params="-E -2 -H -f $2 -i $1 -l 6 -m -q"
	echo "starting ptp4l $params"
	ptp4l $params &
}

stop() {
	local prg

	prg=`get_prg "ptp4l " $1" "`
	if [ -n "$prg" ]; then
		echo "stopping ptp_sync..."
		echo $prg | awk '{print $1}' | xargs kill -TERM
	else
		echo "ptp4l is not running."
	fi
}

restart() {
	stop
	start
}

#main routine
if [ -n "$2" ]; then 
	PTP4LIF=$2
else
	echo "cannot determine the interface name"
	return 1
fi

if [ -n "$3" ]; then
	PTP4LCONF=$3
else
	if [ $1 != "stop" ]; then
		echo "cannot determine the configuration file"
		return 1
	fi
fi

if [ $1 == "start" ]; then
	echo "do start ${PTP4LIF} ${PTP4LCONF}"
	start ${PTP4LIF} ${PTP4LCONF}
elif [ $1 == "stop" ]; then
	echo "do stop ${PTP4LIF}"
	stop ${PTP4LIF}
elif [ $1 == "restart" ]; then
	echo "do restart ${PTP4LIF} ${PTP4LCONF}"
	restart ${PTP4LIF} ${PTP4LCONF}
else
	echo "Please make sure the operation is start or stop or restart."
fi
