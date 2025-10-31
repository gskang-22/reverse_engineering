#!/bin/sh
##
##Usage:
##  -d: now domain number
##  -m: changed domain number
##  -c: value to write for pmc parameter clockClass       
##  -a: value to write for pmc parameter clockAccuracy
##  -t: value to write for pmc parameter timeSource 
##  -1: value to write for pmc parameter priority1
##  -2: value to write for pmc parameter priority2
##  -s: value to write for pmc parameter ptpTimescale
##  -o: value to write for pmc parameter currentUtcOffset
##  -v: value to write for pmc parameter currentUtcOffsetValid
##  -l: value to write for pmc parameter leap61
##  -e: value to write for pmc parameter leap59
##  -i: value to write for pmc parameter timeTraceable
##  -f: value to write for pmc parameter frequencyTraceable
##  -g: value to write for pmc parameter offsetScaledLogVariance
##  -b: value to write for pmc parameter step removed
##  -j: value to write for pmc parameter log sync interval
##  -k: value to write for pmc parameter log delay interval
##  -n: value to write for pmc parameter log announce interval
##  -x: value to write for pmc parameter externalGrandmasterId
##  -u: UNIX domain socket for the ptp4l instance
##
#set -x 

#get_prg() {
#	echo `ps | grep "$1" | grep -v grep`
#}

# check if already running
#prg=`get_prg "ptp4l "`
#if [ -z "$prg" ]; then
#	echo "ptp4l not running"
#	echo "Leaving..."
#	exit 1
#fi

usage()
{
  grep "^##" $0 | cut -c3-
  exit 2
}

GRANDMASTER_SETTINGS_nochange=0

while getopts ":d:m:c:a:t:1:2:o:v:l:e:i:f:s:g:b:j:k:n:x:u:" opt; do
  case "${opt}" in
	d)
      old_domain_value=${OPTARG}
      if [ -z "${old_domain_value}" ]; then
        usage
      fi
      ;;
	m)
      changed_domain_value=${OPTARG}
      if [ -z "${changed_domain_value}" ]; then
        usage
      fi
      ;;
	c)
      clockClass_value=${OPTARG}
      if [ -z "${clockClass_value}" ]; then
        usage
      fi
      ;;
	a)
      clockAccuracy_value=${OPTARG}
      if [ -z "${clockAccuracy_value}" ]; then
        usage
      fi
      ;;
	t)
      timeSource_value=${OPTARG}
      if [ -z "${timeSource_value}" ]; then
        usage
      fi
      ;;
	1)
      priority1_value=${OPTARG}
      if [ -z "${priority1_value}" ]; then
        usage
      fi
      ;;
	2)
      priority2_value=${OPTARG}
      if [ -z "${priority2_value}" ]; then
        usage
      fi
      ;;
	o)
      currentUtcOffset_value=${OPTARG}
      if [ -z "${currentUtcOffset_value}" ]; then
        usage
      fi
      ;;
	v)
      currentUtcOffsetValid_value=${OPTARG}
      if [ -z "${currentUtcOffsetValid_value}" ]; then
        usage
      fi
      ;;
	l)
      leap61_value=${OPTARG}
      if [ -z "${leap61_value}" ]; then
        usage
      fi
      ;;
	e)
      leap59_value=${OPTARG}
      if [ -z "${leap59_value}" ]; then
        usage
      fi
      ;;
	i)
      timeTraceable_value=${OPTARG}
      if [ -z "${timeTraceable_value}" ]; then
        usage
      fi
      ;;
	f)
      frequencyTraceable_value=${OPTARG}
      if [ -z "${frequencyTraceable_value}" ]; then
        usage
      fi
      ;;
	s)
      ptpTimescale_value=${OPTARG}
      if [ -z "${ptpTimescale_value}" ]; then
        usage
      fi
      ;;
	g)
      offsetScaledLogVariance_value=${OPTARG}
      if [ -z "${offsetScaledLogVariance_value}" ]; then
        usage
      fi
      ;;
	b)
      stepRemoved_value=${OPTARG}
      if [ -z "${stepRemoved_value}" ]; then
        usage
      fi
      ;;
	j)
      logSyncInterval_value=${OPTARG}
      if [ -z "${logSyncInterval_value}" ]; then
        usage
      fi
      ;;
	k)
      logDelayInterval_value=${OPTARG}
      if [ -z "${logDelayInterval_value}" ]; then
        usage
      fi
      ;;
	n)
      logAnnounceInterval_value=${OPTARG}
      if [ -z "${logAnnounceInterval_value}" ]; then
        usage
      fi
      ;;
	x)
      externalGrandmasterId_value=${OPTARG}
      if [ -z "${externalGrandmasterId_value}" ]; then
        usage
      fi
      ;;
	u)
      unixDomainSocket_value=${OPTARG}
      if [ -z "${unixDomainSocket_value}" ]; then
        usage
      fi
      ;;
	*)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

