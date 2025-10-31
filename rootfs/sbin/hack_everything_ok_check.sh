#!/bin/sh

LOGFILE=/tmp/apcloud_log.txt
TIMESTAMP_FILE=/tmp/timestamp_apcloud
WAIT_TIME=240
touch $LOGFILE

timestamp=$(stat -c %y $LOGFILE)
echo $timestamp > $TIMESTAMP_FILE

while true
do

    sleep $WAIT_TIME
    timestamp_old=$(cat $TIMESTAMP_FILE)
    timestamp_new=$(stat -c %y $LOGFILE)
    if [ "$timestamp_old" = "$timestamp_new" ]; then
        logger -t checker -s "apcloud frozen killing it"
        killall -9 apcloud
    fi

    echo $timestamp_new > $TIMESTAMP_FILE

done
