#!/bin/sh
#Example:
#   profilepolicy.sh policy_id enter
#   profilepolicy.sh policy_id exit

if [ $# -lt 2 ]; then
    echo "no enough parameters"
    echo "  usage:"
    echo "  profilepolicy.sh policy_id enter/exit"
    exit 1
fi

enable()
{
    #for avoid data sync issue, send msg to cfgmgr to handle this case
    cfgcli entersched $1
}

disable()
{
    cfgcli exitsched $1
}

if [ $2 == "enter" ]; then
    echo "enter"
    enable $1
elif [ $2 == "exit" ]; then
    echo "exit"
    disable $1
fi
