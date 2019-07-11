#!/bin/bash
cmd="$@"
id=`echo $cmd | awk '{print $NF}'`
csv=`echo $cmd | sed 's/.* \+\(.*\.csv\).*/\1/'`
yuvDir=`grep setdirs $csv | cut -d, -f3`
yuvs=`grep -E "^$id\b" "$csv" | cut -d, -f3 | tr ';' ' '`
for yuv in $yuvs;do
	[ -z "$yuv" ] && echo -e "\e[32mYUV should not be empty\e[0m" && exit 1
	[ "$yuvDir" = content ]  && echo -e "\e[32mYUV Dir should not be content\e[0m" && exit 1
	[ ! -f $yuvDir/$yuv ] && echo "Copy content/$yuv to $yuvDir" && cp -f content/$yuv $yuvDir/$yuv
done
$cmd
