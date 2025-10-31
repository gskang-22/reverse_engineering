#! /bin/sh
syslogFile=/logs/messages
workrole=`cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole | awk -F "=" '{print $2}'`

if [ $workrole = "Controller" ]; then
    echo "/etc/init.d/syslog restart" >> $syslogFile
    /etc/init.d/syslog restart
else
    controllerIp=`cat /tmp/root_ip.txt`
    echo "/etc/init.d/rsyslog-sendout restart $controllerIp" >> $syslogFile
    /etc/init.d/rsyslog-sendout restart $controllerIp
fi
