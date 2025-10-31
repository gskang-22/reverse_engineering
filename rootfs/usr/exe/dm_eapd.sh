#!/bin/sh

killall eapd
rm -rf /tmp/EAPD_IS_RUNNING
/bin/eapd
