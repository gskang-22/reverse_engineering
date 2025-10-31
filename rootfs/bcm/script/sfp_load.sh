#!/bin/sh

KMOD_SFP_DRIVER="/bcm/bin/soc_sfp_driver.ko"

### Check whether kernel module exist
if [ ! -e ${KMOD_SFP_DRIVER} ]; then
	echo "WARNING: ${KMOD_SFP_DRIVER} not exist"
	return 1;
fi

### Try to load the target kernel module
if insmod ${KMOD_SFP_DRIVER} $*; then
	rm -f /dev/sfp0
	mknod /dev/sfp0 c 93 0
	rm -f /dev/bosa
	mkdir -p /configs/bosa
	ln -sf /lib/libbosa.so.mindspeed /configs/bosa/libbosa.so.mdl
else
	echo "WARNING: insmod ${KMOD_SFP_DRIVER}"
	return 2;
fi

