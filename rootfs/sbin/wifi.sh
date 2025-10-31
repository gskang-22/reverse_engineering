#!/bin/sh

######################################
#
# Para: enter / exit
# Date: 2016/11/22
#
#######################################

usage()
{
    echo
    echo "  usage:"
    echo "          wifi.sh enter / exit"
    echo
}

wifi_off()
{
    flag=0
    Radio_2G4=$(cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.RadioEnabled | awk -F '=' '{print $2}')
    Radio_5G=$(cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.RadioEnabled | awk -F '=' '{print $2}')
    #Radio_2G4="true"
    #Radio_5G="true"
    echo "============"
    echo "Keypeople:: Radio_2G4: $Radio_2G4" Radio_5G: $Radio_5G
    echo "============"
    [ $Radio_2G4 = true ] && {
        echo "To disable radio_2G4."
        cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.RadioEnabled 0
        #flag=$(cfgcli -g InternetGatewayDevice.X_ALU-COM_WifiSchedule.Schedule.1.Flag | awk -F '=' '{print $2}') 
        let "flag += 1";
        sleep 2;
    }

    [ "$Radio_5G" = "true" ] && {
        echo "To disable radio_5G."
        cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.RadioEnabled 0
        let "flag += 2";
        sleep 2;
    }
    echo "Keypeople:: To set flag = $flag";
    cfgcli -s InternetGatewayDevice.X_ALU-COM_WifiSchedule.Flag $flag
}

wifi_on()
{
    Radio_2G4=$(cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.RadioEnabled | awk -F '=' '{print $2}')
    Radio_5G=$(cfgcli -g InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.RadioEnabled | awk -F '=' '{print $2}')
    #Radio_2G4="false"
    #Radio_5G="false"
    flag=$(cfgcli -g InternetGatewayDevice.X_ALU-COM_WifiSchedule.Flag | awk -F '=' '{print $2}')
    #flag=1
    [ "$Radio_2G4" = "false" ] && {
        [ $flag = 3 -o $flag = 1 ] && {
            let "flag -= 1"
            echo "To enable radio_2G4, flag = $flag";
            cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.RadioEnabled 1
            sleep 2;
        }
    }

    [ "$Radio_5G" = "false" ] && {
        [ "$flag" = "3" -o "$flag" = "2" ] && {
            let "flag -= 2"
            echo "To enable radio_5G, flag = $flag";
            cfgcli -s InternetGatewayDevice.LANDevice.1.WLANConfiguration.5.RadioEnabled 1
            sleep 2;
        }
    }
    echo "Keypeople:: To set flag = $flag";
    cfgcli -s InternetGatewayDevice.X_ALU-COM_WifiSchedule.Flag $flag
}

#####  Enter
[ $# -ne 1 ] && usage || {

    #para=$(echo "$1" | tr '[A-Z]' '[a-z]')
    para="$1"
    [ "$para" != "enter" -a "$para" != "exit" ] && usage

    if [ "$para" = "enter" ]; then
        echo "para is enter."
        wifi_off
    fi

    if [ "$para" = "exit" ]; then
        echo "para is exit."
        wifi_on
    fi

}
