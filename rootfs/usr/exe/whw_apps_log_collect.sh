#! /bin/sh
echo "start Collecting logs for whw_apps..."

cd /tmp/
log_dir_name=whw_apps_logs_"$(date +%Y%m%d%H%M%S)"
WHW_APPS_LOG_DIR=/tmp/$log_dir_name
mkdir $WHW_APPS_LOG_DIR

cp -a /flash/whw/edge_analytics/analytics.db $WHW_APPS_LOG_DIR
cp -a /flash/whw/cma/hie_timestamp.txt $WHW_APPS_LOG_DIR
cp -a /logs/messages* $WHW_APPS_LOG_DIR
cp -a /logs/customer* $WHW_APPS_LOG_DIR
cp -a /tmp/.meshinfo $WHW_APPS_LOG_DIR/meshinfo
cp -a /tmp/messages_info* $WHW_APPS_LOG_DIR
cp -a /logs/beacon_syslog* $WHW_APPS_LOG_DIR
cp -a /logs/applog* $WHW_APPS_LOG_DIR
cp -a /tmp/ddm_high_data_usage_log_files $WHW_APPS_LOG_DIR
cp -a /logs/ddm_btrace.log $WHW_APPS_LOG_DIR
cp -a /flash/whw/devusepeak.txt $WHW_APPS_LOG_DIR

comcli -m meshctl -u "dump all"
sleep 1
cp -a /tmp/meshctl_dump.txt $WHW_APPS_LOG_DIR

lanhostd dump > $WHW_APPS_LOG_DIR/lanhost_dump

comcli -m guestdev -u dumpguest 

cp -a /logs/core $WHW_APPS_LOG_DIR
       
ritool dump > $WHW_APPS_LOG_DIR/ritool_dump
cat /etc/buildinfo > $WHW_APPS_LOG_DIR/buildinfo

#ddm debug commands 
echo "[1] ps | grep ddm:" >> $WHW_APPS_LOG_DIR/ddm.txt
ps | grep ddm >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[2] uptime:" >> $WHW_APPS_LOG_DIR/ddm.txt
uptime >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[3] date:">> $WHW_APPS_LOG_DIR/ddm.txt
date >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[4] ddmcli show thread info:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli show thread info >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[5] ddmcli show debug info:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli show debug info  >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[6] ddmcli show session info:">> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli show session info  >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[7] ddmcli get queue info:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get queue info  >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[8] ddmcli get btree dump:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree dump >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[9] ddmcli dump dev stats:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli dump dev stats >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[10] ddmcli get btree stats:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree stats  >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[11] dmcli get btree analytics:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree analytics >> $WHW_APPS_LOG_DIR/ddm.txt 
echo -e "\n[12] ddmcli get btree devintf:", >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree devintf >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [13] ddmcli get btree fp:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree fp >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [14]ddmcli get btree unium:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get btree unium >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [15]ddmcli get mesh capability:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get mesh capability >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [16]ddmcli get mem profile info:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get mem profile info >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [17]ddmcli dump wan stats:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli dump wan stats >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [18]ddmcli get async profile info:" >> $WHW_APPS_LOG_DIR/ddm.txt
ddmcli get async profile info >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n [19] Beacon info datamodel :" >> $WHW_APPS_LOG_DIR/ddm.txt
cfgcli -e InternetGatewayDevice.X_ALU-COM_BeaconInfo. >> $WHW_APPS_LOG_DIR/ddm.txt


