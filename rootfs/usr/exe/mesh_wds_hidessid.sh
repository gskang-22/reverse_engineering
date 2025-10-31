#!/bin/sh

num=$1
band=$2
ssidindex=$3
ssidname=$4
password=$5
bcmintf=$band.$ssidindex
#mnemonic=`ritool dump|grep "Mnemonic"|awk '{sub(/Mnemonic:/, "",$2);print $2}'`
wifichip=`hcfgtool get WIFI.0.SOLUTION`

	if [ "$num" == "0" ]; then
		echo "creat hide ssid"
		wl -i $band up
		wl -i $band bss  -C $ssidindex  up
		wl -i $bcmintf ssid  $ssidname
		wl -i $bcmintf closed 1
		radio=`wl -i $band status  | sed -n '6p' | awk '{print $2}'`
		if [ $radio == "5GHz" ]; then
			wl -i $bcmintf pspretend_retry_limit  5
			wl -i $bcmintf pspretend_overtime  100
		fi
		if [ $radio == "2.4GHz" ] && [ "$wifichip" == "BCM4363" ]; then
			wl  -i $band  wme_ac ap  be aifsn 1 ecwmin 2 ecwmax 3 txop  0x2f
		fi
		nvram set  $bcmintf"_ssid"=$ssidname
		nvram set $bcmintf"_rxchain_pwrsave_enable"=0
		nvram set $bcmintf"_wps_config_state"=1
		nvram set $bcmintf"_wpa_gtk_rekey"=0
		nvram set $bcmintf"_macmode"="disabled"
		nvram set $bcmintf"_proxy_arp"=1
		nvram set $bcmintf"_maclist"=""
		nvram set $bcmintf"_preauth"=0
		nvram set $bcmintf"_wmf_bss_enable"=0
		nvram set $bcmintf"_wps_mode"="disabled"
		nvram set $bcmintf"_auth_mode"="none"
		nvram set $bcmintf"_bss_maxassoc"=16
		nvram set $bcmintf"_wme_bss_disable"=0
		nvram set $bcmintf"_radius_ipaddr"=0.0.0.0
		nvram set $bcmintf"_mode"="ap"
		nvram set $bcmintf"_rxchain_pwrsave_pps"=10
		nvram set $bcmintf"_crypto"="aes"
		nvram set $bcmintf"_ipv6addr"=0
		nvram set $bcmintf"_interface"="wl0"
		nvram set $bcmintf"_ipv4addr"=3
		nvram set $bcmintf"_wpa_psk"="$password"
		nvram set $bcmintf"_mfp"=-1
		nvram set $bcmintf"_key1"=1234567890123
		nvram set $bcmintf"_key2"=1234567890123
		nvram set $bcmintf"_akm"="psk2"
		nvram set $bcmintf"_key3"=1234567890123
		nvram set $bcmintf"_key4"=1234567890123
		nvram set $bcmintf"_rxchain_pwrsave_quiet_time"=10
		nvram set $bcmintf"_closed"=1
		nvram set $bcmintf"_bss_enabled"=1
		nvram set $bcmintf"_wep"="disabled"
		nvram set $bcmintf"_radius_port"=1812
		nvram set $bcmintf"_radio"=1
		nvram set $bcmintf"_ap_isolate"=0
		nvram set $bcmintf"_auth"=0
		wl -i $band down
		touch /tmp/hidessid_create
	fi
	
	wl -i $band bss -C $ssidindex down

	if [ "$num" == "1" ]; then
		echo "config hide ssid"
		prebcminft=`expr $ssidindex - 1`
		if [ $prebcminft = "0" ];then
			base_MAC=`ifconfig $band |grep HWaddr | awk -F ' ' '{print $5}'`
		else
			base_MAC=`ifconfig $band.$prebcminft |grep HWaddr | awk -F ' ' '{print $5}'`
		fi
		macAddress=":"${base_MAC}

		mac1=`echo $macAddress | cut -d ':' -f 2`
		mac2=`echo $macAddress | cut -d ':' -f 3`
		mac3=`echo $macAddress | cut -d ':' -f 4`
		mac4=`echo $macAddress | cut -d ':' -f 5`
		mac5=`echo $macAddress | cut -d ':' -f 6`
		mac6=`echo $macAddress | cut -d ':' -f 7`

		mac6="0x"$mac6
		mac_val=$((($mac6>>2)&(1)))
		if [ "$mac_val" == "0" ]; then
			mac6=$(($mac6|4))
		fi
		if [ "$mac_val" == "1" ]; then
			mac6=$(($mac6&(~4)))
		fi
		mac6=`printf "%02X\n" $mac6` 
		Hidessid_MAC=$mac1:$mac2:$mac3:$mac4:$mac5:$mac6
		echo $Hidessid_MAC
		wl -i $band down
		ifconfig $bcmintf down 2>/dev/null
		ifconfig $bcmintf hw ether $Hidessid_MAC 2>/dev/null
		ifconfig $bcmintf.v0 hw ether $Hidessid_MAC 2>/dev/null
		wl -i $bcmintf  cur_etheraddr $Hidessid_MAC

		#wl -i $band ssid -C $ssidindex $ssidname
		wl -i $band auth -C $ssidindex 0
		wl -i $band wpa_auth -C $ssidindex 0x80
		wl -i $band wsec -C $ssidindex 0x4
		wl -i $band wsec_restrict -C $ssidindex 1
		wl -i $bcmintf closed 1
		wl -i $bcmintf eap 1
		wl -i $band up
		nvram set $bcmintf"_auth"=0
		nvram set $bcmintf"_auth_mode"="none"
		nvram set $bcmintf"_crypto"="aes"
		nvram set $bcmintf"_akm"="psk2"
		nvram set $bcmintf"_wep"="disabled"
		#nvram set $bcmintf"_wpa_psk"="$password"
		nvram set $bcmintf"_hwaddr"=$Hidessid_MAC

		dhd -i $bcmintf wmf_bss_enable 1
		nvram set $bcmintf"_bss_enabled"=1
		wl -i $band bss -C $ssidindex up
		ifconfig $bcmintf up
		wl -i $bcmintf wdstimeout 10
		ebtables -D OUTPUT -o wl0.4.v0 -j DROP
		ebtables -D OUTPUT -o wl1.4.v0 -j DROP
		ebtables -D FORWARD -o wl0.4.v0 -j DROP
		ebtables -D FORWARD -o wl1.4.v0 -j DROP

		ebtables -D OUTPUT -p 0xc0c0 -o wl+ -j DROP 
		ebtables -D FORWARD -p 0xc0c0 -o wl+ -j DROP

		ebtables -A OUTPUT -o wl0.4.v0 -j DROP
		ebtables -A OUTPUT -o wl1.4.v0 -j DROP
		ebtables -A FORWARD -o wl0.4.v0 -j DROP
		ebtables -A FORWARD -o wl1.4.v0 -j DROP

		ebtables -A OUTPUT -p 0xc0c0 -o wl+ -j DROP
		ebtables -A FORWARD -p 0xc0c0 -o wl+ -j DROP
	fi
