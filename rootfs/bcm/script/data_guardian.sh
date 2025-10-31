# File name: data_guardian.sh
# Description: This script used for backup files periodically, refer to backup_files.sh for details.
# Author: xinpeng.cao@alcatel-sbell.com.cn
# History: 2016/4/25 Create file.

#! /bin/sh

source /bcm/script/backup_files.sh

# check the certificates whether are damaged before ONU registry
if [ -f /bcm/script/check_certificate_files.sh ]; then
	echo "check certificate files before ONU registry..."
	sh /bcm/script/check_certificate_files.sh
fi

# backup files one time before sleep since logs damaged and power down when sleep,
# and configs also damaged when power up ALU02591096
backup_static_files;
sync

# Waiting system booting up
sleep 120

# check the certificates whether are damaged
if [ -f /bcm/script/check_certificate_files.sh ]; then
	echo "check certificate files before backup files..."
	sh /bcm/script/check_certificate_files.sh
fi

# After booting up backup static files once.
backup_static_files;
sync

# Backup dynamic files every 1 hour.
while true
do
    backup_dynamic_files;
    sync
    sleep 120
done
