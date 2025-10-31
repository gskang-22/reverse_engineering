#!/bin/sh

script_file=/tmp/80211r.sh
map_table_file=/configs/uniumd/map_table.db
old_map_file=/tmp/unium_map_table
nas_daemon=/bin/nas
eapd_daemon=/bin/eapd
rehup_marker=/tmp/rehup_80211r
config_is_running_marker=/tmp/80211r_config_running
BIN_PATH=$( dirname $0 )

eval $(cat /usr/etc/buildinfo)
case "$ONT_TYPE" in
g140wh | g240wg)
	WIFI_5G_ADAPTER="wl1"
	;;
*)
	WIFI_5G_ADAPTER="wl0"
	;;
esac

do_80211r() {
	echo "Setting up 80211R"
	if ! [ -f "$map_table_file" ] ; then
		echo "No map file found, assuming single node operation"
		nodes="AP1"
		AP1_br0=$(ip link show dev br0 | grep ether | awk '{print $2}' | busybox tr '[:lower:]' '[:upper:]')
		AP1_wl0=$(wl -i wl0 status | grep BSSID | awk '{print $2}')
		AP1_wl1=$(wl -i wl1 status | grep BSSID | awk '{print $2}')
		touch $old_map_file
	else
		#if 80211R config is called again, check if anything changed since last time
		#and don't do anything if nothing changed
		#if things have changed, proceed as normal
		if [ -f "$old_map_file" ] ; then
			changed=$(diff  $old_map_file $map_table_file| wc -l)
			if [ "$changed" == "0" ] ; then
				echo "Nothing has changed, ignoring rehup request"
				return 0
			else
				echo "Things changed, re-evaluating 80211r"
			fi
		fi

		eval $(cat $map_table_file)
		cp $map_table_file $old_map_file
	fi

	#check if nas daemon supports 802.11r
	if ! ( grep -q fbt "$nas_daemon" ) ; then
		echo "This system does not have a compatible nas daemon, skipping 802.11r configuration"
		return 0;
	fi

	mdid=10

	. ${BIN_PATH}/80211r_config_helpers.sh

	valid_80211r_vifs=$(find_valid_ssids)
	eval $(generate_80211r_keys "$valid_80211r_vifs")
	my_index=$(find_my_index)

	if [ "$my_index" == "0" ] ; then
		echo "Unable to find my 802.11r entry - aborting"
		return 0
	fi

	#create scriptfile for nvram settings
	echo > $script_file

	generate_local_settings
	generate_nvram_ap_list

cat >> $script_file << EOF
nvram commit
# DON'T RESTART EAPD or NAS to avoid interference with WDS Encryption
# killall eapd
# $eapd_daemon&

# killall nas
# $nas_daemon&
EOF

	/bin/sh "$script_file"
}

enable_80211r=$(wl -i ${WIFI_5G_ADAPTER} fbt)

if ! [ "$enable_80211r" == "1" ] ; then
	echo "80211R is not enabled, skipping startup"
	return 0
fi

if [ -f "$config_is_running_marker" ] ; then
	echo "80211R config already running, skipping running another instance"
	return 0
fi

touch "$config_is_running_marker"

#always rehup 80211r when just starting unium
touch $rehup_marker
rm -f $old_map_file 2>/dev/null

while true; do
	if [ -f "$rehup_marker" ] ; then
		rm "$rehup_marker"
		do_80211r
	fi
	sleep 30
done
