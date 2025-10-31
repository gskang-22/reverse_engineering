#!/bin/sh
## default logs functions
source /usr/exe/defset.as

## default logs
BARDEFAULT=15000
default_logs2tmp()
{
    if [ -f /logs/${LOGDEFAULT} ]; then
    SIZDEFAULT=$(ls -l /logs/${LOGDEFAULT} 2>/dev/null|sed "s/[! \t][ \t]*/ /g"|cut -d" " -f5)
    if [ "0${SIZDEFAULT}" -ge ${BARDEFAULT} ]; then mv -f /logs/${LOGDEFAULT} /logs/${BAKDEFAULT}
    else mv -f /logs/${LOGDEFAULT} /tmp/${LOGDEFAULT}; fi
    if [ -f /logs/${BAKDEFAULT} ]; then mv -f /logs/${BAKDEFAULT} /tmp/${BAKDEFAULT}; fi
  fi
}

default_tmp2logs()
{
  if [ -f /tmp/${BAKDEFAULT} ]; then mv -f /tmp/${BAKDEFAULT} /logs/${BAKDEFAULT}; fi
  if [ -f /tmp/${LOGDEFAULT} ]; then cat /tmp/${LOGDEFAULT} >> /logs/${LOGDEFAULT}; fi
  rm -rf /tmp/${LOGDEFAULT}
  sync
}

