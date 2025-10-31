#!/bin/sh
destdir=/mnt
usbinfo=/tmp/usbinfo
export mnt_dir
export fs_type
export label
export dev_path
export dev_name
MAXUSB=16
COUNT=1
prefixdir=usb
get_label()
{
#	if [ "X${fs_type}" == "XFAT32" -o  "${fs_type}" == "FAT" ] ; then
#		if mlabel -i /dev/${MDEV} -s :: | grep "Volume has no label" ; then
			label=""
#		else
#			label=$(mlabel -i /dev/${MDEV} -s :: | awk '{print $4}')
#		fi
#	elif [ "X${fs_type}" == "XNTFS" ] ; then
#		label=$( ntfslabel -f /dev/${MDEV} 2> /dev/null )
#	fi
}
get_mnt_dir()
{
	COUNT=`echo ${1} |awk '{print substr($0, 3, 1)}'`
	COUNT=`printf "%d" "'${COUNT}"`
	let COUNT=COUNT-96
	if [ "$label" == "" ] ; then
		mnt_dir=`echo ${1} |awk '{print "'${COUNT}'_"substr($0, 4, 1)""}'`
		mnt_dir=${prefixdir}${mnt_dir}
	else
		mnt_dir=${label}
	fi
}
get_fs_type()
{
	if fdisk -l | grep "^/dev/${1}" | grep NTFS ; then
		fs_type="NTFS"
	elif fdisk -l | grep "^/dev/${1}" | grep FAT32 ; then
		fs_type="FAT32"
	elif fdisk -l | grep "^/dev/${1}" | grep FAT ; then
		fs_type="FAT"
	fi
}
my_umount()
{
	if grep -qs "$1 " /proc/mounts ; then
		mnt_dir=$( grep $1 ${usbinfo} | awk '{print $2}' )
		if [ "${mnt_dir}" == "" ] ; then
			exit 1
		fi
		umount -l "${mnt_dir}"
	fi
	sed -i "/${1}/d" ${usbinfo}
	if [ "${mnt_dir}" != "" ] ; then
		[ -d "${mnt_dir}" ] && rmdir "${mnt_dir}"
	fi
	if ls -l /tmp/ushare_start | grep -v "No such file or directory" ; then
		killall -15 ushare
		[ `ls -la /mnt | wc -l` -gt 2 ] && (/bin/ushare -f /usr/etc/ushare.conf &) || echo /mnt is empty
	fi
    if [ -e "/tmp/twonky_start" ] ; then
        curl "http://127.0.0.1:9000/rpc/mountpoint_added?path=${mnt_dir}"
        curl "http://127.0.0.1:9000/rpc/mountpoint_removed?path=${mnt_dir}"
    fi
}

my_mount()
{
	get_fs_type ${1}
	get_label
	get_mnt_dir ${1}
	mkdir -p "${destdir}/${mnt_dir}"
	case "${fs_type}" in
	FAT32 | FAT)
		if ! mount -t vfat -o iocharset=cp936,umask=000,uid=111 "/dev/$1" "${destdir}/${mnt_dir}" ; then
			# failed to mount, clean up mountpoint
			rmdir "${destdir}/${mnt_dir}"
			exit 1
		fi
		;;
	NTFS)
		if !  /bin/ntfs-3g -o iocharset=cp936,umask=000  "/dev/$1" "${destdir}/${mnt_dir}" ; then
			# failed to mount, clean up mountpoint
			rmdir "${destdir}/${mnt_dir}"
			exit 1
		fi
		;;
	esac
	dev_name=$1
    echo "USB${COUNT} /mnt/${mnt_dir} ${fs_type} /dev/${dev_name}" >>  ${usbinfo}
	if ls -l /tmp/ushare_start | grep -v "No such file or directory" ; then
		pkill -9 ushare
		/bin/ushare -f /usr/etc/ushare.conf &
	fi
    if [ -e "/tmp/twonky_start" ] ; then
        curl "http://127.0.0.1:9000/rpc/mountpoint_removed?path=/mnt/${mnt_dir}"
        curl "http://127.0.0.1:9000/rpc/mountpoint_added?path=/mnt/${mnt_dir}"
    fi
}
echo "#########################"
echo "start usb storage process"
#dev_path=$(cat /tmp/usb_dev_path)
case "${ACTION}" in
add|"")
	my_umount ${MDEV}
	my_mount ${MDEV}
#	/sbin/usbmgr    8      0   ${MAJOR} ${MINOR} ${dev_path} /dev/${MDEV} ${destdir}/${mnt_dir}
	;;
remove)
	my_umount ${MDEV}
#	/sbin/usbmgr    8      1   ${MAJOR} ${MINOR} ${dev_path} /dev/${MDEV} ${mnt_dir}
	;;
esac
