#!/bin/sh
## check the system account
PASSWD="/configs/etc/passwd"
SHADOW="/configs/etc/shadow"
UGROUP="/configs/etc/group"

## check the default system account
home_dir=/etc/home
if [ -e $PASSWD ]; then
  if [ -s $PASSWD ]; then  
    sh /usr/exe/ckpswd.sh
    if ! grep -q "^ONTUSER:" $PASSWD; then
       sed -i '/^ONTUSER:.*$/d' $PASSWD
       sed -i '$a\ONTUSER:x:0:0:Linux:/etc/home/ONTUSER:/bin/sh' $PASSWD
       sed -i '/^ONTUSER:.*$/d' $SHADOW
       sed -i '$a\ONTUSER:$1$ojmCYQtx$ktc5DH0Kvu/jCpuUSAQB0.:0:0:99999:7:::' $SHADOW
       [ -d ${home_dir} ] || mkdir -p ${home_dir}
       if [ ! -d ${home_dir}/ONTUSER ]; then
         mkdir -p ${home_dir}/ONTUSER
         echo "export PS1=\"[\\u@\\h: \\W]\\\\\$ \"" >> ${home_dir}/ONTUSER/.bashrc
         chown ONTUSER ${home_dir}/ONTUSER/.bashrc
       fi
    elif grep "^ONTUSER:" $PASSWD |grep -q -v "/bin/sh"; then
        sed -i 's#^ONTUSER:.*$#ONTUSER:x:0:0:Linux:/etc/home/ONTUSER:/bin/sh#g' $PASSWD
    fi
    
    if ! grep -q "^root:" $PASSWD; then
       ## Add the default account root in the first line, which is used for factory cmd prompt
       sed -i  '1i\root:x:0:0:root:/root:/bin/false' "$PASSWD"
    else
       sed -i 's#^root:.*$#root:x:0:0:root:/root:/bin/false#g' $PASSWD
    fi

    ## add a non-root account for services such as webs
    if ! grep -q "^appService:" $PASSWD; then
       sed -i '/^appService:.*$/d' $PASSWD
       sed -i  '$a\appService:x:1100:1100:Linux User,,,:/home/appService:/bin/false' $PASSWD
       sed -i '/^appService:.*$/d' $SHADOW
       sed -i  '$a\appService:!:2:0:99999:7:::' $SHADOW
       sed -i '/^appService:.*$/d' $UGROUP
       sed -i '$a\appService:x:1100:' $UGROUP
    fi
  else
    ## passwd file is empty, then rm these empty files, which will be restored by etc configuration file mechanism
    ## Therefore, cfgetc.sh must be run after this script to restore the passwd files
    rm -rf $PASSWD $SHADOW $UGROUP
  fi
fi

## trigger system sync
sync

