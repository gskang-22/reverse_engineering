#!/bin/sh
## load 3g-dongle kernel modules
KMOD_DONGLE="usbserial.ko usb_wwan.ko option.ko"

### Try to load kernel module
for case in ${KMOD_DONGLE}
do
	LKM="${KER_MOD_DIR}/${case}"
	if [ -e ${LKM} ]; then
		insmod ${LKM}
	else
		echo "WARNING: insmod ${case}"
	fi
done

