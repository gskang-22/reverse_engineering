#!/bin/sh
####################################################################
# Alcatel-Lucent ONT Platform Init Script
# Pusrpose: Board, Common Module Init
# Note: for Broadcom Platform.
####################################################################

shift

#when kernel is panic, wait for 5s, then reboot @xupingl
echo 5 > /proc/sys/kernel/panic

#increase the free page low threshold to 5148K, the default is 1287K. add by xufuguo, 20130112
#this make mem allocator wakes up kswapd in time to reclaim cache and buffer,
#then avoid of page allocation failures when request with GFP_ATOMIC.
echo 1300 > /proc/sys/vm/min_free_kbytes
echo 500 > /proc/sys/vm/vfs_cache_pressure
echo "0" > /proc/sys/vm/oom-kill

#Linux Kernel Network Parameter
source /etc/sysctl.conf

#set onu service type
echo "hgu" > /configs/ont_service_type
echo 1 > /proc/sys/net/ipv4/conf/default/arp_filter
echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter

#Enable Core Dump.
#must behind /configs ready
if [ ! -e /configs/coredump_disabled ]; then
    #(1)The max block size for compressing is set to 5000000 (about 5M) bytes.
    #If core dump file is larger than 5M, it will be compressed block by block,
    #It is to say the max space for caching uncompressed file is 5M bytes.
    #(2)The compressed core files are located at /logs/core directory.
    echo "|/bin/crashcapture /logs %e %p %s 5000000" > /proc/sys/kernel/core_pattern

    #Store max 5000000 (about 5M) bytes core dump files
    echo 5000000 > /configs/coredump_max_filesize
fi

if [ -e /configs/last_reboot_info ]; then
    flag=$(cat /configs/last_reboot_info|cut -d' ' -f1)
    cause=$(cat /configs/last_reboot_info|cut -d' ' -f2)
    if [ $flag == 0 ]; then
       echo "0 99" > /configs/last_reboot_info
    fi
    if [ $flag == 1 ]; then
       echo "0 $cause" > /configs/last_reboot_info
    fi
fi

# dump buildinfo for information
cat /usr/etc/buildinfo

if [ -e /bcm/bin/nand_drv.ko ]; then
        echo "insmod nand_drv ..."
        insmod /bcm/bin/nand_drv.ko
fi

if [ -e /bcm/bin/extfs.ko ]; then
        echo "insmod extfs ..."
        insmod /bcm/bin/extfs.ko
fi

# for system ri module
echo "insmod scfg module ..."
#insmod /bcm/bin/i2c_bcm6xxx.ko
insmod /bcm/bin/scfg.ko
insmod $KER_MOD_DIR/hcfg.ko

# software upgrade init, add by xufuguo, 20120415.
# must use source to execute and behind of RI. it also will identify and set first boot flag.
source /bcm/script/swdl_init.sh

# for gpio manager driver
if [ -e /bcm/bin/gpio_mgr.ko ]; then
	echo "insmod gpio_mgr ..."
	insmod /bcm/bin/gpio_mgr.ko
	mknod /dev/gpio_mgr_drv c 50 1
fi

# for netlinkmsg driver
if [ -e /bcm/bin/netlinkmsg.ko ]; then
	echo "insmod netlinkmsg ..."
	insmod /bcm/bin/netlinkmsg.ko
fi

#super facotry reset start after netlink is ready
if [ -x /usr/exe/superd ]; then
	echo "superd start ... "
	/usr/exe/superd &
fi

# for led_drv driver
if [ -e /bcm/bin/led_drv.ko ]; then
	echo "inmod led_drv ..."
	insmod /bcm/bin/led_drv.ko
fi

# for intmgr and button driver
if [ -e /bcm/bin/int_mgr.ko ]; then
	echo "insmod int_mgr ..."
	insmod /bcm/bin/int_mgr.ko
fi
if [ -e /bcm/bin/button_driver.ko ]; then
	echo "insmod button_driver ..."
	insmod /bcm/bin/button_driver.ko
	mknod /dev/button_driver c 77 0
fi

# load ups driver
if [ -e /bcm/bin/upsdrv.ko ]; then
	echo "insmod upsdrv ..."
	insmod /bcm/bin/upsdrv.ko
fi

# for pwrmngtd driver
if [ -e /bcm/bin/pwrmngtd.ko ]; then
        echo "insmod pwrmngtd.ko ..."
        insmod /bcm/bin/pwrmngtd.ko
fi

# for tr069 service
if [ -f /usr/etc/tr069_conf/tr.conf ]; then
	echo "restore tr069.conf ..."
	cp /usr/etc/tr069_conf/tr.conf /configs/tr069_conf
fi

if [ -f /usr/etc/tr069_conf_analytics/tr.conf ]; then
        cp /usr/etc/tr069_conf_analytics/tr.conf /configs/tr069_conf_analytics
fi

# for tr181 service
if [ -f /usr/etc/tr069_conf/tr181.conf ]; then
echo "restore tr069_conf ..."
cp /usr/etc/tr069_conf/tr181.conf /configs/tr069_conf
fi

if [ -f /usr/etc/tr069_conf_analytics/tr181.conf ]; then
cp /usr/etc/tr069_conf_analytics/tr181.conf /configs/tr069_conf_analytics
fi

## XMPP config file
cp /etc/xmpp.conf /configs/xmpp
chmod 777 /configs/xmpp/xmpp.conf
cp /etc/xmpp_saas.conf /configs/xmpp
chmod 777 /configs/xmpp/xmpp_saas.conf

# for tftpd configuration
if [ -e /etc/vsftpd.conf ]; then
	echo "check vsftpd.conf ..."
	chown root /etc/vsftpd.conf
fi

# startup thttpd
start_thttpd()
{
    if [ -x /webs/thttpd ]; then
        work_role=Controller
        get_work_role=0

        while [ $get_work_role = 0 ]
        do
            sleep 1

            work_role_tmp=`cfgcli -g InternetGatewayDevice.X_ALU-COM_Wifi.WorkRole`
            work_role=`echo $work_role_tmp | cut -d = -f 2`

            if [ "x$work_role" = "xController" -o "x$work_role" = "xAgent" -o "x$work_role" = "xUNSELECTED" ]; then
                get_work_role=1
            fi
        done

        echo "current work role is $work_role"
        if [ "x$work_role" != "xAgent" ]; then
            echo "startup thttpd ..."
            /webs/thttpd -dd /webs
        fi
    fi
}
start_thttpd &

#pls place this cmd at the end. xufuguo, 20120420
#make sure /dev/null belong to group wheel. bob calibration software will use /dev/null via telnet.
chgrp wheel /dev/null

# for igmp proxy configuration
if [ -e /etc/igmpproxy.conf ]; then
	echo "check igmpproxy.conf ..."
	cp /etc/igmpproxy.conf /configs
	chmod 775 /configs/igmpproxy.conf
	echo 1024 > /proc/sys/net/ipv4/igmp_max_memberships
	echo 40960 > /proc/sys/net/core/optmem_max
fi

# for data guardian
if [ -f /bcm/script/data_guardian.sh ]; then
	echo "startup data guardian ..."
	sh /bcm/script/data_guardian.sh &
fi

# for pwrmgr
if [ -f /sbin/pwrmgr ]; then
        echo "startup pwrmgr ..."
        /sbin/pwrmgr &
fi

## XMPP config file
cp /etc/xmpp.conf /configs/xmpp
chmod 777 /configs/xmpp/xmpp.conf
