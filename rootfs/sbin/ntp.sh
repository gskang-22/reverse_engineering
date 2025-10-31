#! /bin/sh
sleep 2
echo "GMT${2}" | /usr/bin/tr  "\-\+" "\+\-" > /etc/TZ
/sbin/ntpclient -e "$3" -T "$4" -i "$5" -tsl -h "$1" &
