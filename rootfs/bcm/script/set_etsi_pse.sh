#!/bin/sh
# This program will execute the cmd

numOfPse=`hcfgtool get PSE.NUMS`
if [ "$numOfPse" == "1" ]; then
	echo "Support PSE"

	#ledtool 80 1
	#ledtool 81 1
	#ledtool 82 1

	echo "Upgrade PSE controller firmware, it will take a about 1 minute"

	Loop=1
	while [ $Loop -le 5 ]
	do
		#echo "cycle $Loop times"
		Loop=$(( $Loop + 1 ))
		pse_tool upgrade_pd

		if [ $? -lt 0 ]; then
			if [ $Loop -gt 3 ]; then
				echo "PSE upgrade failed, retry the max times, this firmware cannot work, trigger a rollback"
				reboot
			else
				echo "PSE upgrade failed, retry upgrade"
			fi
		else
			echo "Upgrade passed"
			break
		fi
	done
	#echo "Start PSE manager to monitor reverse powering status"
	#psemgr &
else
	echo "Not Support PSE"
fi

echo "PSE initialization done"
