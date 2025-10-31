#!/bin/sh
username=$1
#echo usrname=$username
UID=`grep $username /etc/passwd | awk -F: '{print $3}'`
GID=`grep $username /etc/passwd | awk -F: '{print $4}'`
#echo "UID=$UID"
sed -i "s/$username:x:$UID:$GID/$username:x:0:0/" /configs/etc/passwd
sync
