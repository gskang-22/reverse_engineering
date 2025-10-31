#!/bin/sh

data=$1
File="/proc/serdes/wan/rogue"

if [ ! -f "$File" ]; then
  echo "this file is not found!"
else
  if [ "on" = "$data" ]; then
    echo 1 > /proc/serdes/wan/rogue
    bs /b/c gpon link_activate=deactivate
    bs /b/c gpon link_activate=activate_O1
  elif [ "off" = "$data" ]; then
    echo 0 > /proc/serdes/wan/rogue
  else
    echo "input parameter is invalid, valid parameter is on or off"
  fi
fi
