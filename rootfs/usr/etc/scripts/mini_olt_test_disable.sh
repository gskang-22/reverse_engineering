#!/bin/sh
set -x

show_help() {
    echo "Usage: $0"
    echo "       No arguments needed."
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	show_help; exit 0
fi

bs /b/d egress_tm/dir=us,index=70
bs /b/d tcont/index=1
bs /b/d gem/index=30

bs /b/d ingress_class/dir=us,index=10
bs /b/d ingress_class/dir=ds,index=11

bs /b/d vlan_action/dir=us,index=10
bs /b/d vlan_action/dir=ds,index=11

gponif -r wan0 -g 30
