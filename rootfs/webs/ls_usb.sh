#! /bin/sh
echo "Content-type:text/html;charset=UTF-8"
echo "Cache-Control:private,max-age=0;"
echo 

cd /tmp
if [  -e   usbinfo ];then
awk '
BEGIN{printf "[",lnr=0};
END{printf "]"};
{
    if(NF==4)
    {
        if(lnr>0){printf ","}
        if ($3 == "RAW")
        {
            total = "-"
            free  = "-"
        }
        else
        {
            total = "df  -h " $4 "| grep -v Size"
            free  = "df  -h " $4 "| grep -v Size"
            total | getline total

            split(total,a," ");
            total = a[2]"B";
            free  = a[4]"B";
        }

        printf "[\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"]",$1,substr($2,6),$3,total,free,$4
        lnr++;
    }
}
' /tmp/usbinfo
else
exit 0
fi
