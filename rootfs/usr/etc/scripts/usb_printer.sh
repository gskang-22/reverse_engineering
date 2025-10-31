#!/bin/sh
# This program will execute the cmd

FILENAME1="/dev/lp0"
FILENAME2="/dev/lp1"

if [ -c $FILENAME1 ]; then
   chmod 0777 $FILENAME1
  fi

if [ -c $FILENAME2 ]; then
   chmod 0777 $FILENAME2
fi

lpinfo -u
