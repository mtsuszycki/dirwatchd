#!/bin/bash

libdir=/usr/libexec/dirwatch
duration_ts=/opt/vnl/Tools/GetTSFileDuration
duration_mxf=$libdir/mxfdump
duration_mov=/opt/vnl/Tools/ReadMPEG
sleep_default=120

logpath=/var/log/dirwatchd

function alarm
{
	prg=${0/*\//}
	logger -p local0.info "$prg [$$] Error: $@"
}

function warn
{
	prg=${0/*\//}
	logger -p local0.info "$prg [$$] Warn: $@"
}

function say
{
	prg=${0/*\//}
	logger -p local0.info "$prg [$$]: $@"
}

function log_exit
{
	alarm $@
	exit 1;
}

transaction_log=''
# create one file per event, format: mv/cp | filename | source path | destination path
function log_event
{
	local cmd=$1 spath=$2 dpath=$3 duration=$4
	local file=${spath/*\//} size_file=$dpath/$file

	[ ! -z "${dpath/*\//}" ] && size_file=$dpath  # shitty hack indeed

	[ ! -d $logpath ] && { alarm "$logpath does not exist" ; return; }
	if [ -z "$transaction_log" ] ; then
		local d=`date "+%y%m%d-%H%M%S"`
		transaction_log=`mktemp $logpath/filepart.$d.XXXXXX` || { alarm "Cannot create $logpath/$d" ; return; }
	fi
# do stat and file size
	local size=`stat -c "%s" "$size_file" 2>/dev/null`
	[ -z $size ] && size=0
	echo "$cmd|$file|${spath%/*}/|$dpath|$size|$duration" >> $transaction_log
}

function log_close
{
	chmod a+r $transaction_log
	mv $transaction_log ${transaction_log/filepart./}
}

function file_is_ready
{
	local t=$sleep_default
	s=(`stat -c "%s %Y" "$1" 2>&1`)
	[ $? -ne 0 ] && { alarm "can't stat1 $1: ${s[@]}";  return 1 ; }
	
	[ ! -z $2 ] && t=$2
	sleep $t
	
	d=(`stat -c "%s %Y" "$1" 2>&1`)
	[ $? -ne 0 ] && { alarm "can't stat2 $1: ${d[@]}"; return 1 ; }

	[ ${s[0]} -ne ${d[0]} -o ${s[1]} -ne ${d[1]} ] && return 1
	return 0	
}

function get_duration
{
	local ext
	ext=`echo "${1/*./}" | tr A-Z a-z`
	case "$ext" in
		mpg|mpeg|ts)
			n=`$duration_ts "$1"`
			if [ $? -eq 0 ] ; then
	 			sec=`echo $n| awk '{print $3}'` 
				echo $sec
				return 0
			fi
			;;
		mxf)
			n=`$duration_mxf -m "$libdir/mxfdump-dict.xml" "$1" | grep -m1 'Duration ='`
			if [ $? -eq 0 ] ; then 
				d=`echo $n | awk '{print $3}'`
				echo "$d" | egrep -q '^[0-9]+$'
				[ $? -ne 0 ] && { alarm "Can't get duration1 $n";  echo 0 ; return 0; }
				echo $((d/25))
				return 0
			fi
			;;
		mov)
			n=`$duration_mov "$1" | awk '{if ($1 == "timescale") t=$3; if ($1 == "duration") d=$3; if (t && d) { printf("%.0f",d/t); e=1; exit 0} } END { if (!e) exit 1}' `
			if [ $? -eq 0 ] ; then
				echo $n 
				return 0
			fi
			;;
		*)	echo 0 
			return 0
			;;
	esac
	# error condition gets here. we return 0 for the caller to continue
	# because lack of duration isn't critical.
	warn "Can't get duration $1: $n"
	echo 0
	return 0
}	

