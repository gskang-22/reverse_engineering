#!/bin/sh

#Note: do this after /logs mounted.
if [ -f /tmp/configs_key_data ]; then
  # restore key data backup at /logs
  cp -rf /logs/configs_key_data_bak/* /configs
  sync
fi

cp /usr/etc /configs -R
rm -f /etc/localtime
mkdir -p /var/run
mkdir -p /var/log

# create links to /configs
if [ -x /bcm/script/cfglnk.sh ]; then
	/bcm/script/cfglnk.sh
fi

#mkdir bosa for saving bosa cfg data, add by xufugo, 20120420
if [ ! -d /configs/bosa ]; then
	mkdir -p /configs/bosa
	chmod g+w /configs/bosa
	chgrp wheel /configs/bosa
fi

#mkdir tr069_conf for saving tr069 cfg data, add by xufugo, 20121009
if [ ! -d /configs/tr069_conf ]; then
	mkdir -p /configs/tr069_conf
	chmod g+w /configs/tr069_conf
	chgrp wheel /configs/tr069_conf
fi

#mkdir tr069_conf_analytics for saving analytics tr069 cfg data
if [ ! -d /configs/tr069_conf_analytics ]; then
        mkdir -p /configs/tr069_conf_analytics
        chmod g+w /configs/tr069_conf_analytics
        chgrp wheel /configs/tr069_conf_analytics
fi

#mkdir xmpp for saving xmpp cfg data
if [ ! -d /configs/xmpp ]; then
        mkdir -p /configs/xmpp
        chmod g+w /configs/xmpp
        chgrp wheel /configs/xmpp
fi

#mkdir log for saving omci trace cfg data, June 2014
[ -d /configs/log ] || mkdir -p /configs/log


#for p2p project
mkdir -p /configs/p2p
chmod g+w /configs/p2p
chgrp wheel /configs/p2p
touch /configs/p2p/done
chmod g+w  /configs/p2p/done

