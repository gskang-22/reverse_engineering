#!/bin/sh
host=localhost
port=2323
login=admin
pass=aadmin
cmd1="ccd backup"
cmd2="brestore -f $1"
echo "restoring file: $1"

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
  sleep 2
  echo eexit
  sleep 1
  echo tt
  echo -e "\r"  ) | telnet $host $port
