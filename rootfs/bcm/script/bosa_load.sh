#!/bin/sh

#mkdir bosa for saving bosa cfg data, add by xufugo, 20120420
if [ ! -d /configs/bosa ]; then
	mkdir -p /configs/bosa
	chmod g+w /configs/bosa
	chgrp wheel /configs/bosa
fi

BOSA_TYPE=$(hcfgtool get BOB.0.SOLUTION || echo NA)
case ${BOSA_TYPE} in
	Semtech.GN25L95)
		BOSA_TAG=semetech
		;;
	Semtech.GN25L98)
		BOSA_TAG=gn25l98
		;;
	Mindspeed.M02098)
		BOSA_TAG=mindspeed
		;;
	*)
		BOSA_TAG=discrete
		;;
esac

echo "Establish bosa symbol link ..."
ln -sf /lib/libbosa.so.$BOSA_TAG /tmp/libbosa.so.mdl
ln -sf /sbin/bob.$BOSA_TAG /tmp/bob.mdl

echo "Loading bosa $BOSA_TAG ..."
source /bcm/script/bosa_load.$BOSA_TAG.sh

