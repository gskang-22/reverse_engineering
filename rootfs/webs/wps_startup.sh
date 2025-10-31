#!/bin/sh


if [ $1 == "pbc" ]
	then 
	echo "do pbc"
	wps_tool addenrollee wl0 pbc
elif [ $1 == "pin" ]
	then
	echo "do pin"
	wps_tool addenrollee wl0 sta_pin=$2
fi
