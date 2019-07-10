#!/bin/bash
[ $# -eq 0 ] && echo "$0 csv file dir" && exit 1
files=$@
#sed -i 's:\*setdirs\*,,,:*setdirs*,,content_local,:' `find $files -type f -name '*.csv'`
#sed -i 's:\*setdirs\*,,content,:*setdirs*,,content_local,:' `find $files -type f -name '*.csv'`
sed -i 's/\*setdirs\*,,[0-9a-zA-Z_\/]*,/*setdirs*,,content_local,/' `find $files -type f -name '*.csv'`
