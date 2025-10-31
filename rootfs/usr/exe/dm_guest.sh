#! /bin/sh
OUTPUT=$(ps w | grep guestdev | grep -v grep | cut -d 'r' -f 1);
if [ ! $OUTPUT ]
then
killall guestdev
/usr/exe/guestdev &
fi
