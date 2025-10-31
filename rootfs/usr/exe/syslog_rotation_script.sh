#!/bin/sh
MAXFILES="5"
MESSAGES_FILE="/logs/messages"
BEACON_LOG="/logs/beacon_syslog"
if [ $MESSAGES_FILE = $1 -o $BEACON_LOG = $1 ];
  then
  if [[ -e "$1.1" && -e "$1.0" ]]
     then
       for i in `seq $MAXFILES -1 2` ; do
          if [ -e "$1.$i.tar.bz2" ]
            then
               f=$i; let f++
               mv -f $1.$i.tar.bz2 $1.$f.tar.bz2 
	      fi
       done
    if [ -e "$1.2.tar.bz2" ]
      then
         mv -f $1.2.tar.bz2 $1.3.tar.bz2
    fi
   #mv -f $1.1 $1.tar
   tar cjvf $1.2.tar.bz2 $1.1
   #rm -rf $1.tar
  fi
fi
mv -f $1.0 $1.1
mv -f $1 $1.0

