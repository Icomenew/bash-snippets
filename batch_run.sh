#!/bin/bash
#==================================================
# DESCRIPTION:
# batch run test cases
# HISTORY:
# 2019/07/04    auspbro@gmail.com    First release.
#==================================================
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

[ $# -lt 1 ] && echo -e "\e[33mUsage: $0 <case_list1.csv> <case_list2.csv> ...\e[0m"
export LD_LIBRARY_PATH=$PWD/imports/mediasdk:$PWD/lib
timeout=90 # set timeout of running one case (minute)
csv_files=($@)

detect_fail_msg()
{
    local filename=$1
    local line
    tac $filename | while read line ; do
        [ -n "$line" ] && echo $line && break
    done
}

driver_ver=`vainfo 2>&1 | grep -ni 'driver version' | cut -d' ' -f 8`
#echo $driver_ver 

del_decode_yuv_files()
{
    #remove the decoded output yuv files to save space.
    [ -n "$log_dir" ] && find $log_dir -type f -name '*.yuv' -o -name '*.i010' -print0 | xargs -0 rm -f
}

trap "pkill `basename $0`;exit" 2

for csv_file in ${csv_files[@]} ; do
    date_time=`date +%Y-%m-%d_%H_%M_%S`
    log_file=${csv_file%.*}_${driver_ver}_${date_time}.log
    result_file=${csv_file%.*}_${driver_ver}_${date_time}.csv
    echo "Command,Result,Comment" > $result_file
    N=`cat $csv_file | wc -l`
    for (( i = 2; i < N; i++ )); do
        line="`sed -n ${i}p $csv_file`"
        echo $line | grep -q '^$' && continue
        echo $line | grep -q '^#' && echo $line >>$result_file && continue
        rm -rf temp/* &>/dev/null 
        start_time=`date +%S`
        cmd="`echo $line | cut -d, -f 1`"
        [ -z "$cmd" ] && continue 
        sudo dmesg -C
        test_id="`echo $cmd | cut -d' ' -f 5`"
        scenario_file=$(basename `echo $cmd | sed 's/^.*[[:space:]]-s[[:space:]]\+\(.*\.csv\)[[:space:]].*$/\1/'`)
        log_dir=$PWD/logs/$driver_ver/$scenario_file
        [ ! -d $log_dir ] && sudo mkdir -p $log_dir
        case_log=$log_dir/$test_id.log
        $cmd 2>&1 | tee $case_log | tee -a $log_file &
        pid=$!
        cp -rf temp/* $log_dir &>/dev/null
        del_decode_yuv_files
    done
done
