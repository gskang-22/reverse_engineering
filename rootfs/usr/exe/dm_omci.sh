#! /bin/sh

cat /usr/etc/buildinfo >> /tmp/omci.log
cp -f /tmp/omci.log* /logs
cp /logs/messages /logs/messages.bak
/etc/scripts/saveOmciLog.sh&
