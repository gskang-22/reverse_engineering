#! /bin/sh

#echo "Configure SFU flows:  lan0,lan1,lan2,lan3's default_vlan as 100,200,300,400;data_vlan=10,pbit=0;video_vlan=20,pbit=3;voice_vlan=30,pbit=5;ISP/RG/MGMT vlan=40,pbit=6"

configure_us_untag_vlan_action() {
bs /b/new vlan_action/dir=us,index=0
bs /b/c vlan_action/dir=us,index=0 action={cmd=push_always,ovid=100}
bs /b/new vlan_action/dir=us,index=1
bs /b/c vlan_action/dir=us,index=1 action={cmd=push_always,ovid=200}
bs /b/new vlan_action/dir=us,index=2
bs /b/c vlan_action/dir=us,index=2 action={cmd=push_always,ovid=300}
bs /b/new vlan_action/dir=us,index=3
bs /b/c vlan_action/dir=us,index=3 action={cmd=push_always,ovid=400}
}

configure_us_priority_tag_vlan_action() {
bs /b/new vlan_action/dir=us,index=5
bs /b/c vlan_action/dir=us,index=5 action={cmd=replace,ovid=100}
bs /b/new vlan_action/dir=us,index=6
bs /b/c vlan_action/dir=us,index=6 action={cmd=replace,ovid=200}
bs /b/new vlan_action/dir=us,index=7
bs /b/c vlan_action/dir=us,index=7 action={cmd=replace,ovid=300}
bs /b/new vlan_action/dir=us,index=8
bs /b/c vlan_action/dir=us,index=8 action={cmd=replace,ovid=400}
}
#
configure_us_data_vlan_action() {
bs /b/new vlan_action/dir=us,index=10
bs /b/c vlan_action/dir=us,index=10 action={cmd=replace,ovid=110}
bs /b/new vlan_action/dir=us,index=11
bs /b/c vlan_action/dir=us,index=11 action={cmd=replace,ovid=210}
bs /b/new vlan_action/dir=us,index=12
bs /b/c vlan_action/dir=us,index=12 action={cmd=replace,ovid=310}
bs /b/new vlan_action/dir=us,index=13
bs /b/c vlan_action/dir=us,index=13 action={cmd=replace,ovid=410}
}
#
configure_us_video_vlan_action() {
bs /b/new vlan_action/dir=us,index=20
bs /b/c vlan_action/dir=us,index=20 action={cmd=replace,ovid=120}
bs /b/new vlan_action/dir=us,index=21
bs /b/c vlan_action/dir=us,index=21 action={cmd=replace,ovid=220}
bs /b/new vlan_action/dir=us,index=22
bs /b/c vlan_action/dir=us,index=22 action={cmd=replace,ovid=320}
bs /b/new vlan_action/dir=us,index=23
bs /b/c vlan_action/dir=us,index=23 action={cmd=replace,ovid=420}
}
#
#us voice vlan_action
configure_us_voice_vlan_action() {
bs /b/new vlan_action/dir=us,index=30
bs /b/c vlan_action/dir=us,index=30 action={cmd=replace,ovid=130}
bs /b/new vlan_action/dir=us,index=31
bs /b/c vlan_action/dir=us,index=31 action={cmd=replace,ovid=230}
bs /b/new vlan_action/dir=us,index=32
bs /b/c vlan_action/dir=us,index=32 action={cmd=replace,ovid=330}
bs /b/new vlan_action/dir=us,index=33
bs /b/c vlan_action/dir=us,index=33 action={cmd=replace,ovid=430}
}

#
#us mgnt vlan_action
configure_us_mgnt_vlan_action() {
bs /b/new vlan_action/dir=us,index=40
bs /b/c vlan_action/dir=us,index=40 action={cmd=replace,ovid=140}
bs /b/new vlan_action/dir=us,index=41
bs /b/c vlan_action/dir=us,index=41 action={cmd=replace,ovid=240}
bs /b/new vlan_action/dir=us,index=42
bs /b/c vlan_action/dir=us,index=42 action={cmd=replace,ovid=340}
bs /b/new vlan_action/dir=us,index=43
bs /b/c vlan_action/dir=us,index=43 action={cmd=replace,ovid=440}
}

#
###downstream vlan_action
#
#ds single default_vlan vlan_action
configure_ds_default_vlan_action() {
bs /b/new vlan_action/dir=ds,index=1
bs /b/c vlan_action/dir=ds,index=1 action={cmd=pop}
}
#
#ds data vlan_action
configure_ds_data_vlan_action() {
bs /b/new vlan_action/dir=ds,index=10
bs /b/c vlan_action/dir=ds,index=10 action={cmd=replace,ovid=10}
}

