#!/bin/sh


batch_test $1 $2
if [ $? -ne 0 ]; then
	echo "fail to batch"
	exit 1
fi

#set OperatorID value
ritool set OperatorID 9999

#retore to factory mode
cfgcli -r all

#reboot
reboot

# end banner
echo "Finish to upgrade FITS partition!"
