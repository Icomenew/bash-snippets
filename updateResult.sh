#!/bin/bash
[  $# -ne 2 ] && echo -e "\e[31m$0 <file1> <file2>\e[0m" && exit 1
file1=$1
file2=$2
resfile=$file1.update
head -1 $file1 >$resfile
sed -n '2,$p' $file1 | while read line;do
	cmd="`echo $line | cut -d, -f1`"
	line2="`grep \"$cmd\" $file2`"
	[ -z "$line2" ] && echo "$line" >>$resfile || echo "$line2" >>$resfile
done
