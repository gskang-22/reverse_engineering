#!/bin/sh
### Reset RI to default with default ri.dump

cd /configs
RIROM=$(ls *ri.dump|head -n 1)
if [ "X$1" != "X" ]; then
	RIROM=$1
fi
echo "RIROM: $RIROM"
OPID=$(ritool get OperatorID |cut -d: -f2)
ritool set OperatorID 0000
test ! -z $RIROM && for case in $(cat $RIROM|grep ":"|sed "s/ *//g"|cut -c4-)
do
	ITEM=$(echo $case|cut -d: -f1)
	DATA=$(echo $case|cut -d: -f2-)
	case $ITEM in
		OperatorID)
			OPID=$DATA
			continue;;
		Checksum|Checksum1|Mnemonic2)
			continue;;
		SLID)
			echo "ri.set SLID 0 ..."
			ritool set SLID 0
			continue;;
		*)
			echo "ri.set $ITEM $DATA ..."
			ritool set $ITEM $DATA
			;;
	esac
done
ritool set OperatorID $OPID
cd - >/dev/null
