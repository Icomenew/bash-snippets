#!/bin/bash
# script usage
[ $# -lt 1 ] && echo -e "\e[31m$0 <case sute csv file name> ...\e[0m"
export LD_LIBRARY_PATH=$PWD/imports/mediasdk:$PWD/lib
# set the timeout of running one case (minute)
timeout=90
csvFiles=($@)
getLastNoNoneLine()
{
	local fileName=$1
	local line
	tac $fileName | while read line;do
		[ -n "$line" ] && echo $line && break
	done
}
driver_version=`vainfo 2>&1 | awk '/Driver version:/{print $NF}'`

removeDecodeYuvFiles()
{
# Remove the decoded output yuv files to save storage space.
	[ -n "$logDir" ] && find $logDir -type f -name '*.yuv' -o -name '*.i010' -print0 | xargs -0 rm -f
}
trap "pkill `basename $0`;exit" 2

for csvFile in ${csvFiles[@]};do
	dateTime=`date "+%Y-%m-%d_%H-%M-%S"`
	logfile=${csvFile%.*}_${driver_version}_${dateTime}.log
	resultFile=${csvFile%.*}_${driver_version}_${dateTime}.csv
	echo "Command,Result,Comment" >$resultFile
	N=`cat $csvFile | wc -l`
	for((i=2;i<=N;i++));do
		line="`sed -n ${i}p $csvFile`"
#	sed -n '2,$p' $csvFile | while read line;do
		echo $line | grep -q '^$' && continue
		echo $line | grep -q '^#' && echo $line >>$resultFile && continue
#		rm -f $caseLog &>/dev/null
		rm -rf temp/* &>/dev/null
		startTime=`date "+%s"`
		cmd="`echo $line | cut -d, -f1`"
		[ -z "$cmd" ] && continue
		sudo dmesg -C
		testId="`echo $cmd | awk '{print $NF}'`"
		scenarioFile=$(basename `echo $cmd | sed 's/^.*[[:space:]]-s[[:space:]]\+\(.*\.csv\)[[:space:]].*$/\1/'`)
		logDir=$PWD/logs/$driver_version/$scenarioFile
		[ ! -d $logDir ] && mkdir -p $logDir
		caseLog=$logDir/$testId.log
		$cmd 2>&1 | tee $caseLog | tee -a $logfile &
		pid=$!
		while :;do
			gpuhang=`dmesg | grep -i 'GPU hang'`
			[ -n "$gpuhang" ] && gpuhang='GPU Hang'
			ps aux | awk '{print $2}' | grep -Eq "\b$pid\b"
			if [ $? -eq 0 ];then
				deltaTime=$((t2-startTime))
				if [ $deltaTime -ge $((timeout*60)) ];then
					echo "$cmd,TIMEOUT,`getLastNoNoneLine $caseLog` $gpuhang" >>$resultFile
					kill -9 $pid
					killall -9 lucas
					break
				fi
			else
				res="`cat $caseLog | grep -Em1  '^ERROR|\(issue #1\)'`"
				[ ! -z "$res" ] && echo "$cmd,FAILED,$res $gpuhang" >>$resultFile && break
				grep -q '(NOT RUN)' $caseLog &&  echo "$cmd,Not Run," >>$resultFile && break
				grep -q '(PASSED)' $caseLog &&  echo "$cmd,PASSED," >>$resultFile && break
				res="`grep 'Input file.*not found' $caseLog`" && echo "$cmd,FAILED,$res $gpuhang" >>$resultFile && break
				grep -q 'Segmentation fault' $caseLog && echo "$cmd,FAILED,Segmentation fault $gpuhang" >>$resultFile && break
				grep -q '(FAILED)' $caseLog && echo "$cmd,FAILED,FAILED $gpuhang" >>$resultFile && break
				echo "$cmd,FAILED,`getLastNoNoneLine $caseLog` $gpuhang" >>$resultFile && break
			fi
			t2=`date "+%s"`
			sleep 1
		done
		[ -n "$gpuhang" ] && sudo cat /sys/kernel/debug/dri/0/i915_error_state >temp/${testId}_i915_error_state.log && cp -rf temp/* $logDir &>/dev/null && echo "GPU Hang, exit" && exit 1
		cp -rf temp/* $logDir &>/dev/null
		removeDecodeYuvFiles
	done
done
