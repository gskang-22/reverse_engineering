#!/bin/bash

#restore user account when downgrade and upgrade
PASSWD="/configs/etc/passwd"

if [ -e $PASSWD ]; then
	while read LINE
	do
		temp=$(echo $LINE | awk -F : '{print $1}')
		if [ "${temp}" == "ONTUSER" -o "${temp}" == "root" -o "${temp}" == "appService" ]; then
			continue
		else
			deluser ${temp}
		fi
	done < $PASSWD
fi

