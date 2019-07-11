#!/bin/bash
#==================================================
# Description: print 9*9 口诀表
# Created: 20190711  
# Author: auspbro@gmail.com
#==================================================

for i in `seq 9` ; do
    for j in `seq $i` ; do
        echo -n "$i*$j=$(($i*$j)) "
    done
    echo ""
done
