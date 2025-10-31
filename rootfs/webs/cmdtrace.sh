#! /bin/sh
FILE="/tmp/cancelfile.txt"
                if [ -f $FILE ];
                then
                        rm $FILE
                fi
if [ $# -eq 6 ] || [ $# -eq 7 ];then

	if [ "$1" = "ping" ];then
	    ping  $2 "-s" $4 "-c" $5 "-I" $3 
	    exit 0
	elif [ "$1" = "trace" ];then
	    traceroute $2 "-n" "-w" "3" "-s" $5 "-m" $6 $4
	    exit 0
	elif [ "$1" = "ping,trace" ];then
           traceroute $2 "-n" "-w" "3"  "-s" $6 "-m" $7 $4
	    echo
	    if [ -f $FILE ];
	    then
	     rm $FILE
	    else
	      ping  $2 "-s" $4 "-c" $5 "-I" $3 "-W" 1 
               if [ -f $FILE ];
                then
                        rm $FILE
                fi
	    exit 0
	    fi
	fi
else

	if [ "$1" = "ping" ];then
	    ping  $2 -s $3 "-c" $4
	    exit 0
	elif [ "$1" = "trace" ];then
	    traceroute $2 "-n" "-w" "3" "-m" $4 $3 
	    exit 0
	elif [ "$1" = "ping,trace" ];then
           traceroute $2 "-n" "-w" "3" "-m" $5 $3
            echo
	    if [ -f $FILE ];
            then 
		rm $FILE
           else 
	            ping  $2 "-s" $3 "-c" $4 "-W" 1 
                if [ -f $FILE ];
               then
                       rm $FILE
               fi
	    	exit 0
	    fi
	fi
fi 