#
#ds video vlan_action
configure_ds_video_vlan_action() {
bs /b/new vlan_action/dir=ds,index=20
bs /b/c vlan_action/dir=ds,index=20 action={cmd=replace,ovid=20}
}

#
#ds voice vlan_action
configure_ds_voice_vlan_action() {
bs /b/new vlan_action/dir=ds,index=30
bs /b/c vlan_action/dir=ds,index=30 action={cmd=replace,ovid=30}
}

#
#ds mgnt vlan_action
configure_ds_mgnt_vlan_action() {
bs /b/new vlan_action/dir=ds,index=40
bs /b/c vlan_action/dir=ds,index=40 action={cmd=replace,ovid=40}
}

#
###upstream ingress_class_flow
#
#us untag ingress_class_flow
configure_us_untag_ingress_class() {
bs /b/new ingress_class/dir=us,index=0,cfg={type=flow,fields=ingress_port+vlan_num,prty=8,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=0 flow string key={ingress_port=2,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=0}}
bs /bdmf/attr/add ingress_class/dir=us,index=0 flow string key={ingress_port=3,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=1}}
bs /bdmf/attr/add ingress_class/dir=us,index=0 flow string key={ingress_port=4,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=2}}
bs /bdmf/attr/add ingress_class/dir=us,index=0 flow string key={ingress_port=5,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=3}}
}
#
#us priority_tag ingress_class_flow
configure_us_priority_tag_ingress_class() {
bs /b/new ingress_class/dir=us,index=1,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid,prty=9,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=1 flow string key={ingress_port=2,vlan_num=1,outer_vid=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=5}}
bs /bdmf/attr/add ingress_class/dir=us,index=1 flow string key={ingress_port=3,vlan_num=1,outer_vid=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=6}}
bs /bdmf/attr/add ingress_class/dir=us,index=1 flow string key={ingress_port=4,vlan_num=1,outer_vid=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=7}}
bs /bdmf/attr/add ingress_class/dir=us,index=1 flow string key={ingress_port=5,vlan_num=1,outer_vid=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=8}}
}

#
#us data ingress_class_flow
configure_us_data_ingress_class() {
bs /b/new ingress_class/dir=us,index=2,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=10,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=1,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=10}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=2,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=10}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=1,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=11}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=2,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=11}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=1,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=12}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=2,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=12}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=1,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=13}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=2,outer_vid=10,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=13}}
}

#
#us video ingress_class_flow
configure_us_video_ingress_class() {
bs /b/new ingress_class/dir=us,index=2,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=10,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=1,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=20}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=2,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=20}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=1,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=21}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=2,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=21}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=1,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=22}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=2,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=22}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=1,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=23}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=2,outer_vid=20,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=23}}
}

#
#us voice ingress_class_flow
configure_us_voice_ingress_class() {
bs /b/new ingress_class/dir=us,index=2,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=10,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=1,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=30}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=2,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=30}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=1,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=31}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=2,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=31}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=1,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=32}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=2,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=32}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=1,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=33}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=2,outer_vid=30,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=33}}
}

#
#us mgnt ingress_class_flow
configure_us_mgnt_ingress_class() {
bs /b/new ingress_class/dir=us,index=2,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=10,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=1,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=40}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=2,vlan_num=2,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=40}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=1,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=41}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=3,vlan_num=2,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=41}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=1,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=42}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=4,vlan_num=2,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=42}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=1,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=43}}
bs /bdmf/attr/add ingress_class/dir=us,index=2 flow string key={ingress_port=5,vlan_num=2,outer_vid=40,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=43}}
}

#
#
###downstream ingress_class_flow
#
#ds single default_vlan ingress_class_flow
configure_ds_default_vlan_ingress_class() {
bs /b/new ingress_class/dir=ds,index=1,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid,prty=40,acl_mode=black,port_mask=wan0+wan1}
bs /bdmf/attr/add ingress_class/dir=ds,index=1 flow string key={ingress_port=0,vlan_num=1,outer_vid=100},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=1}}
bs /bdmf/attr/add ingress_class/dir=ds,index=1 flow string key={ingress_port=0,vlan_num=1,outer_vid=200},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=1}}
bs /bdmf/attr/add ingress_class/dir=ds,index=1 flow string key={ingress_port=0,vlan_num=1,outer_vid=300},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=1}}
bs /bdmf/attr/add ingress_class/dir=ds,index=1 flow string key={ingress_port=0,vlan_num=1,outer_vid=400},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=1}}
}
#
#ds data ingress_class_flow
configure_ds_data_ingress_class() {
bs /b/new ingress_class/dir=ds,index=0,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=50,acl_mode=black,port_mask=wan0+wan1}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=110,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=110,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=210,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=210,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=310,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=310,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=410,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=410,outer_pbit=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=10}}
}

