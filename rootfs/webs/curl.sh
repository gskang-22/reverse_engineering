#!/bin/sh
u=$1
p=$2
url=$3
usb_dir=/mnt/$4
dl_fname="${url##*/}"
echo { 

if [ ! -d $usb_dir ];then
    echo \"ret\":-1 
    echo }
    exit 1;
fi
dl_dir=$usb_dir/
if [ ! -d $dl_dir ];then
    mkdir -p $dl_dir
fi
dec_str="`echo "$dl_fname" | sed 's/+/ /g;s/%\(..\)/\\\x\1/g;'`"
dec_fname="`echo -n -e "${dec_str}"`"

cd $dl_dir
/sbin/curl -s -u $u:$p -m 172800 --connect-timeout 3 --url "$url" \
    -w "\"speed_download\":\"%{speed_download}\",\"time_total\":\"%{time_total}\",\"size_download\":\"%{size_download}\"," \
    -o "$dl_fname"
dl_ret=$?
echo \"ret\":${dl_ret} 
echo } 

if [ ${dl_ret} -eq 0 ];then
    mv "${dl_fname}" "${dec_fname}"
fi
/bin/sync >/dev/null 2>&1
