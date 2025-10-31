#! /bin/sh

echo {
echo -n \"exist\":
[ -d /proc/${1}/ ]&&echo 1||echo 0
#grepid="ps |grep '^[[:blank:]]*${1}'|awk '{print \$1}'"
#[ "`eval ${grepid}`" = "${1}" ] && echo 1 || echo 0
echo }
