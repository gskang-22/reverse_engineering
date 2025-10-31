#!/bin/sh

default_ed_thresh=-60
isup=0

while true
do
	isup=`wl -i wl1 isup`
	wl1_ed_thresh=`wl -i wl1 phy_ed_thresh`
#	echo "wl1 phy_ed_thresh = $wl1_ed_thresh"
	if [ $isup -eq 1 -a $wl1_ed_thresh != $default_ed_thresh ]; then
		#echo "set wl1 phy_ed_thresh to $default_ed_thresh"
		wl -i wl1 phy_ed_thresh $default_ed_thresh
	fi

#	wl0_ed_thresh=`wl -i wl0 phy_ed_thresh`
#	echo "wl0 phy_ed_thresh = $wl0_ed_thresh"
#	if [ $wl0_ed_thresh != $default_ed_thresh ]; then
#		echo "set wl0 phy_ed_thresh to $default_ed_thresh"
#		wl -i wl0 phy_ed_thresh $default_ed_thresh
#	fi

	sleep 10;
done

