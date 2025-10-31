#!/bin/sh
#########################################################################
# File Name: check_fix_partition.sh(brcm)
# Author: renwei
# mail:Wei.D.Ren@alcatel-sbell.com.cn
# Created Time: Wed 14 Oct 2015 01:10:44 PM CST
################################################################################
## security preprocess
UPGRADE_CACHE=/tmp/.cache.upgrade
UPGRADE_STORE=/tmp/software_download

up_store_num=`mount | grep $UPGRADE_STORE | wc -l`
rm -rf $UPGRADE_CACHE
mkdir -p $UPGRADE_CACHE
mkdir -p $UPGRADE_STORE
touch $UPGRADE_STORE/RESERVED
mv $UPGRADE_STORE/* $UPGRADE_CACHE/
if [ $up_store_num -eq 0 ]
then
	mount -t tmpfs tmpfs $UPGRADE_STORE
else
	umount $UPGRADE_STORE
	mount -t tmpfs tmpfs $UPGRADE_STORE
fi
mv $UPGRADE_CACHE/* $UPGRADE_STORE

## FLASH MTD UBI preprocess
# ------------------------------------------------------------------------------
UBIMKVOL=/opt/mtdtools/ubimkvol
UBIATTACH=/opt/mtdtools/ubiattach
UBIDETACH=/opt/mtdtools/ubidetach
UBIFORMAT=/opt/mtdtools/ubiformat
UBIDEVCTL=/dev/ubi_ctrl

BRCM_UBIVOL_SIZE=36288KiB
inactive_fs_bank=$(swug --im inactive --si fs --bank)
if [ "$inactive_fs_bank" != "0" -a "$inactive_fs_bank" != "1" ]; then
	echo "*******SWUG: ubiattach rootfs fail!*******"
	exit 1
fi

mtd_rootfs=$(cat /proc/mtd |grep rootfs$inactive_fs_bank |cut -d: -f1 |cut -c4-)
echo -e "Checking upgrade partition..."
if [ ! -n "$mtd_rootfs" ]; then
	echo "Everything is OK."
	exit 0
fi

$UBIDETACH $UBIDEVCTL -m $mtd_rootfs &>/dev/null
if [ $? != 0 ]; then
	echo "detach failed :$?"
	exit 2
fi

$UBIATTACH $UBIDEVCTL -m $mtd_rootfs -d $mtd_rootfs &>/dev/null
if [ $? -ne 0 ]; then
	echo "Spare partition is damaged, trying to fix it, please wait a minite ..."
	$UBIFORMAT /dev/mtd$mtd_rootfs -y &>/dev/null
	if [ $? -ne 0 ]; then
		echo "Format mtd device fialed, now reboot!!!"
		exit 3
	fi

	$UBIATTACH $UBIDEVCTL -m $mtd_rootfs -d $mtd_rootfs &>/dev/null
	if [ $? -ne 0 ]; then
		echo "Attach mtd device fialed, now reboot!!!"
		exit 4
	fi

	mdev -s &>/dev/null
	$UBIMKVOL /dev/ubi$mtd_rootfs -t dynamic -n 0 -N 0 -s $BRCM_UBIVOL_SIZE &>/dev/null
	if [ $? -ne 0 ]; then
		echo "Make new volume device fialed, now reboot!!!"
		exit 5
	fi

	mdev -s &>/dev/null
	echo "Format OK"
else
	echo "Everything is OK"
fi

exit 0
