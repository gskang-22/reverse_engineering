#!/bin/sh
#Author: Alok Yadav

UCI_CONFIG_DIR="/configs/etc/config"
release_migrations="NWF200100,NWF200200,NWF200300,NWF200400,NWF200500"
NEW_VERSION="BBDR2004"

old_version=`uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} get fonendoscope.config.version`
migrate=0
log()
{
	echo $1 >> "/tmp/homeagent_migration.log"
}
[ -z "$old_version" ] && old_version="NWF200200"
if [ "$NEW_VERSION" == "$old_version" ]; then
	exit 0
fi
log "Old config Version: $old_version"
set_version()
{
	uci -c $UCI_CONFIG_DIR set fonendoscope.config=config
	uci -c $UCI_CONFIG_DIR set fonendoscope.config.version=$1
	uci -c $UCI_CONFIG_DIR commit fonendoscope
	log "Updated Version: "$1
}

OIFS=$IFS
IFS=","
for release in $release_migrations ; do
if [ "$old_version" == "$release" ] || [ "$migrate" == 1 ]; then
	migrate=1
else
	continue
fi
case "$release" in
    NWF200100)
	#Migration of NWF200100 to NWF200200
	set_version $release
        ;;
        
    NWF200200)
	#Migration of NWF200200 to NWF200300
	log "Executing migration Rule for version $release"
	#fonendoscope config migration
 	uci -c $UCI_CONFIG_DIR set fonendoscope.bw_ookla=process
	uci -c $UCI_CONFIG_DIR set fonendoscope.bw_ookla.enabled=true
	uci -c $UCI_CONFIG_DIR set fonendoscope.bw_ookla.bin_path=/usr/bin/bw_ookla
	uci -c $UCI_CONFIG_DIR commit fonendoscope

	#plasmodium config migration
	uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='mesh:history'
	uci -c $UCI_CONFIG_DIR commit plasmodium

	#apcloud config migration 
	uci -c $UCI_CONFIG_DIR set apcloud.adaptative_scan.scan_mode_5=1	
	uci -c $UCI_CONFIG_DIR commit apcloud
        ;;
	
    NWF200300)
        #Migration of NWF200300 to NWF200400
        log "Executing migration Rule for version $release"
        #plasmodium config migration
        uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='stats:wan.event'
        #plasmodium config migration for log_agent process
        uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='log'
        uci -c $UCI_CONFIG_DIR commit plasmodium
        #fonendoscope config migration for log_agent process
        uci -c $UCI_CONFIG_DIR set fonendoscope.log_agent=process
        uci -c $UCI_CONFIG_DIR set fonendoscope.log_agent.enabled=true
        uci -c $UCI_CONFIG_DIR set fonendoscope.log_agent.bin_path='/usr/bin/log_agent -c /etc/ssl/certs/s3-eu-west-1-amazonaws-com-chain.pem'
        uci -c $UCI_CONFIG_DIR commit fonendoscope
        #Add wds interface in nemo config
        uci -c $UCI_CONFIG_DIR add_list nemo.devices.device='wl0.4'
        uci -c $UCI_CONFIG_DIR add_list nemo.devices.device='wl1.4'
        uci -c $UCI_CONFIG_DIR commit nemo
        #apcloud config migration
        uci -c $UCI_CONFIG_DIR set apcloud.main.compression_type=gzip
        uci -c $UCI_CONFIG_DIR set apcloud.main.compression_level=medium
        uci -c $UCI_CONFIG_DIR set apcloud.main.dns_addr_resolve=ipv4
        uci -c $UCI_CONFIG_DIR set apcloud.main.connection_age_time=0
        uci -c $UCI_CONFIG_DIR commit apcloud
        ;;

    NWF200400)
        #Migration of NWF200400 to NWF200500
        uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='rpcnwi:nwihistory'
        uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='station_stats:usage'
	uci -c $UCI_CONFIG_DIR add_list plasmodium.services.service='stats:iptv.wan.event'
        uci -c $UCI_CONFIG_DIR commit plasmodium
        #apcloud config migration
        uci -c $UCI_CONFIG_DIR set apcloud.intervals.dns_cache_tout=1800
        uci -c $UCI_CONFIG_DIR commit apcloud
	;;
     
    NWF200500)
	#Migration of NWF200500 to BBDR2004
	#fonendoscope config migration
        uci -c $UCI_CONFIG_DIR set fonendoscope.log_agent.bin_path='/usr/bin/log_agent -c /etc/ssl/certs'
        uci -c $UCI_CONFIG_DIR commit fonendoscope
        ;;
   
    *)
	#Default case in which no need to handle migration
       	log "No migration need to handle"
esac
done
set_version $NEW_VERSION
log "Migration completed from $old_version to $NEW_VERSION"
