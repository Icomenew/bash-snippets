#!/bin/bash

cat SW_*.csv | awk -F ',' '{print $1 "," $3}' | sed -e '/Summary/d;/CPU Latency Tag/d' > temp.csv
sed -i '1i CPU Latency Tag,Average (ms)' temp.csv
