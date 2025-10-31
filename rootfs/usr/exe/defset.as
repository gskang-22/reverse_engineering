#!/bin/sh
## system default variables definition set
## comments leading with # which not in any quotation
## line style: export NAME=DATA; without any space character
## -----------------------------------------------------------------------------
export SYS_DEV_DIR=/dev
export SYS_ETC_DIR=/etc
export SYS_LIB_DIR=/lib
export SYS_MNT_DIR=/mnt
export SYS_OPT_DIR=/opt
export SYS_SYS_DIR=/sys
export SYS_TMP_DIR=/tmp
export SYS_VAR_DIR=/var
export USR_EXE_DIR=/usr/exe
export USR_CFG_DIR=/usr/cfg
export USR_LIB_DIR=/usr/lib
export USR_ETC_DIR=/usr/etc
export KER_MOD_DIR=${SYS_LIB_DIR}/modules/$(uname -r)
export BCM_BIN_DIR=/bcm/bin
export BCM_EXE_DIR=/bcm/script
export BAK_LOG_DIR=/logs/backup
export BAK_CFG_DIR=/configs/backup

## -----------------------------------------------------------------------------
export UBIMKVOL=/opt/mtdtools/ubimkvol
export UBIATTACH=/opt/mtdtools/ubiattach
export UBIDETACH=/opt/mtdtools/ubidetach
export UBIFORMAT=/opt/mtdtools/ubiformat
export UBIDEVCTL=/dev/ubi_ctrl

## -----------------------------------------------------------------------------
export LOGDEFAULT=.default.log
export BAKDEFAULT=.default.bak
export TAGUBIFSWR=.tag.ubifswr