ddmcli debug commands
echo "[1] ifconfig:" >> $WHW_APPS_LOG_DIR/ddm.txt
ifconfig >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[2] route -n:" >> $WHW_APPS_LOG_DIR/ddm.txt
route -n >> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[3] iptables -L INPUT" >> $WHW_APPS_LOG_DIR/ddm.txt
iptables -L INPUT >> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[4] iptables -L FORWARD" >> $WHW_APPS_LOG_DIR/ddm.txt
iptables -L FORWARD >> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[5] iptables -L -nv:" >> $WHW_APPS_LOG_DIR/ddm.txt
iptables -L -nv >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[3] iptables -t mangle -L SNIFFER_FILTER -nv:" >> $WHW_APPS_LOG_DIR/ddm.txt
iptables -t mangle -L SNIFFER_FILTER -nv >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[6] iptables -t mangle -L PREROUTING  -nv:" >> $WHW_APPS_LOG_DIR/ddm.txt
iptables -t mangle -L PREROUTING  -nv >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[7] fpcli show config:" >> $WHW_APPS_LOG_DIR/ddm.txt
fpcli show config >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[8] fpcli show devinfo:" >> $WHW_APPS_LOG_DIR/ddm.txt
fpcli show devinfo >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[9] fpcli show alldevinfo:" >> $WHW_APPS_LOG_DIR/ddm.txt
fpcli show alldevinfo >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[10] brctl show:" >> $WHW_APPS_LOG_DIR/ddm.txt
brctl show >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[11] lanhostd dump:" >> $WHW_APPS_LOG_DIR/ddm.txt
lanhostd dump >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[12] ps -ww:" >> $WHW_APPS_LOG_DIR/ddm.txt
ps -ww >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[13] netstat -natpu:" >> $WHW_APPS_LOG_DIR/ddm.txt
netstat -natpu >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[14] dumpleases:" >> $WHW_APPS_LOG_DIR/ddm.txt
dumpleases >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[15] cfgcli -e Hosts.:" >> $WHW_APPS_LOG_DIR/ddm.txt
cfgcli -e Hosts. >> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[16] cfgcli -e X_ALU_WLANForGuest.1" >> $WHW_APPS_LOG_DIR/ddm.txt
cfgcli -e X_ALU_WLANForGuest.1>> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[17] cfgcli -e X_ALU_WLANForGuest.2" >> $WHW_APPS_LOG_DIR/ddm.txt
cfgcli -e X_ALU_WLANForGuest.2>> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n[18] cfgcli -e Hosts.:" >> $WHW_APPS_LOG_DIR/ddm.txt
cfgcli -e Hosts. >> $WHW_APPS_LOG_DIR/ddm.txt
echo -e "\n[19] iptables -t mangle -L FORWARD" >> $WHW_APPS_LOG_DIR/ddm.txt

iptables -t mangle -L FORWARD >> $WHW_APPS_LOG_DIR/ddm.txt

echo -e "\n Unium Curl outputs \n" >> $WHW_APPS_LOG_DIR/unium_output.txt

echo -e "\n[1] curl localhost:8090/1/aps/clients/sensing-data:" >> $WHW_APPS_LOG_DIR/unium_output.txt
curl localhost:8090/1/aps/clients/sensing-data >> $WHW_APPS_LOG_DIR/unium_output.txt

echo -e "\n[2] curl localhost:8090/1/network:" >> $WHW_APPS_LOG_DIR/unium_output.txt
curl localhost:8090/1/network >> $WHW_APPS_LOG_DIR/unium_output.txt

echo -e "\n[3] curl localhost:8090/1/toplogy:" >> $WHW_APPS_LOG_DIR/unium_output.txt
curl localhost:8090/1/topology >> $WHW_APPS_LOG_DIR/unium_output.txt

echo -e "\n[4] curl localhost:8090/1/aps/clients:" >> $WHW_APPS_LOG_DIR/unium_output.txt
curl localhost:8090/1/aps/clients >> $WHW_APPS_LOG_DIR/unium_output.txt


cp -a  /logs/guestdump.txt $WHW_APPS_LOG_DIR
cp -a  /logs/guest_btrace.log $WHW_APPS_LOG_DIR
cp -a  /logs/crash_logs.tar.gz $WHW_APPS_LOG_DIR
cp -a /tmp/.meshGwinfo* $WHW_APPS_LOG_DIR
cp -a /tmp/internetstatus $WHW_APPS_LOG_DIR
cp -a /tmp/wwd_log.txt $WHW_APPS_LOG_DIR
 
#####
log_file_name=$log_dir_name.tar
tar -cf $log_file_name $log_dir_name
rm -rf $WHW_APPS_LOG_DIR
cd -

echo "whw_apps log collection done and available in $WHW_APPS_LOG_DIR.tar ..."


