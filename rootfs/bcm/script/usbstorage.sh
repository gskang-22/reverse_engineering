#!/bin/sh
### Just for USB Storage CREATE/REMOVE file test
### Usage: 
###     sh usbstorage.sh [<maxi_time> [file_size]]
### treat >9999 as infinite

usbstorage()
{
	cnt=0
	usb="$1"
	max="$2"
	if [ "X$max" == "X" ]; then	max=3; fi

	volume=$(df -m|grep "$usb"|sed "s# *# #g"|cut -d" " -f5|cut -d"." -f1)
	m_volume=$(echo -n $volume|cut -c1)
	n_volume=$(echo -n $volume|wc -c)
	case $n_volume in
		1) s_volume="" ;;
		2) s_volume="0" ;;
		3) s_volume="00" ;;
		4) s_volume="000" ;;
		5) s_volume="0000" ;;
		6) s_volume="00000" ;;
		7) s_volume="000000" ;;
		8) s_volume="0000000" ;;
		9) s_volume="00000000" ;;
		*) s_volume="000000000" ;;
	esac
	echo
	echo "[$usb]The free volume is ${volume}MB"
	volume="$m_volume""$s_volume"
	if [ "X$3" != "X" ]; then
		volume="$3"
	fi
	tester=$usb/${volume}MB.bin
	echo "[$usb]Try to CREATE/REMOVE ${volume}MB file"

	while [ $cnt -lt $max ]
	do
		rm -rf $tester
		sync; sleep 2
		echo "[$usb]CREATE $tester - times $(($cnt + 1))/$max ..."
		time dd if=/dev/urandom of=$tester bs=16K count=$(($volume * 64))
		sync; sleep 2; ls -lh $tester
		echo "[$usb]READ-> $tester - times $(($cnt + 1))/$max ..."
		time dd if=$tester of=/dev/null bs=16K count=$(($volume * 64))
		sync; sleep 2; ls -lh $tester
		echo "[$usb]REMOVE $tester - times $(($cnt + 1))/$max ..."

		### treat >9999 as infinite
		if [ $cnt -ge 9999 ]; then
			continue
		fi
		cnt=$(($cnt + 1))
	done
}

for usb in $(find /mnt -maxdepth 1 -mindepth 1 -type d)
do
	if [ ! -d "$usb" ]; then continue; fi
	echo 3 > /proc/sys/vm/drop_caches
	usbstorage "$usb" $1 $2 &
done