#if [ -z "${old_domain_value}" ]; then
#	echo "no domain number input. leaving..."
#	exit 3
#fi

if [ ! -z "${changed_domain_value}" ]; then
	if [ "${changed_domain_value}" != "${old_domain_value}" ]; then
		pmc -u -d "${old_domain_value}" "SET DOMAIN ${changed_domain_value}" -s "${unixDomainSocket_value}"
	fi
else
	changed_domain_value="${old_domain_value}"
fi

if [ -z "$clockClass_value" ] && \
   [ -z "$clockAccuracy_value" ] && \
   [ -z "$timeSource_value" ] && \
   [ -z "$ptpTimescale_value" ] && \
   [ -z "$timeTraceable_value" ] && \
   [ -z "$frequencyTraceable_value" ] && \
   [ -z "$currentUtcOffset_value" ] && \
   [ -z "$currentUtcOffsetValid_value" ] && \
   [ -z "$offsetScaledLogVariance_value" ] && \
   [ -z "$externalGrandmasterId_value" ] && \
   [ -z "$leap61_value" ] && \
   [ -z "$leap59_value" ]; then
		GRANDMASTER_SETTINGS_nochange=1
fi

if [ ${GRANDMASTER_SETTINGS_nochange} -ne 1 ]; then
	PMC_OUTPUT="$(pmc -u -d ${changed_domain_value} 'GET GRANDMASTER_SETTINGS_NP' -s ${unixDomainSocket_value})"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: pmc command failure with return value of ${RET}\n"
	  exit ${RET}
	fi

	clockClass_str="clockClass"
	clockAccuracy_str="clockAccuracy"
	offsetScaledLogVariance_str="offsetScaledLogVariance"
	currentUtcOffset_str="currentUtcOffset"
	leap61_str="leap61"
	leap59_str="leap59"
	currentUtcOffsetValid_str="currentUtcOffsetValid"
	ptpTimescale_str="ptpTimescale"
	timeTraceable_str="timeTraceable"
	frequencyTraceable_str="frequencyTraceable"
	timeSource_str="timeSource"
	externalGrandmasterId_str="externalGrandmasterId"

	if [ -z "${clockClass_value}" ]; then
		clockClass_value=$(echo ${PMC_OUTPUT#*${clockClass_str}} | cut -f1 -d" ")
	fi

	if [ -z "${clockAccuracy_value}" ]; then
		clockAccuracy_value=$(echo ${PMC_OUTPUT#*${clockAccuracy_str}} | cut -f1 -d" ")
	fi

	if [ -z "${offsetScaledLogVariance_value}" ]; then
	offsetScaledLogVariance_value=$(echo ${PMC_OUTPUT#*${offsetScaledLogVariance_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${currentUtcOffset_value}" ]; then
	currentUtcOffset_value=$(echo ${PMC_OUTPUT#*${currentUtcOffset_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${currentUtcOffsetValid_value}" ]; then
	currentUtcOffsetValid_value=$(echo ${PMC_OUTPUT#*${currentUtcOffsetValid_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${leap61_value}" ]; then
	leap61_value=$(echo ${PMC_OUTPUT#*${leap61_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${leap59_value}" ]; then
	leap59_value=$(echo ${PMC_OUTPUT#*${leap59_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${ptpTimescale_value}" ]; then
	ptpTimescale_value=$(echo ${PMC_OUTPUT#*${ptpTimescale_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${timeTraceable_value}" ]; then
	timeTraceable_value=$(echo ${PMC_OUTPUT#*${timeTraceable_str}} | cut -f1 -d" ")
	fi

	if [ -z "${frequencyTraceable_value}" ]; then
	frequencyTraceable_value=$(echo ${PMC_OUTPUT#*${frequencyTraceable_str}} | cut -f1 -d" ")
	fi
	
	if [ -z "${timeSource_value}" ]; then
		timeSource_value=$(echo ${PMC_OUTPUT#*${timeSource_str}} | cut -f1 -d" ")
	fi

	if [ -z "${externalGrandmasterId_value}" ]; then
		externalGrandmasterId_value=$(echo ${PMC_OUTPUT#*${externalGrandmasterId_str}} | cut -f1 -d" ")
	fi
	
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET GRANDMASTER_SETTINGS_NP ${clockClass_str} ${clockClass_value} ${clockAccuracy_str} ${clockAccuracy_value} ${offsetScaledLogVariance_str} ${offsetScaledLogVariance_value} ${currentUtcOffset_str} ${currentUtcOffset_value} ${leap61_str} ${leap61_value} ${leap59_str} ${leap59_value} ${currentUtcOffsetValid_str} ${currentUtcOffsetValid_value} ${ptpTimescale_str} ${ptpTimescale_value} ${timeTraceable_str} ${timeTraceable_value} ${frequencyTraceable_str} ${frequencyTraceable_value} ${timeSource_str} ${timeSource_value} ${externalGrandmasterId_str} ${externalGrandmasterId_value}' -s "${unixDomainSocket_value}""
	
	pmc -u -d "${changed_domain_value}" "SET GRANDMASTER_SETTINGS_NP ${clockClass_str} ${clockClass_value} ${clockAccuracy_str} ${clockAccuracy_value} ${offsetScaledLogVariance_str} ${offsetScaledLogVariance_value} ${currentUtcOffset_str} ${currentUtcOffset_value} ${leap61_str} ${leap61_value} ${leap59_str} ${leap59_value} ${currentUtcOffsetValid_str} ${currentUtcOffsetValid_value} ${ptpTimescale_str} ${ptpTimescale_value} ${timeTraceable_str} ${timeTraceable_value} ${frequencyTraceable_str} ${frequencyTraceable_value} ${timeSource_str} ${timeSource_value} ${externalGrandmasterId_str} ${externalGrandmasterId_value}" -s "${unixDomainSocket_value}"
	
	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET GRANDMASTER_SETTINGS_NP failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${priority1_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET PRIORITY1 ${priority1_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET PRIORITY1 ${priority1_value}" -s "${unixDomainSocket_value}"
	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET PRIORITY1 failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${priority2_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET PRIORITY2 ${priority2_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET PRIORITY2 ${priority2_value}" -s "${unixDomainSocket_value}"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET PRIORITY1 failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${stepRemoved_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET CURRENT_DATA_SET_STEPS_REMOVED_NP ${stepRemoved_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET CURRENT_DATA_SET_STEPS_REMOVED_NP ${stepRemoved_value}" -s "${unixDomainSocket_value}"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET stepRemoved failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${logSyncInterval_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET LOG_SYNC_INTERVAL ${logSyncInterval_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET LOG_SYNC_INTERVAL ${logSyncInterval_value}" -s "${unixDomainSocket_value}"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET logSyncInterval failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${logDelayInterval_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET LOG_MIN_DELAY_REQ_INTERVAL_NP ${logDelayInterval_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET LOG_MIN_DELAY_REQ_INTERVAL_NP ${logDelayInterval_value}" -s "${unixDomainSocket_value}"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET logDelayInterval failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

if [ ! -z "${logAnnounceInterval_value}" ]; then
	echo -e "\npmc -u -d "${changed_domain_value}" 'SET LOG_ANNOUNCE_INTERVAL ${logAnnounceInterval_value}' -s "${unixDomainSocket_value}""
	pmc -u -d "${changed_domain_value}" "SET LOG_ANNOUNCE_INTERVAL ${logAnnounceInterval_value}" -s "${unixDomainSocket_value}"

	RET=$?
	if [ "${RET}" -ne 0 ]; then
	  echo -e "ERROR: SET logAnnounceInterval failure with return value of ${RET}\n"
	  exit ${RET}
	fi
fi

exit 0
