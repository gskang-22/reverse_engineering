#!/bin/sh

#lan_filter_reason_list="\
#bcast dhcp  \
#etype_arp etype_802_1x etype_pppoe_d ip_frag"
#wan_filter_reason_list="\
#bcast dhcp  \
#etype_arp etype_802_1x ip_frag"

#only trap arp packets to CPU in p2p mode
lan_filter_reason_list="etype_arp"
wan_filter_reason_list="etype_arp"

lan_filter_port_list="lan0 lan1 lan2 lan3"
wan_filter_port_list="wan0"

#Modify egress_tm
modify_egress_tm(){
  #US egress_tm, total 3k, attribute 2k
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[0]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[1]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[2]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[3]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[4]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[5]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[6]={drop_threshold=256}
  bs /b/c egress_tm/dir=us,index=0 queue_cfg[7]={drop_threshold=256}

  #lan0
  bs /b/c egress_tm/dir=ds,index=0 queue_cfg[0]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=0 queue_cfg[1]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=0 queue_cfg[2]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=0 queue_cfg[3]={drop_threshold=128}
  bs /bdmf/configure egress_tm/dir=ds,index=0 queue_cfg[4]={queue_id=4,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=0 queue_cfg[5]={queue_id=5,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=0 queue_cfg[6]={queue_id=6,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=0 queue_cfg[7]={queue_id=7,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}

  #lan1
  bs /b/c egress_tm/dir=ds,index=1 queue_cfg[0]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=1 queue_cfg[1]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=1 queue_cfg[2]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=1 queue_cfg[3]={drop_threshold=128}
  bs /bdmf/configure egress_tm/dir=ds,index=1 queue_cfg[4]={queue_id=4,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=1 queue_cfg[5]={queue_id=5,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=1 queue_cfg[6]={queue_id=6,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=1 queue_cfg[7]={queue_id=7,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}

  #lan2
  bs /b/c egress_tm/dir=ds,index=2 queue_cfg[0]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=2 queue_cfg[1]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=2 queue_cfg[2]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=2 queue_cfg[3]={drop_threshold=128}
  bs /bdmf/configure egress_tm/dir=ds,index=2 queue_cfg[4]={queue_id=4,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=2 queue_cfg[5]={queue_id=5,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=2 queue_cfg[6]={queue_id=6,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=2 queue_cfg[7]={queue_id=7,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}

  #lan3
  bs /b/c egress_tm/dir=ds,index=3 queue_cfg[0]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=3 queue_cfg[1]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=3 queue_cfg[2]={drop_threshold=128}
  bs /b/c egress_tm/dir=ds,index=3 queue_cfg[3]={drop_threshold=128}
  bs /bdmf/configure egress_tm/dir=ds,index=3 queue_cfg[4]={queue_id=4,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=3 queue_cfg[5]={queue_id=5,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=3 queue_cfg[6]={queue_id=6,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
  bs /bdmf/configure egress_tm/dir=ds,index=3 queue_cfg[7]={queue_id=7,drop_threshold=128,weight=0,drop_alg=dt,red_high_threshold=0,red_low_threshold=0}
}

#port_cfg
modify_port() {
  
#  bs /bdmf/c port/index=cpu cfg={sal=yes,dal=yes,sal_miss_action=host,dal_miss_action=forward}
  bs /bdmf/c port/index=lan0 cfg={sal=yes,dal=yes,sal_miss_action=host,dal_miss_action=forward}
  bs /bdmf/c port/index=lan1 cfg={sal=yes,dal=yes,sal_miss_action=host,dal_miss_action=forward}
  bs /bdmf/c port/index=lan2 cfg={sal=yes,dal=yes,sal_miss_action=host,dal_miss_action=forward}
  bs /bdmf/c port/index=lan3 cfg={sal=yes,dal=yes,sal_miss_action=host,dal_miss_action=forward}
  bs /bdmf/c port/index=wan0 cfg={sal=no,dal=yes,sal_miss_action=host,dal_miss_action=forward}
}
#filter_cfg
configure_filter() {
  for port in $lan_filter_port_list; do
    for reason in $lan_filter_reason_list; do
      bs /bdmf/configure filter entry[{filter=$reason,ports=$port}]={enabled=yes,action=host}
    done
  done

  for port in $wan_filter_port_list; do
    for reason in $wan_filter_reason_list; do
      bs /bdmf/configure filter entry[{filter=$reason,ports=$port}]={enabled=yes,action=host}
    done
  done
}
#Modify pbit_to_queue
configure_pbit_to_queue() {
  bs /bdmf/new pbit_to_queue/table=0
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[0]=7
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[1]=6
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[2]=5
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[3]=4
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[4]=3
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[5]=2
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[6]=1
  bs /bdmf/configure pbit_to_queue/table=0 pbit_map[7]=0
  bs /bdmf/link port/index=lan0 pbit_to_queue/table=0
  bs /bdmf/new pbit_to_queue/table=1
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[0]=7
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[1]=6
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[2]=5
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[3]=4
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[4]=3
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[5]=2
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[6]=1
  bs /bdmf/configure pbit_to_queue/table=1 pbit_map[7]=0
  bs /bdmf/link port/index=lan1 pbit_to_queue/table=1
  bs /bdmf/new pbit_to_queue/table=2
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[0]=7
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[1]=6
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[2]=5
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[3]=4
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[4]=3
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[5]=2
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[6]=1
  bs /bdmf/configure pbit_to_queue/table=2 pbit_map[7]=0
  bs /bdmf/link port/index=lan2 pbit_to_queue/table=2
  bs /bdmf/new pbit_to_queue/table=3
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[0]=7
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[1]=6
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[2]=5
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[3]=4
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[4]=3
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[5]=2
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[6]=1
  bs /bdmf/configure pbit_to_queue/table=3 pbit_map[7]=0
  bs /bdmf/link port/index=lan3 pbit_to_queue/table=3
  bs /bdmf/new pbit_to_queue/table=4
  bs /b/c pbit_to_queue/table=4 pbit_map[0]=7
  bs /b/c pbit_to_queue/table=4 pbit_map[1]=6
  bs /b/c pbit_to_queue/table=4 pbit_map[2]=5
  bs /b/c pbit_to_queue/table=4 pbit_map[3]=4
  bs /b/c pbit_to_queue/table=4 pbit_map[4]=3
  bs /b/c pbit_to_queue/table=4 pbit_map[5]=2
  bs /b/c pbit_to_queue/table=4 pbit_map[6]=1
  bs /b/c pbit_to_queue/table=4 pbit_map[7]=0
  bs /b/link pbit_to_queue/table=4 port/index=wan0
}

#Config system
configure_system() {
  bs /b/c system cfg={mtu_size=2000}
}

#cfg_local_forward_disable
disable_local_forward() {
  bs /b/c bridge/index=0 local_switch_enable={no}
}

#configure cpu meter
configure_cpu_meter() {
  bs /b/c cpu/index=host meter_cfg[{dir=us,index=2}]={sir=1200} 
  bs /b/c cpu/index=host meter_cfg[{dir=ds,index=2}]={sir=800}
  bs /b/c cpu/index=host reason_cfg[{dir=us,reason=etype_arp}]={meter=2}
  bs /b/c cpu/index=host reason_cfg[{dir=ds,reason=etype_arp}]={meter=2}
}

#add eth0-eth3 to br0
config_linux_br0() {
brctl addbr br0
ifconfig br0 192.168.1.254 netmask 255.255.255.0 up

brctl addif br0 eth0
ifconfig eth0 up
brctl addif br0 eth1
ifconfig eth1 up
brctl addif br0 eth2
ifconfig eth2 up
brctl addif br0 eth3
ifconfig eth3 up

}

config_linux_wan0() {
ifconfig eth_wan0 192.168.4.254 netmask 255.255.255.0 up
bs /b/c ip_class routed_mac[0]={30:30:30:30:30:31}
}

config_l2_flow() {
    op_id=$(/sbin/ritool get OperatorID |grep OperatorID |awk '{print substr($2,12,4)}')
    echo ${op_id}
    echo $#
    factory_opid="0000"

    if [ "$1" = "factory" -o "$op_id" = $factory_opid ];then
        /bcm/script/create_flow_script.sh factory     
    elif [ "$1" = "QT" ];then
        /bcm/script/create_flow_script.sh QT  
    fi

}



#config_linux_br0
#echo "config_linux_br0 $?"

#config_linux_wan0
#echo "config_linux_wan0 $?"

#echo "init_gbe_wan_port"
#/sbin/p2p
#sleep 2
#configure system 
#configure_system
#echo "configure system $?"

#configure_cpu_meter
#echo "configure_cpu_meter $?"

#configure_filter
#echo "config filter $?"

#disable_local_forward
#echo "disable local forward $?"

eth_wanport_init_done_file="/tmp/eth_wanport_init_done"
while [ ! -e ${eth_wanport_init_done_file} ]
do
	sleep 1	
done

modify_port
echo "modify port $?"

modify_egress_tm
echo "modify egress tm $?"

#configure_pbit_to_queue
#echo "configure pbit to queue $?"

config_l2_flow
