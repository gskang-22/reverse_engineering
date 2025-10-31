#!/bin/sh

killall eapd
/bin/eapd &

killall acsd
/bin/acsd &

killall nas
/bin/nas &


