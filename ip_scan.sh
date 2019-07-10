#!/bin/bash
#==================================================
# Description: 判断当前网络里，当前在线的IP有哪些？
# Created: date  
# Author: auspbro@gmail.com
#==================================================

rm /tmp/ip_down.log
for ip in 10.239.140.{1..10} ; do
    ping -c 2 -w 2 ${ip}>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "$ip is ok."
    else
        echo "$ip is down.">>/tmp/ip_down.log
    fi
done
