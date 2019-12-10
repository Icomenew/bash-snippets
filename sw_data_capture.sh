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
        # cp $gta_pac_path${i}_GTAX-*-FM_task_logs*.zip ./$i/$driver_build
        mv $gta_pac_path${i}_GTAX-*-FM_task_logs*.zip ./$i/$driver_build
    done
}

# unzip perf sw overhead data csv file from GTA download. (SW_CASE_ID_perf_summary.csv)
get_sw_csv(){
    for i in APL CFL KBL SKL ICL ; do
        # unzip ./$i/$driver_build/*.zip -d ./$i/$driver_build/temp && \
        # cp ./$i/$driver_build/temp/*/logs/SW_*perf_summary.csv ./$i/$driver_build && \
        # rm -rf ./$i/$driver_build/temp
        unzip -j ./$i/$driver_build/*.zip *test_media_lucas*/logs/SW_*perf_summary.csv -d ./$i/$driver_build/  # -j 不处理压缩文件中原有的目录路径
    done

}

capture_sw_data(){
    for i in APL CFL KBL SKL ICL ; do
        cat ./$i/$driver_build/SW_*.csv | awk -F ',' '{print $1 "," $3}' | sed -e '/Summary/d;/CPU Latency Tag/d' > ./temp/${driver_build}_${i}_temp.csv
        sed -i '1i CPU Latency Tag,Average (ms)' ./temp/${driver_build}_${i}_temp.csv
        sed -i "1i CI Biuld,${driver_build}" ./temp/${driver_build}_${i}_temp.csv
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

chk_folder(){
	if [ ! -d APL ]; then
    mkdir APL
	else echo "Folder APL exist."
	fi

	if [ ! -d CFL ]; then
	mkdir CFL
	else echo "Folder CFL exist."
	fi

	if [ ! -d KBL ]; then
	mkdir KBL
	else echo "Folder KBL exist."
	fi

	if [ ! -d SKL ]; then
	mkdir SKL
	else echo "Folder SKL exist."
	fi

	if [ ! -d ICL ]; then
	mkdir ICL
	else echo "Folder ICL exist."
	fi

	if [ ! -d temp ]; then
	mkdir temp
	else echo "Folder temp exist."
	fi
}

# mian funcation
if [ $# -gt -0 ]; then
	chk_folder
    cp_package
	get_sw_csv
    capture_sw_data
    echo -e "\e[32m Done.\e[0m"
else
	help_info
	exit 1
fi