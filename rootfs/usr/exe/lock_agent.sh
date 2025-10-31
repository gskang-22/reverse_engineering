#!/bin/sh

#periodically checking in seconds
CHECK_INTERVAL=20

#Timeout(seconds) to visit lock server URL 
TIME_OUT=10

#CertFile
CERT_FILE="/usr/cfg/balitower.pem"

#LogFile
LOG_FILE="/tmp/lock_agent.log"

#LockingServerUrl
server_url=`cfgcli -g InternetGatewayDevice.UserInterface.X_ALU-COM_CarrierLocking.X_ALU-COM_LockingServerUrl | awk -F "=" '{print $2}'`

#LockingStatus
lock_status="LOCKED"
unlock_status="UL02"

update_locking_status(){
    cfgcli -fs InternetGatewayDevice.UserInterface.X_ALU-COM_CarrierLocking.X_ALU-COM_LockingStatus $1
}

#Init lockingStatus to unlock
iptables -D INPUT_WAN_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT 2>/dev/null
iptables -I INPUT_WAN_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT
cfgcli -s InternetGatewayDevice.UserInterface.X_ALU-COM_CarrierLocking.X_ALU-COM_LockingEnable true
update_locking_status ${unlock_status}  

while true
do
    echo -e "\n[`date -u '+%F %T'`][LOCKAGENT]: **********CURL BIBT SERVER RESULT**********\n" > ${LOG_FILE}
    response=`curl -m $TIME_OUT -s -k --cert $CERT_FILE $server_url`
    allow_ack=`awk -v s="$response" 'BEGIN {r="Allow"; print match(s, r)}'`
    deney_ack=`awk -v s="$response" 'BEGIN {r="Deny"; print match(s, r)}'`
    if [ ${allow_ack} -ne 0 -a ${deney_ack} -eq 0 ]; then
        echo "[`date -u '+%F %T'`][LOCKAGENT]: Access lockingServer successfully and get allow" >> ${LOG_FILE}
        update_locking_status ${unlock_status}
        iptables -D INPUT_WAN_REMOTE_ACCESS -p tcp --sport 443 -j ACCEPT 2>/dev/null
        exit
    elif [ ${allow_ack} -eq 0 -a ${deney_ack} -ne 0 ]; then
        echo "[`date -u '+%F %T'`][LOCKAGENT]: Access lockingServer get deny" >> ${LOG_FILE}
        update_locking_status ${lock_status}
    else
        echo "[`date -u '+%F %T'`][LOCKAGENT]: curl time out" >> ${LOG_FILE}
    fi
    sleep $CHECK_INTERVAL
done
