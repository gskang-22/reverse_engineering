#!/bin/sh

LIST="$*"
REGS="0x0 0x1 0x4 0x5 0x9 0xA"

if [ "X$LIST" = "X" ]; then
	NUMS=$(hcfgtool get ENET.NUMS)
	PORT=0; while [ $PORT -lt $NUMS ]
	do
		PORT=$(($PORT + 1))
		LIST="$LIST $PORT "
	done
fi

for port in $LIST
do
	phytool gm $port
	for reg in $REGS
	do
		phytool rr $port $reg
	done
done