#
#ds video ingress_class_flow
configure_ds_video_ingress_class() {
bs /b/new ingress_class/dir=ds,index=0,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=50,acl_mode=black,port_mask=wan0+wan1}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=120,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=120,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=220,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=220,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=320,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=320,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=420,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=420,outer_pbit=3},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=20}}
}

#
#ds voice ingress_class_flow
configure_ds_voice_ingress_class() {
bs /b/new ingress_class/dir=ds,index=0,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=50,acl_mode=black,port_mask=wan0+wan1}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=130,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=130,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=230,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=230,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=330,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=330,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=430,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=430,outer_pbit=5},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=30}}
}

#
#ds mgnt ingress_class_flow
configure_ds_mgnt_ingress_class() {
bs /b/new ingress_class/dir=ds,index=0,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid+outer_pbit,prty=50,acl_mode=black,port_mask=wan0+wan1}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=140,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=140,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan0,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=240,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=240,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan1,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=340,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=340,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan2,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=1,outer_vid=440,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
bs /bdmf/attr/add ingress_class/dir=ds,index=0 flow string key={ingress_port=0,vlan_num=2,outer_vid=440,outer_pbit=6},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=lan3,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=40}}
}

#

#create default vlan flow
create_default_vlan_flow() {
configure_us_untag_vlan_action
echo "configure_us_untag_vlan_action $?"
configure_us_untag_ingress_class
echo "configure_us_untag_ingress_class $?"

configure_us_priority_tag_vlan_action
echo "configure_us_priority_tag_vlan_action $?"
configure_us_priority_tag_ingress_class
echo "configure_us_priority_tag_ingress_class $?"

configure_ds_default_vlan_action
echo "configure_ds_default_vlan_action $?"
configure_ds_default_vlan_ingress_class
echo "configure_ds_default_vlan_ingress_class $?"
}

create_data_flow() {
configure_us_data_vlan_action
echo "configure_us_data_vlan_action $?"
configure_us_data_ingress_class
echo "configure_us_data_ingress_class $?"

configure_ds_data_vlan_action
echo "configure_ds_data_vlan_action $?"
configure_ds_data_ingress_class
echo "configure_ds_data_ingress_class $?"
}

create_video_flow() {
configure_us_video_vlan_action
echo "configure_us_video_vlan_action $?"
configure_us_video_ingress_class
echo "configure_us_video_ingress_class $?"

configure_ds_video_vlan_action
echo "configure_ds_video_vlan_action $?"
configure_ds_video_ingress_class
echo "configure_ds_video_ingress_class $?"
}

create_voice_flow() {
configure_us_voice_vlan_action
echo "configure_us_voice_vlan_action $?"
configure_us_voice_ingress_class
echo "configure_us_voice_ingress_class $?"

configure_ds_voice_vlan_action
echo "configure_ds_voice_vlan_action $?"
configure_ds_voice_ingress_class
echo "configure_ds_voice_ingress_class $?"
}

create_mgnt_flow() {
configure_us_mgnt_vlan_action
echo "configure_us_mgnt_vlan_action $?"
configure_us_mgnt_ingress_class
echo "configure_us_mgnt_ingress_class $?"

configure_ds_mgnt_vlan_action
echo "configure_ds_mgnt_vlan_action $?"
configure_ds_mgnt_ingress_class
echo "configure_ds_mgnt_ingress_class $?"
}

create_all_flows() {
create_default_vlan_flow
echo "create_default_vlan_flow: [ lan0,lan1,lan2,lan3's default_vlan is 100,200,300,400] $?"

create_data_flow
echo "create_data_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 10/0; ds vlan/pbit is 110/0 210/0 310/0 410/0] $?"

create_video_flow
echo "create_video_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 20/3; ds vlan/pbit is 120/3 220/3 320/3 420/3] $?"

create_voice_flow
echo "create_voice_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 30/5; ds vlan/pbit is 130/5 230/5 330/5 430/5] $?"

create_mgnt_flow
echo "create_mgnt_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 40/6; ds vlan/pbit is 140/6 240/6 340/6 440/6] $?"
}


