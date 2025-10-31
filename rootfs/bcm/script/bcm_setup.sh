#!/bin/sh
export LD_LIBRARY_PATH=/bcm/bin:/lib/gpl:$LD_LIBRARY_PATH
source /bcm/script/bcm_drivers

# Set system PATH
PATH=/bcm/bin:$PATH

## Set env for whw
if [ -e /usr/exe/whw ]; then
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/exe/whw/lib
	export PATH=$PATH:/usr/exe/whw/bin
fi

echo "execute apps_stage0.sh"
/bin/sh /usr/exe/apps_stage0.sh &

# Main startup from now on
# We need to down eth0 prior to starting runner's data path init
ifconfig eth0 down   >/dev/null  2>&1

# Load drivers and kernel modules
echo "Loading drivers and kernel modules... "
load_bcm_drivers

# Initialize bdmf shell
echo "Initializing bdmf shell... "
init_bdmf_shell

# Loading resource management module...
echo "Loading resource management module... "
load_rm_drv

# Initialize system
echo "Initializing system... "
init_system

#delete auto-create egress_tm to save resource
reset_ds_tm

# insmod phy_driver.ko ,add by denggaos
echo "insmod phy_driver... "
if [ -e /bcm/bin/phy_driver.ko ]
then
	echo "Install phy_driver.ko"
	insmod /bcm/bin/phy_driver.ko
else
	echo "Install phyadpt.ko"
	insmod /bcm/bin/phyadpt.ko
	phytool -d on
fi

# Initialize port
echo "Initializing port... "
init_port

# Loading bcm ioctl driver...
echo "Loading bcm ioctl driver.... "
load_bcmioctl_driver

# Loading klpd driver...
echo "Loading klpd driver... "
load_klpd_driver

# Load Bridge fast-path module
echo "Loading bridge fast-path module... "
load_br_fp

# Load flow cache module
echo "Loading flow cache module... "
load_flow_cache

# Load conntrack module and iptables
echo "Loading conntrack module and iptables..."
insmod $KER_MOD_DIR/ip_tables.ko
insmod $KER_MOD_DIR/iptable_filter.ko
insmod $KER_MOD_DIR/iptable_mangle.ko
insmod $KER_MOD_DIR/nf_conntrack.ko
insmod $KER_MOD_DIR/nf_nat.ko
insmod $KER_MOD_DIR/xt_nat.ko
insmod $KER_MOD_DIR/nfnetlink.ko
insmod $KER_MOD_DIR/nf_conntrack_ftp.ko
insmod $KER_MOD_DIR/nf_conntrack_h323.ko
insmod $KER_MOD_DIR/nf_defrag_ipv4.ko
insmod $KER_MOD_DIR/nf_conntrack_ipv4.ko
insmod $KER_MOD_DIR/nf_nat_ipv4.ko
insmod $KER_MOD_DIR/iptable_nat.ko
insmod $KER_MOD_DIR/ip_set.ko
insmod $KER_MOD_DIR/ip_set_hash_ip.ko
insmod $KER_MOD_DIR/xt_set.ko
insmod $KER_MOD_DIR/xt_string.ko
insmod $KER_MOD_DIR/ts_bm.ko


insmod $KER_MOD_DIR/ip6_tables.ko
insmod $KER_MOD_DIR/ip6table_filter.ko
insmod $KER_MOD_DIR/ip6table_mangle.ko
insmod $KER_MOD_DIR/ip6table_raw.ko

# Load Bcmdrvhoook Module
echo "insmod bcmhook..."
test -e /bcm/bin/bcmhook.ko && insmod /bcm/bin/bcmhook.ko

# Load bcm wlan driver
echo "Loading bcm wlan module... "
[ -e /bcm/script/init_wlan.sh ] && /bcm/script/init_wlan.sh

# Load Dyinggasp Module
echo "insmod dyingasp..."
insmod /bcm/bin/dying_gasp.ko

# Load iptv
echo "Loading iptv... "
init_iptv

# Load linux_if
echo "Loading linux_if "
init_linux_if

# Load linux bridge.
echo "Loading linux bridge..."
init_linux_bridge

# Initialize filter
echo "Initializing filter..."
init_filter

# Load Igmp driver
echo "Loading igmp driver... "
load_igmp_module

# Load dhcp driver
echo "Loading dhcp driver..."
load_dhcp_driver

# Load IPTV stat driver
echo "Loading iptv stat driver..."
load_iptv_stat_driver

# config ds egressTm by TMP            
echo "configing ds egressTm TMP..." 
config_ds_egressTm

# Config cpu rxq_size of wlan
echo "Configing  cpu rxq_size of wlan..."
config_wlan_cpu_rxq_size

dmesg -n 8

# Load appmgr
echo "start appmgr"
init_pre_app
/sbin/appmgr &

#start diagnosis
echo "Start diagnosis"
/sbin/diagnosis &

# launch saved_ip
if [ -e /configs/saved_ip ]; then
	/configs/saved_ip
fi

# Start daemon
echo "Start daemon..."
/usr/exe/daemon  &

echo "run after app start..."
if [ -x /configs/post_app_script.sh ];then
	saferun /configs/post_app_script.sh &
fi

## check configs link
if [ -x /bcm/script/cfglnk.sh ]; then
	/bcm/script/cfglnk.sh
fi

## selftest
if [ -x ${USR_EXE_DIR}/selftest ]; then
	echo "run selftest ..."
	${USR_EXE_DIR}/selftest
fi

## start whw_middleware
#echo "Start WHW..."
#[ -x /usr/exe/whw/bin/startwhw.sh ] && source /usr/exe/whw/bin/startwhw.sh && start_whw&

if [ -x /usr/exe/check_ed_thresh.sh ]; then
	echo "Go checking phy_ed_thresh"
	/usr/exe/check_ed_thresh.sh &
fi

# free caches
sync
echo 3 > /proc/sys/vm/drop_caches

