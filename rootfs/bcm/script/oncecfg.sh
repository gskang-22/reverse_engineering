#!/bin/sh
########################################
# Just for once cfg of customer requires
########################################

OPID=$(ritool get OperatorID|cut -d: -f2)
BETA=$(cat /usr/etc/buildinfo |grep BUILDDATE|cut -d= -f2|cut -d_ -f1)
ZETA=/logs/oncecfg

# cases for custmomers
mkdir -p $ZETA
echo "OnceCfg for OPID:$OPID with ZETA:$ZETA ..."
case $OPID in
	ALCL)
		;;
	ALCO)
		;;
	ENTB)
		## Below case is for FR ALU02112974: ENTB Colombia new RCRs ALU01957187 & ALU01932914
		CAFE="$ZETA/ALU02112974"
		if [ $BETA -ge 20150812 -a $BETA -le 20150823 -a ! -e $CAFE ]; then
			cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPSEnable 1
			cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.MACAddressControlEnabled false
			touch $CAFE || echo "WARNING: touch $CAFE with failure"
		fi
		;;
	MXXT)
		;;
        SAIB)
                ;;
        MXXV)
                ;;
	STXX)
		;;
	XXXX)
		;;
	*)
		echo "WARNING: Skip $OPID during OnceCfg"
		;;
esac

