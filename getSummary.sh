#!/bin/bash
[ $# -ne 1 ] && exit
fileName=$1
resfile=tmp_${RANDOM}_${RANDOM}.csv
trap "rm -f $resfile &>/dev/null && exit -1" SIGINT
head -1 $fileName >$resfile
sed -n '2,$p' $fileName | while read line;do
	comment="`echo $line | cut -d, -f3`"
	if echo $comment | grep -q 'PSNR.*lower';then
		echo `echo "$line" | cut -d, -f1-2`,PSNR drop >>$resfile
	elif echo $comment |grep -q 'SSIM.*lower';then
		echo `echo "$line" | cut -d, -f1-2`,SSIM drop >>$resfile
	else
		echo "$line" >>$resfile
	fi
done
fileName=$resfile
#csvs=(`cat $fileName | awk '{print $4}' | uniq`)
csvs=(`sed -n '2,$p' $fileName | sed 's/^.*[[:space:]]-s[[:space:]]\+\(.*\.csv\)[[:space:]].*$/\1/i' | sort | uniq`)
echo "Scenario File,Total,Passed,Failed,Blocked,Pass Rate,Comment" >summary.csv
for csv in "${csvs[@]}";do
	x=`basename $csv`
	passedNum=`grep "$x" $fileName | grep -c PASSED`	
	failedNum=`grep "$x" $fileName | grep -c 'FAILED'`
	timeoutNum=`grep "$x" $fileName | grep -c 'TIMEOUT'`
	blockedNum=`grep "$x" $fileName | grep -c 'BLOCKED'`
	totalNum=$((passedNum+failedNum+timeoutNum+blockedNum))
    passRate=`echo "scale=2;100*$passedNum/$totalNum" | bc`%
#	errorInfos="`grep "$x" $fileName | cut -d, -f3- | grep -v '^$' | sort | uniq | tr '\n' '|' | sed 's/,|\(.*$\)/,\1/' | sed 's/|$/\n/'`"
    errorInfos=''
    comment=$(\
    grep "$x" $fileName | cut -d, -f3- | grep -v '^$' | sort | uniq -c | while read line;do
        numOfCases=`echo $line | awk '{print $1}'`
        failedInfo=`echo $line | awk '{$1="";print $0}'`
        [ "$numOfCases" -ne 1 ] && suffix=cases || suffix=case
        [ -z "$errorInfos" ] && errorInfos="$failedInfo[$numOfCases $suffix]" || errorInfos="$errorInfos|$failedInfo[$numOfCases $suffix]"
        echo $errorInfos
done | tail -1)
    echo $comment
	#errorInfos="`grep "$x" $fileName | cut -d, -f3- | grep -v '^$' | sort | uniq -c | tr '\n' '|' | sed 's/,|\(.*$\)/,\1/' | sed 's/|$/\n/'`"
	[ $timeoutNum -ne 0 ] &&  ([ -n "$comment" ] && comment="$comment|TIMEOUT" || comment=TIMEOUT)
#	errors=''
#	for errorInfo in "${errorInfos[@]}";do
#		[ -n "$errors" ] && errors="$errors|$errorInfo" || errors="$errorInfo"
#	done
	echo "$x,$totalNum,$passedNum,$((failedNum+timeoutNum)),$blockedNum,$passRate,$comment" | tee -a summary.csv
done
allCasesNum=`sed -n '2,$p' summary.csv | cut -d, -f2 | tr '\n' + | sed 's/$/0\n/' | bc`
allPassedNum=`sed -n '2,$p' summary.csv | cut -d, -f3 | tr '\n' + | sed 's/$/0\n/' | bc`
allFailedNum=`sed -n '2,$p' summary.csv | cut -d, -f4 | tr '\n' + | sed 's/$/0\n/' | bc`
allBlockedNum=`sed -n '2,$p' summary.csv | cut -d, -f5 | tr '\n' + | sed 's/$/0\n/' | bc`
allPassRate=`echo "scale=2;100*$allPassedNum/$allCasesNum" | bc`%
echo "Total,$allCasesNum,$allPassedNum,$allFailedNum,$allBlockedNum,$allPassRate," | tee -a summary.csv
echo -e "\e[1;32mPlease refer to summary.csv\e[0m"
rm -f $resfile
	
