#!/bin/bash
#$@ log file names"
result=failedCases.log
rm -f $result &>/dev/null
for log in $@;do
	failedIds=(`grep '(FAILED)' $log | uniq | sed "s/^.*TEST '\(.*\)' END.*$/\1/"`)
	for id in ${failedIds[@]};do
#		awk  "/'$id' START/","/'$id' END/" $log >>$result
		awk  "/'$id' START/","/ALWAYS  :ExecutionMgr: TimedOut/" $log >>$result
	done
done	
	

