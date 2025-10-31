#!/bin/sh

echo "Loading drivers and kernel modules... "
echo

test -e /bcm/bin/bcm_log.ko && insmod /bcm/bin/bcm_log.ko
# RDPA
test -e /bcm/bin/bdmf.ko && insmod /bcm/bin/bdmf.ko bdmf_chrdev_major=215
test -e /bcm/bin/gpon_stack.ko && insmod /bcm/bin/gpon_stack.ko
test -e /bcm/bin/rdpa_gpl.ko && insmod /bcm/bin/rdpa_gpl.ko
#add some delay to avoid hanging here. To be removed later.
#echo "sleep 10 seconds before init RDPA"
#sleep 10
test -e /bcm/bin/rdpa.ko && insmod /bcm/bin/rdpa.ko
# We need to down eth0 prior to starting runner's data path init
ifconfig eth0 down &> /dev/null
# Initialize bdmf shell
bdmf_shell -c init | while read a b; do echo $b; done > /tmp/bdmf_sh_id
alias bs="bdmf_shell -c `cat /tmp/bdmf_sh_id` -cmd "
test -e /bcm/bin/rdpa_mw.ko && insmod /bcm/bin/rdpa_mw.ko
test -e /bcm/bin/bcmbrfp.ko && insmod /bcm/bin/bcmbrfp.ko

# General
test -e /bcm/bin/chipinfo.ko && insmod /bcm/bin/chipinfo.ko
test -e /bcm/bin/bcmxtmrtdrv.ko && insmod /bcm/bin/bcmxtmrtdrv.ko
test -e /bcm/bin/bcm_ingqos.ko && insmod /bcm/bin/bcm_ingqos.ko
test -e /bcm/bin/bcm_bpm.ko && insmod /bcm/bin/bcm_bpm.ko
test -e /bcm/bin/pktflow.ko && insmod /bcm/bin/pktflow.ko
test -e /bcm/bin/pktcmf.ko && insmod /bcm/bin/pktcmf.ko
test -e /bcm/bin/bcmfap.ko && insmod /bcm/bin/bcmfap.ko
test -e /bcm/bin/pktrunner.ko && insmod /bcm/bin/pktrunner.ko
test -e /bcm/bin/flowbond.ko && insmod /bcm/bin/flowbond.ko
test -e /etc/cmf/cmfcfg && /etc/cmf/cmfcfg
test -e /bcm/bin/profdrvdd.ko && insmod /bcm/bin/profdrvdd.ko
test -e /bcm/bin/bcmxtmcfg.ko && insmod /bcm/bin/bcmxtmcfg.ko
test -e /bcm/bin/ext_bonding.ko && insmod /bcm/bin/ext_bonding.ko
test -e /bcm/bin/atmapi.ko && insmod /bcm/bin/atmapi.ko
test -e /bcm/bin/adsldd.ko && insmod /bcm/bin/adsldd.ko
test -e /bcm/bin/blaa_dd.ko && insmod /bcm/bin/blaa_dd.ko
test -e /bcm/bin/bcmprocfs.ko && insmod /bcm/bin/bcmprocfs.ko

#test -e /lib/modules/$KERNELVER/kernel/net/ipv6/ipv6.ko && insmod /lib/modules/$KERNELVER/kernel/net/ipv6/ipv6.ko
#test -e /lib/modules/$KERNELVER/kernel/net/atm/br2684.ko && insmod /lib/modules/$KERNELVER/kernel/net/atm/br2684.ko

test -e /bcm/bin/linux-kernel-bde.ko && insmod /bcm/bin/linux-kernel-bde.ko
test -e /bcm/bin/linux-user-bde.ko && insmod /bcm/bin/linux-user-bde.ko
# enet depends on moca depends on i2c
test -e /bcm/bin/i2c_bcm6xxx.ko && insmod /bcm/bin/i2c_bcm6xxx.ko
test -e /bcm/bin/bcm3450.ko && insmod /bcm/bin/bcm3450.ko
test -e /bcm/bin/gpon_i2c.ko && insmod /bcm/bin/gpon_i2c.ko
test -e /bcm/bin/gpon_i2c.ko && echo gpon_i2c 0x50 > /sys/bus/i2c/devices/i2c-0/new_device
test -e /bcm/bin/gpon_i2c.ko && echo gpon_i2c 0x51 > /sys/bus/i2c/devices/i2c-0/new_device

