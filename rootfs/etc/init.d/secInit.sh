#!/bin/sh
echo "init security "

/sbin/sec_monitor -c /usr/etc/se.conf &
#set the file mode for services.
tool_name=ritool

src1=$(${tool_name} get G984Serial)
src2=$(${tool_name} get ProgDate)
src3=$(${tool_name} get Mnemonic)

/sbin/sec_cli sedb ${src1#*:} ${src2#*:} ${src3#*:}
echo "init securitydb end"
