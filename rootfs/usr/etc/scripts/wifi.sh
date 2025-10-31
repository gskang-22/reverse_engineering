//For 2.4G wifi
wl counters
wl dump
wl status
wl pwr_percent
wl phy_rssi_ant
wlctl -i wl0 assoclist 
wl sta_info 00:01:02:03:04:05 
wl rate

//For 5G wifi
qcsapi_sockrpc get_status wifi0
qcsapi_sockrpc get_ssid wifi0
qcsapi_sockrpc get_channel wifi0
qcsapi_sockrpc get_bw wifi0
qcsapi_sockrpc get_count_assoc wifi0
qcsapi_sockrpc get_link_quality  wifi0 0
qcsapi_sockrpc get_associated_device_ip_addr wifi0 0
qcsapi_sockrpc get_associated_device_mac_addr wifi0 0
qcsapi_sockrpc get_rssi_dbm  wifi0 0

