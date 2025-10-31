#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 

echo {
echo \"hosts\":
echo {
/sbin/arp -n |
    awk '
        BEGIN{OFS="";FS="[ \t()]+";i=0};
        {
            if($7=="br0"){
                if(i>0)printf ",";
                printf "\"%s\":{\"ip\":\"%s\",\"if\":\"%s\"}",tolower($4),$2,$7;
                i++;
            }
        };'
echo 
echo }
echo ,

echo \"leases\":
echo {
dumpleases -f /tmp/udhcpd.leases 2>/dev/null |
    awk '
        BEGIN{OFS="";}
        {
            if(NR<2)continue;
            if(NR>2){print ","}
            printf "\"%s\":{\"ip\":\"%s\",\"ep\":\"%s\"}",$1,$2,$4;
        }'
echo 
echo }
echo ,

echo \"mw\":
echo [
cat /tmp/test 2>/dev/null |
    awk '
        BEGIN{OFS="";FS=":";i=0;};
        {
            if($1=="IP"){
                if(i>0)printf ",";
                printf "\"%s\"",$2
                i++;
            }
        }'
echo ]

echo }