test -e /bcm/bin/laser_i2c.ko && insmod /bcm/bin/laser_i2c.ko
test -e /bcm/bin/sfp_i2c.ko && insmod /bcm/bin/sfp_i2c.ko
test -e /bcm/bin/bcmmoca.ko && insmod /bcm/bin/bcmmoca.ko
test -e /bcm/bin/bcm_enet.ko && insmod /bcm/bin/bcm_enet.ko
test -e /bcm/bin/time_sync.ko && insmod /bcm/bin/time_sync.ko
test -e /bcm/bin/bcmsw.ko && insmod /bcm/bin/bcmsw.ko && ifconfig bcmsw up
test -e /bcm/bin/bcm_usb.ko && insmod /bcm/bin/bcm_usb.ko
test -e /bcm/bin/bcmarl.ko && insmod /bcm/bin/bcmarl.ko

#load SATA/AHCI modules
 test -e $KER_MOD_DIR/libata.ko && insmod $KER_MOD_DIR/libata.ko
 test -e $KER_MOD_DIR/libahci.ko && insmod $KER_MOD_DIR/libahci.ko
 test -e $KER_MOD_DIR/ahci.ko && insmod $KER_MOD_DIR/ahci.ko
 test -e $KER_MOD_DIR/bcm63xx_sata.ko && insmod $KER_MOD_DIR/bcm63xx_sata.ko
 test -e $KER_MOD_DIR/ahci_platform.ko && insmod $KER_MOD_DIR/ahci_platform.ko

#load usb modules
 for f in usb-common usbcore \
  ehci-hcd ohci-hcd xhci-hcd \
  bcm63xx_usb \
  usblp; do
  test -e $KER_MOD_DIR/$f.ko && insmod $KER_MOD_DIR/$f.ko
 done

# pcie configuration save/restore
test -e /bcm/bin//bcm63xx_pcie.ko && insmod /bcm/bin/bcm63xx_pcie.ko

#Load Bcmdrvhoook Module
echo "insmod bcmhook..."
test -e /bcm/bin/bcmhook.ko && insmod /bcm/bin/bcmhook.ko

#WLAN Module
[ -e /bcm/script/init_wlan.sh ] && /bcm/script/init_wlan.sh

test -e /bcm/bin/dect.ko && insmod /bcm/bin/dect.ko
test -e /bcm/bin/dectshim.ko && insmod /bcm/bin/dectshim.ko
test -e /bcm/bin/dspdd.ko && insmod /bcm/bin/dspdd.ko
test -e /bcm/bin/pcmshim.ko && insmod /bcm/bin/pcmshim.ko
test -e /bcm/bin/endpointdd.ko && insmod /bcm/bin/endpointdd.ko
test -e /bcm/bin/p8021ag.ko && insmod /bcm/bin/p8021ag.ko

# other modules
test -e /bcm/bin/isdn.ko && insmod /bcm/bin/isdn.ko
test -e /bcm/bin/capi.ko && insmod /bcm/bin/capi.ko
test -e /bcm/bin/bcmgpon.ko && insmod /bcm/bin/bcmgpon.ko
test -e /bcm/bin/bcmvlan.ko && insmod /bcm/bin/bcmvlan.ko
test -e /bcm/bin/pwrmngtd.ko && insmod /bcm/bin/pwrmngtd.ko
test -e /bcm/bin/rng-core.ko && insmod /bcm/bin/rng-core.ko
test -e /bcm/bin/bcmtrng.ko && insmod /bcm/bin/bcmtrng.ko

test -e /bcm/bin/laser_dev.ko && insmod /bcm/bin/laser_dev.ko
test -e /bcm/bin/pmd.ko && insmod /bcm/bin/pmd.ko
test -e /bcm/bin/sim_card.ko && insmod /bcm/bin/sim_card.ko

# presecure fullsecure modules
test -e /bcm/bin/otp.ko && insmod /bcm/bin/otp.ko

# EPON Module
#test -e /bcm/bin/epon_stack.ko && insmod /bcm/bin/epon_stack.ko epon_usr_init=1

# RDPA Command Drivers
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_tm.ko && insmod /bcm/bin/rdpa_cmd_tm.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_iptv.ko && insmod /bcm/bin/rdpa_cmd_iptv.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_ic.ko && insmod /bcm/bin/rdpa_cmd_ic.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_sys.ko && insmod /bcm/bin/rdpa_cmd_sys.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_br.ko && insmod /bcm/bin/rdpa_cmd_br.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_port.ko && insmod /bcm/bin/rdpa_cmd_port.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_llid.ko && insmod /bcm/bin/rdpa_cmd_llid.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_spdsvc.ko && insmod /bcm/bin/rdpa_cmd_spdsvc.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_ds_wan_udp_filter.ko && insmod /bcm/bin/rdpa_cmd_ds_wan_udp_filter.ko
test -e /bcm/bin/rdpa.ko && test -e /bcm/bin/rdpa_cmd_drv.ko && insmod /bcm/bin/rdpa_cmd_drv.ko

