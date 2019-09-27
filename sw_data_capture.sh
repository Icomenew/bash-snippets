#!/bin/bash
# coding: utf-8
# mail: auspbro@gmail.com


driver_build=$1
gta_pac_path="C:/Users/xuex1x/Downloads/"   # GTA package download path on local

# help info function
help_info() {
	echo -e "--------------------------------------------------"
	echo -e "          Usage: sw overhead data capture         "
	echo -e "--------------------------------------------------"
	echo -e "Args\t\t Describe"
	echo -e "  -h\t\t get all help infomations"
	echo -e "eg:"
	echo -e "$0 driver_build"
	echo -e "$0 open-linux-driver-ci-dev_media-3084"
}

cp_package(){
    for i in APL CFL KBL SKL ICL ; do
        mkdir ./$i/$driver_build
        cp $gta_pac_path${i}_GTAX-*-FM_task_logs*.zip ./$i/$driver_build
    done
}

# unzip perf sw overhead data csv file from GTA download. (SW_CASE_ID_perf_summary.csv)
get_sw_csv(){
    for i in APL CFL KBL SKL ICL ; do
        unzip ./$i/$driver_build/*.zip -d ./$i/$driver_build/temp && \
        cp ./$i/$driver_build/temp/*/logs/SW_*perf_summary.csv ./$i/$driver_build && \
        rm -rf ./$i/$driver_build/temp
    done

}

capture_sw_data(){
    for i in APL CFL KBL SKL ICL ; do
        cat ./$i/$driver_build/SW_*.csv | awk -F ',' '{print $1 "," $3}' | sed -e '/Summary/d;/CPU Latency Tag/d' > ./$i/$driver_build/temp.csv
        sed -i '1i CPU Latency Tag,Average (ms)' ./$i/$driver_build/temp.csv
    done
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
    cp_package
	get_sw_csv
    capture_sw_data
    echo -e "\e[32m Done.\e[0m"
else
	help_info
	exit 1
fi