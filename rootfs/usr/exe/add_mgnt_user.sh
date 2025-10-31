#!/bin/bash

#add MgntUser according to RI info, xufuguo, 20120808
#if user_name or password is NULL, do nothing.
#update for R30 read-only rootfs, modify by xufuguo, 20130816

#modify: not get MgntUserLongPasswd from RI. so call this script in pre-config instead of startup.sh xufuguo, 20120926

#user_name=$(ritool get UserName | grep UserName | awk -F : '{print $2}')
#password=$(ritool get MgntUserLongPasswd | grep MgntUserLongPasswd | awk -F : '{print $2}')

user_name=$1
password=$2

if [ "$user_name" = "ONTUSER" ]; then
	home_dir=/etc/home
else
	home_dir=/configs/home
fi

#remove char " " at the head and end.
user_name=$(echo $user_name)
password=$(echo $password)

if [ "$user_name" != "" -a "$password" != "" ]; then
	exist=no
	while read LINE
	do
		temp=$(echo $LINE | awk -F : '{print $1}')
		if [ "${temp}" != "$user_name" ]; then
			continue
		fi
		exist=yes
		break
	done < /etc/passwd

	#always try to add the account to fix the only password is changed
	if [ "${exist}" = "yes" ]; then
		deluser "$user_name"
		exist=no
	fi

	OPID=$(ritool get OperatorID|cut -d: -f2|sed "s/[ \r\n]//g")

	if [ "${exist}" = "no" ]; then
		rm -f /configs/etc/*+ #clean up temp files
		[ -d ${home_dir} ] || mkdir -p ${home_dir}
        
		if [ -e /usr/sbin/vtysh -a "$user_name" != "ONTUSER" -a "$OPID" != "0000" -a "OPID" != "9999" ]; then
			adduser -D -h ${home_dir}/${user_name} -G wheel ${user_name} -s /usr/sbin/vtysh
		else
			adduser -D -h ${home_dir}/${user_name} -G wheel ${user_name}
		fi
        
		echo "${user_name}:${password}" | chpasswd -m > /dev/null 2>&1
		echo "export PS1=\"[\\u@\\h: \\W]\\\\\$ \"" >> ${home_dir}/${user_name}/.bashrc
		chown ${user_name} ${home_dir}/${user_name}/.bashrc

		#chang uid to 0 for get root authorization
		source /usr/exe/rootmod.sh ${user_name}

		sync
	fi
	
	## no ONTUSER account for SIGH
    	if [ "${OPID}" = "SIGH" ]; then
       		deluser ONTUSER
       		rm -rf ${home_dir}/ONTUSER
       		rm -rf /home/ONTUSER
    	fi
else
	echo "param error, user_name=$1, passwd=$2"
fi

