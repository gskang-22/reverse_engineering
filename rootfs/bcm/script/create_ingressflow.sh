#!/bin/sh

apply_ingress_flow() {

  oldstatus=`cfgcli -g InternetGatewayDevice.GRE.X_ALU-COM_TunnelMode | cut -d = -f2`

  if [ ! -z "$oldstatus" -a "$oldstatus" != " " -a "$oldstatus" == 2 ];
    then
        echo "***************** Applying Tunnel Configuration ******************"
        cfgcli -s InternetGatewayDevice.GRE.X_ALU-COM_TunnelMode 0
        cfgcli -s InternetGatewayDevice.GRE.X_ALU-COM_TunnelMode $oldstatus
        echo "******************************************************************"
    fi
}

apply_ingress_flow

bs /b/c cpu/index=host reason_cfg[{dir=us,reason=flow}]={queue=3,meter=-1,meter_ports=0}
bs /b/c cpu/index=host reason_cfg[{dir=ds,reason=ip_flow_miss}]={queue=3,meter=-1,meter_ports=0} 

bs /b/c cpu/index=host reason_cfg[{dir=ds,reason=ip_flow_miss}]={queue=4,meter=-1,meter_ports=0}
bs /b/c ip_class l4_filter[gre]={action=host,protocol=0x2f} 

