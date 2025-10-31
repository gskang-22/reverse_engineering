#!/bin/sh

#
# kill apps which are not needed in AP Bridge work mode 
#
#

# Scan apps every 5 seconds, totally 36 times(about 3 minutes).
# Assume all apps will be bootup during 3 minutes after executing 
# this script.
MAX_TIMES=36
SLEEP_SEC=5

# The apps in the list are required to be killed in the script 
# Add or delete an app to the list according to the stip requirement.
APPLIST="dnsproxy ramond wanlived radvd"

#
# Main
#
for i in `seq $MAX_TIMES` ; do
    unset TMP_LIST
        for app in $APPLIST ; do
                killall -9 $app &>/dev/null || TMP_LIST="$TMP_LIST $app"
        done
        APPLIST=$TMP_LIST
        [ "$APPLIST" = "" ] && exit 0

        # echo "Scan for $i round, app list: $APPLIST."

        sleep $SLEEP_SEC
done
