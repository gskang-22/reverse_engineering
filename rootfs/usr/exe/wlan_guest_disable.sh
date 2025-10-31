#!/bin/sh
cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.Enable 0
sed -i "/wlan_guest_disable.sh $1/d" /configs/spc/timer/root
#cfgcli del InternetGatewayDevice.LANDevice.1.X_ALU_WLANForGuest.$2.
