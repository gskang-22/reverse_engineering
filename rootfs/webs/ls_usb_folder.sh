#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 
cd /mnt/
i=0
echo -n [
for d in *;do
    #echo $d
    if [ `expr $d : usb._.` -gt 0  -a -d $d ];then
        [ $i -gt 0 ] && echo -n ,
        echo -n 
        i=$((++i))
        echo -n {\"name\":\"$d\",\"open\":\"true\",
        #echo -n \"
        cd $d
        #dir_num=`ls -F|grep / -c`
        #echo $dir_num
        if [ `ls -F|grep / -c` -gt 0 ];then
            echo \"children\": [
            j=1           
            for dir in `ls`
            do
                if [ -d $dir ];then
                    #echo $j
                    if [ $j -eq 1 ];then
                        echo   {\"name\":\"$dir\",\"children\": [{\"name\":\"\"}]} 
                    else
                        echo , {\"name\":\"$dir\",\"children\": [{\"name\":\"\"}]}
                    fi
                    j=$((++j))                
                fi  
            done
          echo  ]}
        fi
    fi
done
echo ]
