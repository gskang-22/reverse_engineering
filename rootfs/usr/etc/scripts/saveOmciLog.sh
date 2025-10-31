#!/bin/sh

#check save to log partition or configure partition
df | grep -q '/logs'
if [ $? -eq 0 ]; then
  file_prefix=/logs/omciMsg.
else
  file_prefix=/configs/omciMsg.
fi

#get current file id
if [ -e /configs/omciMsgFileID.txt ]; then
  file_id=`head -1 /configs/omciMsgFileID.txt`
else
  file_id=0
fi

log_file=${file_prefix}${file_id}
echo $log_file

if [ -e /tmp/omcimsg.txt ]; then
  line=`cat /tmp/omcimsg.txt | wc -l`
  echo $line

  if [ $line -ge 20 ]; then
    rm -f $log_file
    tail -20 /tmp/omcimsg.txt > $log_file
  else
    cat /tmp/omcimsg.txt >> $log_file
  fi
fi
sync
echo "saveOmciLog.sh has been finished"

