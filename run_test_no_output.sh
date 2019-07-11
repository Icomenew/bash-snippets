#!/bin/bash
[ $# -lt 1 ] && echo -e "\e[31m$0 <file name> ...\e[0m"
export LD_LIBRARY_PATH=$PWD/imports/mediasdk:$PWD/lib
#set the timeout,minute
timeout=$((60*12))
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
#		rm -f res.txt &>/dev/null
	#	rm -rf temp/* &>/dev/null
		startTime=`date "+%s"`
		cmd="`echo $line | cut -d, -f1`"
		[ -z "$cmd" ] && continue
		sudo dmesg -C
		testId="`echo $cmd | awk '{print $NF}'`"
		scenarioFile=$(basename `echo $cmd | sed 's/^.*[[:space:]]-s[[:space:]]\+\(.*\.csv\)[[:space:]].*$/\1/'`)
		$cmd 2>&1 | tee res.txt | tee -a $logfile &
		pid=$!
		while :;do
			gpuhang=`dmesg | grep -i 'GPU hang'`
			[ -n "$gpuhang" ] && gpuhang='GPU Hang'
			ps aux | awk '{print $2}' | grep -Eq "\b$pid\b"
			if [ $? -eq 0 ];then
				deltaTime=$((t2-startTime))
				if [ $deltaTime -ge $((timeout*60)) ];then
					echo "$cmd,TIMEOUT,`getLastNoNoneLine res.txt` $gpuhang" >>$resultFile
					kill -9 $pid
					killall -9 lucas
					break
				fi
			else
				res="`cat res.txt | grep -Em1  '^ERROR|\(issue #1\)'`"
				[ ! -z "$res" ] && echo "$cmd,FAILED,$res $gpuhang" >>$resultFile && break
				grep -q '(NOT RUN)' res.txt &&  echo "$cmd,Not Run," >>$resultFile && break
				grep -q '(PASSED)' res.txt &&  echo "$cmd,PASSED," >>$resultFile && rm -rf temp/$testId* && break
				res="`grep 'Input file.*not found' res.txt`" && echo "$cmd,FAILED,$res $gpuhang" >>$resultFile && break
				grep -q '(FAILED)' res.txt && echo "$cmd,FAILED,FAILED $gpuhang" >>$resultFile && break
				echo "$cmd,FAILED,`getLastNoNoneLine res.txt` $gpuhang" >>$resultFile && break
			fi
			t2=`date "+%s"`
			sleep 1
		done
	done
done
