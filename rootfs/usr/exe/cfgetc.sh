#!/bin/sh
#### /etc configuration deal with for the target system

SYS_ETC_AGE="/usr/cfg/etc.age"
SYS_ETC_CFG="/usr/cfg/etc.cfg"
SYS_ETC_EXT="/usr/cfg/etc.ext"

#### deal with the etc.age before etc.cfg handle
# discard the residual config while image switch
ACTIVE=$(swug --active)
COMMIT=$(swug --committed)
if [ -z "$ACTIVE" -o "X$ACTIVE" != "X$COMMIT" ]; then
	for item in $(cat ${SYS_ETC_AGE} |sed "s/[ \t]//g" |sed "s/#.*$//g")
	do test -e "${item}" && rm -rf "${item}"; done
	sync
fi

#### deal with the etc.cfg with general strategy
for item in $(cat ${SYS_ETC_CFG} |sed "s/[ \t]//g" |sed "s/#.*$//g")
do
	LINK_TARGET=$(echo ${item} |cut -d: -f1)
	LINK_SOURCE=$(echo ${item} |cut -d: -f2)
	mkdir -p $(dirname ${LINK_SOURCE})
	if [ -e ${LINK_SOURCE} ]; then
		if [ -L ${LINK_TARGET} ]; then
			rm -f ${LINK_TARGET}
		else
			rm -rf ${LINK_TARGET}
		fi
	elif [ -e ${LINK_TARGET} ]; then
		mv ${LINK_TARGET} ${LINK_SOURCE}
	fi
	mkdir -p $(dirname ${LINK_TARGET})
	ln -sf ${LINK_SOURCE} ${LINK_TARGET}
done
sync

#### deal with the etc.ext with specail strategy
for item in $(cat ${SYS_ETC_EXT} |sed "s/[ \t]//g" |sed "s/#.*$//g")
do
	LINK_TARGET=$(echo ${item} |cut -d: -f1)
	LINK_SOURCE=$(echo ${item} |cut -d: -f2)
	mkdir -p $(dirname ${LINK_TARGET})
	ln -sf ${LINK_SOURCE} ${LINK_TARGET}
done

