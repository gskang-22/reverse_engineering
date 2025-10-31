#!/bin/bash
#software upgrade scripts.

mkdir -p /tmp/software_download

#mkdir /configs/swdl to save extend bootinfo, add by xufugo, 20120530
if [ ! -d /configs/swdl ]; then
	mkdir -p /configs/swdl
	chmod g+w /configs/swdl
	chgrp wheel /configs/swdl
fi

#creat a flag file when every boot, this file will be deleted when first execute swug cmd. add by xufuguo, 20120510
touch /tmp/software_download/new_boot_flag

#add ubiattach tool path to PATH, add by xufuguo, 20120510
PATH=/opt/mtdtools:$PATH

#add env. reason: this script is called by startup.sh, but startup.sh execute after /etc/profile. add by xufuguo, 20120514
PATH=/bcm/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/bcm/bin

SYS_SOCINFO="/proc/socinfo"
if test -e ${SYS_SOCINFO} && cat ${SYS_SOCINFO} |grep -qE "6858|55045|6846|6856|6836"; then
	#init mutex sem
	swug --init_sem
	if [ $? != 0 ]; then
		echo "*******SWUG: init mutex sem fail!*******"
		exit 1
	fi
else
	# attach partitions
	echo "SWUG: Attaching boot configuration and inactive images"

	# remove stale dev nodes make sure that /dev is fully populated
	rm /dev/ubi*
	mdev -s &>/dev/null

	# mtd_kupdate: inactive kernel
	inactive_kernel=`swug --im inactive --si kernel --bank`
	if [ "$inactive_kernel" != "0" -a "$inactive_kernel" != "1" ]; then
		echo "*******SWUG: link kernel mtd fail!*******"
		exit 1
	fi
	inactive_kmtd=$(cat /proc/mtd |grep jff2_$inactive_fs_bank |cut -d: -f1 |cut -c4-)
	ln -s /dev/mtdblock$inactive_kmtd /dev/mtd_kupdate

	# ubi2_0: inactive rootfs
	inactive_fs_bank=`swug --im inactive --si fs --bank`
	if [ "$inactive_fs_bank" != "0" -a "$inactive_fs_bank" != "1" ]; then
		echo "*******SWUG: ubiattach rootfs fail!*******"
		exit 1
	fi
	active_fs_bank=`expr 1 - $inactive_fs_bank`
	mtd_rootfs=$(cat /proc/mtd |grep rootfs$inactive_fs_bank |cut -d: -f1 |cut -c4-)

	OPERATE_FLAG=0
	ubiattach /dev/ubi_ctrl -m $mtd_rootfs -d $mtd_rootfs &>/dev/null || OPERATE_FLAG=1
	if [ $OPERATE_FLAG != 0 ]; then
		ubidetach /dev/ubi_ctrl -m $mtd_rootfs &>/dev/null
		ubiformat /dev/mtd$mtd_rootfs -y &>/dev/null
		ubiattach /dev/ubi_ctrl -m $mtd_rootfs -d $mtd_rootfs &>/dev/null
		mdev -s &>/dev/null
		if [ $? != 0 ]; then reboot; fi
		/opt/mtdtools/ubimkvol /dev/ubi$mtd_rootfs -t dynamic -n 0 -N 0 -s 36288KiB &>/dev/null
		if [ $? != 0 ]; then reboot; fi
		mdev -s &>/dev/null
	fi

	echo "SWUG: inactive rootfs: mtd$mtd_rootfs attached to ubi$mtd_rootfs"
fi

# re-populate /dev
mdev -s &>/dev/null

# if new active, set flag to trigger cfgmgr to do DB Migration, add, 20140416
# this is used to meet one case: switch to old image, restore factory setting, then 
# switch back(not upgrade). if not set this flag, will not do DB migration, but have to.
# Note: this must in front of "auto commit".
actived=`swug --active`
committed=`swug --committed`
if [ $actived != $committed ];then
	source /bcm/script/first_boot.sh
fi

# identify first boot after upgrade, if yes, execute first_boot.sh to set flag. add by xufuguo, 20130704
current_build_date=`cat /usr/etc/buildinfo | sed -n '/BUILDDATE/p' | awk -F = '{print $2}'`
if [ "$current_build_date" = "" ]; then
	echo "*******SWUG: buildinfo format error!*******"
	exit 1
fi
if [ -f /configs/swdl/last_buildinfo_img$active_fs_bank ]; then
	last_build_date=`cat /configs/swdl/last_buildinfo_img$active_fs_bank | sed -n '/BUILDDATE/p' | awk -F = '{print $2}'`
fi
if [ "$current_build_date" != ""$last_build_date"" ]; then
	source /bcm/script/first_boot.sh
	cp -f /usr/etc/buildinfo /configs/swdl/last_buildinfo_img$active_fs_bank	
fi

#show active image version for tracking problems in future, add, 20121218
echo "### Active Image ###"
swug --show_version --im active

