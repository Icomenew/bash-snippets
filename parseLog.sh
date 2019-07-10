#!/bin/bash
#$1 function name $2 .... log file name"
funcName=$1
shift
result=${funcName}_summary.csv
rm -f $result
for log in $@;do
	csvFile=`grep -m1 'Command line:' $log | sed 's/^.*-s[[:space:]]\+\(scenarios.\+\.csv\)[[:space:]]\+.*$/\1/'`
#	echo $csvFile
	grep -E '\(PASSED\)|\(FAILED\)' $log | uniq >tmp.txt
	cat tmp.txt | while read line;do
		testId=`echo $line | cut -d"'" -f2`
		res=`echo $line | awk '{print $NF}' | tr -d '()'`
		if [ "$res" = FAILED ] ;then
			comment=`awk  "/'$testId' START/","/'$testId' END/" $log | grep -iEm1 '\(issue #1\)|ERROR'`
		else
			comment=''
		fi
		echo $funcName,$csvFile,$testId,$res,$comment | tee -a $result
	done	
done	
rm -f tmp.txt
	

