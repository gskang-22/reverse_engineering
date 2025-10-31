#!/bin/sh
stat_fpath=/tmp/dl_stat
pstr=`ps w |grep "curl -s"|grep -v grep`

[ "$pstr" != "" ] && downloading=1 || downloading=0
if [ $downloading -eq 1 ];then
    echo { \"ret\":-2 }
else
    if [ $# -eq 4 ];then
        echo "" >$stat_fpath
        ./curl.sh $1 $2 $3 $4 | tee  ${stat_fpath}
    else
        if [ $# -eq 2 ];then
            #echo $1 $2 
            echo "" >$stat_fpath
            ./curl.sh anonymous anonymous $1 $2 | tee  ${stat_fpath}
        else
            cat ${stat_fpath}
        fi
    fi
fi
