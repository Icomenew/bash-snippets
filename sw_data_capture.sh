#!/bin/bash
# coding: utf-8
# mail: auspbro@gmail.com


work_week=$1
platform=$2
driver_build=$3

# help info function
help_info() {
	echo -e "--------------------------------------------------"
	echo -e "          Usage: sw overhead data capture         "
	echo -e "--------------------------------------------------"
	echo -e "Args\t\t Describe"
	echo -e "  -h\t\t get all help infomations"
	echo -e "eg:"
	echo -e "$0 work_week platform driver_build"
	echo -e "$0 ww38 APL open-linux-driver-ci-dev_media-3084"
}


# unzip perf sw overhead data csv file from GTA download. (SW_CASE_ID_perf_summary.csv)
get_sw_csv(){
    
    unzip *.zip -d ./temp && cp ./temp/*/logs/SW_*perf_summary.csv ./ && rm -rf temp


}

capture_sw_data(){
    cat SW_*.csv | awk -F ',' '{print $1 "," $3}' | sed -e '/Summary/d;/CPU Latency Tag/d' > temp.csv
    sed -i '1i CPU Latency Tag,Average (ms)' temp.csv

}


# get opts
while getopts "t:i:o:h" arg; do
	case $arg in
	t)
		type=$OPTARG
		;;
	i)
		inputf=$OPTARG
		;;
	o)
		outputf=$OPTARG
		;;
	h)
		help_info
		exit 1
		;;
	?)
		echo -e "\033[1;31m[ Error ]\033[0m Umm, Unknown Argument!"
		help_info
		exit 1
		;;
	esac
done

# mian funcation
if [ $# -gt -0 ]; then
	get_sw_csv
    capture_sw_data
else
	help_info
	exit 1
fi