#!/bin/sh

# To speed up booting up, move some apps to here, before driver insmode.

echo "[startup] messagebus"
/bin/messagebus start &

echo "[startup] msgmgr"
/sbin/msgmgr &

echo "[startup] cfgmgr"
/sbin/cfgmgr &

