#!/bin/sh
# File name: backup_once.sh
# Description: This script used for backup files after upgrade image, refer to backup_files.sh for details.
# Author: xinpeng.cao@alcatel-sbell.com.cn
# History: 2016/4/25 Create file.

source /usr/exe/defset.as
source /bcm/script/backup_files.sh

backup_static_files;
backup_dynamic_files;

sync