create_hardware_QT_test_l2_flows()
{
    bs /b/e ingress_class max_prints:-1
    bs /b/e vlan_action max_prints:-1
    bs /b/d ingress_class/dir=ds,index=0
    bs /b/e ingress_class max_prints:-1
    bs /b/e vlan_action max_prints:-1

    if [ $# = 1  ]
    then
        case $1 in
        default) create_default_vlan_flow && echo "create_default_vlan_flow: [ lan0,lan1,lan2,lan3's default_vlan is 100,200,300,400] $?" && exit 0 ;;
        data)    create_data_flow && echo "create_data_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 10/0; ds vlan/pbit is 110/0 210/0 310/0 410/0] $?" && exit 0 ;;
        video)   create_video_flow && echo "create_video_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 20/3; ds vlan/pbit is 120/3 220/3 320/3 420/3] $?" && exit 0 ;;
        voice)   create_voice_flow && echo "create_voice_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 30/5; ds vlan/pbit is 130/5 230/5 330/5 430/5] $?" && exit 0 ;;
        mgnt)    create_mgnt_flow && echo "create_mgnt_flow: [ lan0,lan1,lan2,lan3's us vlan/pbit is 40/6; ds vlan/pbit is 140/6 240/6 340/6 440/6] $?" && exit 0 ;;
        esac
    else
        create_all_flows
        echo "create_all_flows $?, Configure SFU flows:  lan0,lan1,lan2,lan3's default_vlan as 100,200,300,400;data_vlan=10,pbit=0;video_vlan=20,pbit=3;voice_vlan=30,pbit=5;ISP/RG/MGMT vlan=40,pbit=6"
        
    fi
}


####################################################################factory l2 flow#######################################################


create_factory_l2_flow_us_vlan_action()
{
    vid=100
    if [ $# = 1 ];then
        vid=$1
    fi
    echo "us vlan_action push vid = $vid"
    
    bs /b/new vlan_action/dir=us,index=60
    bs /b/c vlan_action/dir=us,index=60 action={cmd=push_always,ovid=100}
}

create_factory_l2_flow_ds_vlan_action()
{
    bs /b/new vlan_action/dir=ds,index=60
    bs /b/c vlan_action/dir=ds,index=60 action={cmd=pop}
}


create_factory_l2_flow_us_ingress_class()
{
    bs /b/new ingress_class/dir=us,index=6,cfg={type=flow,fields=ingress_port+vlan_num,prty=60,acl_mode=black,port_mask=lan0+lan1+lan2+lan3+lan4}
    bs /bdmf/attr/add ingress_class/dir=us,index=6 flow string key={ingress_port=2,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=60}}
    bs /bdmf/attr/add ingress_class/dir=us,index=6 flow string key={ingress_port=3,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=60}}
    bs /bdmf/attr/add ingress_class/dir=us,index=6 flow string key={ingress_port=4,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=60}}
    bs /bdmf/attr/add ingress_class/dir=us,index=6 flow string key={ingress_port=5,vlan_num=0},result={qos_method=flow,action=forward,forw_mode=flow,egress_port=wan0,queue_id=0,wan_flow=0,vlan_action={vlan_action/dir=us,index=60}}
}


create_factory_l2_flow_ds_ingress_class()
{
    vid=100
    if [ $# = 1 ];then
        vid=$1
    fi
    echo "ds ingress_class filter vid = $vid"
    
    bs /b/new ingress_class/dir=ds,index=6,cfg={type=flow,fields=ingress_port+vlan_num+outer_vid,prty=60,acl_mode=black,port_mask=wan0+wan1}
    bs /bdmf/attr/add ingress_class/dir=ds,index=6 flow string key={ingress_port=0,vlan_num=1,outer_vid=$vid},result={qos_method=flow,action=forward,forw_mode=packet,queue_id=0,wan_flow=1,vlan_action={vlan_action/dir=ds,index=60}}

}

#create factory l2 flow, us untag; ds the same vlan id to different lan port base mac forward
create_factory_l2_flow()
{
    vid=100
    if [ $# = 1 ];then
        vid=$1
    fi
    echo "create factory l2 flow, us filter untag, then add vlan $vid; ds filter single tag, then pop vlan $vid and forward to different lan port base mac"
    
    create_factory_l2_flow_us_vlan_action $vid
    create_factory_l2_flow_ds_vlan_action
    create_factory_l2_flow_us_ingress_class
    create_factory_l2_flow_ds_ingress_class $vid
}


create_l2_flows()
{
    if [ $# = 1  ]
    then
        case $1 in
        "factory") create_factory_l2_flow 100 ;;
        "QT")      create_hardware_QT_test_l2_flows ;;
        esac      
    fi    
}

create_l2_flows $1

exit 0




