#! /bin/sh

fpath=/tmp/$1
if [ -p $fpath ];then
    echo -n ">"
    cat $fpath
else
    echo -n "<"
fi


