#!/bin/sh

SLEEP_INTERVAL=30

refresh_leases() {
        touch /tmp/dhcp_monitor
        num_clients=$( cfgcli -g InternetGatewayDevice.LANDevice.1.Hosts.HostNumberOfEntries | cut -d "=" -f 2 )
        if ! [ "$num_clients" == "0" ] ; then
                for i in `seq 1 "$num_clients"` ; do
                        # TODO cfgcli does not set exit code 1 on failure
                        # TODO cfgcli may no garbage collect hosts since we see this response for some hosts
                        # cfg_isNodeEncrypted:1927 get parame attr fail.
                        mac=$( cfgcli -g InternetGatewayDevice.LANDevice.1.Hosts.Host.$i.MACAddress | cut -d "=" -f 2 )
                        ipaddr=$( cfgcli -g InternetGatewayDevice.LANDevice.1.Hosts.Host.$i.IPAddress | cut -d "=" -f 2 )
			if ( echo "$mac" | grep -q "failed" ) ; then
				continue
			fi
                        if [ "$mac" != "" -a "$ipaddr" != "" ] ; then
                                mac=$(echo "$mac" | sed -e "s/:/-/g")
                                curl -is -X PUT -H "Content-Type: application/json" -d "{ \"ip\": \"$ipaddr\" }" http://localhost:8090/1/network/clients/$mac
                        fi
                done
        fi
}

main_loop() {
        while true; do
                refresh_leases
                sleep $SLEEP_INTERVAL
        done
}

if [ -f /tmp/dhcp_monitor ] ; then
        echo "DHCP monitor is already running"
        exit 0
fi

main_loop &
