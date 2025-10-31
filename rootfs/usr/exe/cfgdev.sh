#!/bin/sh
#### /dev configuration deal with for the target system

SYS_SOCINFO="/proc/socinfo"
if [ -e ${SYS_SOCINFO} ]; then
	CHIPSET=$(grep -i "\<SoC\>" ${SYS_SOCINFO}|cut -d: -f2|cut -c-8)
	case ${CHIPSET} in
	BCM68360)
		SYS_DEVTYPE=6836 ;;
	BCM68460|BCM68461)
		SYS_DEVTYPE=6846 ;;
	BCM68580|BCM55045)
		SYS_DEVTYPE=6858 ;;
	*)
		echo "ERR: miss to handle the chipset ${CHIPSET} ..."
		SYS_DEVTYPE=6858 ;;
	esac
fi

SYS_DEV_CFG="/usr/cfg/dev.cfg${SYS_DEVTYPE}"
while read line
do
	test -z $(echo "$line" |sed "s/[ \t\r\n]//g" |sed "s/#.*//g") && continue
	mknod ${line}
done < ${SYS_DEV_CFG}

