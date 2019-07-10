#!/bin/bash
#==================================================
# DESCRIPTION:
# generate test case list
# HISTORY:
# 2019/07/04    auspbro@gmail.com    First release.
#==================================================
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

[ $# -lt 1 ] && echo -e "\e[33m Usage: $0 <file1.csv> <file2.csv> ...or <*.csv>\e[0m" && exit 1

output_name=case_list.csv
echo "Command,Result,Comment,Resolution" >$output_name
for csv in $@ ; do
    sed -n '2,$p' $csv | grep -Ev '^\*setdirs\*|^#|^$' | while read line ; do
    test_id="`echo $line | cut -d, -f1`"
    state=`echo $line | cut -d, -f2`
    clip=`echo $line | cut -d, -f3`
    resolution=`echo $line | cut -d, -f4`
    #echo $test_id 
    case $state in
        b|B|block)
            echo "./lucas --scenario-safe-mode -s $csv $test_id,blocked in csv,,$resolution" | tee -a $output_name
            continue;;
    esac
    [ -z "$clip" ] && continue
    if [[ -n "$test_id" ]]; then
        echo $line | grep -q "p010,p010"
        [ $? -eq 0 ] && echo "./lucas --scenario-safe-mode -s $csv $test_id,p010 Case,,$resolution" | tee -a $output_name && continue
        echo "./lucas --scenario-safe-mode -s $csv $test_id,,,$resolution" | tee -a $output_name
    fi
    done
done

echo -e "\e[32mDone! Please check $output_name.\e[0m"
