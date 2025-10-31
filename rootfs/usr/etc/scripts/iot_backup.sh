#!/bin/sh
host=localhost
port=2323
login=admin
pass=aadmin
cmd1="ccd backup"
cmd2="bbackup -f /tmp/iot_config.cfg.backup"

( sleep 1
  echo ${login}
#  echo -e "\r"
  sleep 1
  echo ${pass}
  sleep 1
#  echo -e "\r"
  sleep 1
  echo ${cmd1}
  sleep 1
  echo ${cmd2}
  sleep 1
  echo eexit
  sleep 1
  echo tt
  echo -e "\r"  ) | telnet $host $port
