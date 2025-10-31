#!/bin/sh

eval $(cat /usr/etc/buildinfo)
case "$ONT_TYPE" in
g140wh | g240wg)
	WIFI_5G_ADAPTER="wl1"
	;;
*)
	WIFI_5G_ADAPTER="wl0"
	;;
esac

find_valid_ssids() {
	#echo find_valid_ssids >&2
	for vif in wl0 wl1; do
		if $(nvram show | grep "${vif}_akm" | grep -q psk2) ; then
			this_bssid=$(wl -i ${vif}  status | grep BSSID | awk '{print $2}')
			if [ "$this_bssid" != "00:00:00:00:00:00" ] ; then
				echo -n "$vif "
				#echo -n "$vif " >&2
			fi
		fi
	done
	echo
	#echo >&2
}

generate_80211r_keys() {
	#echo generate_80211r_keys >&2
	vifs=$1
	for vif in $vifs ; do
		safe_vif=$(echo $vif | sed -e 's/\./_/')
		password=$(nvram get ${WIFI_5G_ADAPTER}.4_wpa_psk | md5sum | fold -w 16 | xargs | cut -d " " -f 1)
		echo "${safe_vif}_key=$password "
		#echo "${safe_vif}_key=$password " >&2
	done
	echo
	#echo >&2
}

find_my_index() {
	#echo find_my_index >&2
	#echo "$nodes" >&2
	index=1
	my_br0_mac=$(/sbin/ifconfig br0 | grep HWaddr |  awk '{print $5}')
	for i in $nodes; do
		string=${i}_br0
		eval br0_mac=\$${string}
		if [ "$br0_mac" == "$my_br0_mac" ] ; then
			echo $index
			#echo $index >&2
			return 0;
		fi
		index=$(($index+1))
	done
	echo 0
	#echo 0 >&2
}

generate_nvram_ap_list() {
	#echo generate_nvram_ap_list >&2
	for vif in $valid_80211r_vifs ; do
		phy_index=$(echo $vif | sed -e 's/wl//' | cut -d"." -f 1)
		vif_index=$(echo $vif | sed -e "s/wl$phy_index//" -e "s/\.//")
		if [ "$vif_index" == "" ] ; then
			vif_index=0
		fi
		safe_vif=$(echo $vif | sed -e 's/\./_/')
		for i in $nodes; do
			ap_name=${i}P${phy_index}V${vif_index}
			string=${i}_${safe_vif} ; eval bssid=\$${string}
			# if there's no information about this this iface in map file, ignore it
			if [ "$bssid" == "" ] ; then
				continue
			fi
			string=${i}_br0 ; eval br0_mac=\$${string}
			string=${safe_vif}_key ; eval key=\$${string}
			r0kh_id=$(echo "$bssid" | sed -e 's/://g' | busybox tr '[:upper:]' '[:lower:]')
cat >> $script_file << EOF

# $ap_name details
nvram set ${ap_name}_addr="$bssid"
nvram set ${ap_name}_r1kh_id="$bssid"
nvram set ${ap_name}_r1kh_key="$key"
nvram set ${ap_name}_r0kh_id=$r0kh_id
nvram set ${ap_name}_r0kh_id_len=12
nvram set ${ap_name}_r0kh_key="$key"
nvram set ${ap_name}_br_addr="$br0_mac"
EOF
		done
	done
}

generate_safe_vif_from_phy_vif() {
	#echo generate_safe_vif_from_phy_vif >&2
	phy=$1
	vif=$2
	if [ "$vif" == "0" ] ; then
		echo wl${phy}
		#echo wl${phy} >&2
	else
		echo wl${phy}_${vif}
		#echo wl${phy}_${vif} >&2
	fi
}

generate_fbt_ap_list() {
	#echo generate_fbt_ap_list >&2
	phy_index=$1
	vif_index=$2

	my_ap="AP${my_index}"
	for i in $nodes; do
		for phy in 0 1 ; do
			#skip own AP entry when adding fbt neighbors
			if [ "$i" == "$my_ap" -a "$phy" == "$phy_index" ] ; then
				continue
			fi

			#skip adding neighbor if we didn not get its info via map file
			safe_vif=$(generate_safe_vif_from_phy_vif $phy $vif_index)
			string=${i}_${safe_vif} ; eval bssid=\$${string}
			if [ "$bssid" == "" ] ; then
				continue
			fi

			echo -n "${i}P${phy}V${vif_index} "
			#echo -n "${i}P${phy}V${vif_index} " >&2
		done
	done
	echo
}

generate_local_settings() {
	#echo generate_local_settings >&2
	for vif in $valid_80211r_vifs ; do
		phy_index=$(echo $vif | sed -e 's/wl//' | cut -d"." -f 1)
		vif_index=$(echo $vif | sed -e "s/wl$phy_index//" -e "s/\.//")
		if [ "$vif_index" == "" ] ; then
			vif_index=0
		fi

		#exclude own AP from fbt_aps list
		fbt_aps=$(generate_fbt_ap_list $phy_index $vif_index | sed -e 's/ $//')

#create scriptfile for nvram settings
cat >> $script_file << EOF
nvram set ${vif}_fbt_aps="$fbt_aps"
nvram set ${vif}_fbt_generate_local=1
EOF
	done
}



