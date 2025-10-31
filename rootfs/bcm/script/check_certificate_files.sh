#!/bin/sh

#check the certificates in /configs or /logs whether they are damaged, if damaged, will copy the backup files.

check_certificate()
{
	CER_LIST="certificate:1 certificatehost:2 rsakey:3"
	PART_ITEM=$1

	if [ "$PART_ITEM" == "logs" ]; then
		CER_DIR="/logs/configs_key_data_bak/X509"
	else
		CER_DIR="/configs/X509"
	fi

	cd "$CER_DIR"

	if [ -f "certificate" ] && [ -f 1* ] && [ -f "certificatehost" ] && [ -f 2* ] && [ -f "rsakey" ] && [ -f 3* ]; then
		for CER_ITEM in $CER_LIST
		do
			CER_FILE=$(echo "$CER_ITEM" | cut -d":" -f1)
			CER_INDEX=$(echo "$CER_ITEM" | cut -d":" -f2)
			CER_MD5_CURRENT=$(md5sum "$CER_FILE" | cut -d" " -f1)
			CER_MD5_ACTUAL=$(ls "$CER_INDEX"* | cut -d"_" -f2)
			if [ "$CER_MD5_CURRENT" != "$CER_MD5_ACTUAL" ]; then
				echo "$CER_FILE in /"$PART_ITEM" md5sum is different!"
				return 1;
			fi
		done
	else
		return 1;
	fi

	return 0;
}

check_certificate configs;

if [ $? != 0 ]; then
        check_certificate logs;
        if [ $? != 0 ]; then
                echo "certificate files are damaged in both /configs and /logs, cannot fix!"
        else
                echo "certificate files are damaged in /configs, will copy the backup files from /logs to /configs..."
                cp -rf /logs/configs_key_data_bak/X509/* /configs/X509/
                sync
        fi
fi

