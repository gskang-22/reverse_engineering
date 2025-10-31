omcli omciMgr redirect `tty`
omcli omciMgr showAllUpStreamFlowInfo all
omcli omciMgr showAllDownStreamFlowInfo all
sleep 1
bs /b/e ingress_class
bs /b/e ingress_class flow
bs /bdmf/ex system children:yes max_prints:-1
bs /b/e vlan_action
bs /driver/rdd/pvdc 1
bs /b/e bridge
bs /d/r/pvdc 1 
bs /d/r/pvdc 0
bs /b/e egress_tm  

bs /b/e gem
bs /b/e tcont
bs /b/e port
sleep 1
//sleep 5s
bs /b/e gem
bs /b/e tcont
bs /b/e port
sleep 1
//sleep 5s
bs /b/e gem
bs /b/e tcont
bs /b/e port

