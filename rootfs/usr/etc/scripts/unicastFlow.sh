omcli omciMgr redirect `tty`
omcli omciMgr showAllUpStreamFlowInfo all
omcli omciMgr showAllDownStreamFlowInfo all
sleep 1
bs /b/e ingress_class max_prints:-1
bs /b/e egress_tm:max_prints:-1
bs /b/e gem
bs /b/e tcont
bs /b/e dscp_to_pbit
bs /b/e pbit_to_gem
vlanctl -if veip0 -all
vlanctl -if gpon0.0 -all
vlanctl -if gpon0 -all
bs /b/e ip_class
cat /proc/fcache/*
bs /b/e bridge
brctl show
ebtables -t broute -L
ebtables -L
ebtables -t nat -L
iptables-save
ip6tables-save
ip addr 
ip rule show
ip -6 rule show
cat /tmp/omci.log.bak
cat /tmp/omci.log
