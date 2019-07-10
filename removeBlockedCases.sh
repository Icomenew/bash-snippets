#!/bin/bash
[ $# -ne 1 ] && exit 1
fileName=$1
head -1 $fileName >tmp.csv
sed -n '2,$p' $fileName | while read line;do
	csv=`echo $line | cut -d, -f1 | awk '{print $4}'`
	id=`echo $line |cut -d, -f1 |  awk '{print $5}'`
#	echo "$csv $id"
	res=`grep "$id" "$csv"`
	[  -z "$res" ] && echo -e "\e[31m$line\e[0m" && exit 1
	state=`echo "$res" | cut -d, -f2`
	if [ -z "$state" ];then
		echo "$line" >>tmp.csv
	else
		echo "BLOCKED $csv $id"
	fi
done
