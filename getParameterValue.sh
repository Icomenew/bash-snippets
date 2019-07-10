#!/bin/bash
ECHO_RED()
{
	echo -e "\e[31m$@\e[0m"
}


ECHO_GREEN()
{
	echo -e "\e[32m$@\e[0m"
}

[ $# -ne 3 ] && ECHO_RED "$0 <csv filename> <id> <parameter name>" && exit 1
csvName=$1
id=$2
parName=$3
pars=`head -1 $csvName`
[ ! -f $csvName ] && ECHO_RED "No $csvName" && exit 1
[ -z "`grep -ow ^$id $csvName`" ]  && ECHO_RED "No test id \"$id\" in $csvName" && exit 1

pos=0
N=`echo $pars | awk -F, '{print NF}'`
for((pos=1;pos<=N;++pos))do
	par=`echo $pars | cut -d, -f$pos`
	[ "$par" = "$parName" ] && break
done
[ $pos -gt $N ] && ECHO_RED "No parameter \"$parName\" in $csvName" && exit 1

v=`grep $id $csvName | cut -d, -f$pos`

ECHO_GREEN "Test ID: $id\n$parName = $v"
