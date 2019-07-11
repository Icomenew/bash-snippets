#!/bin/bash
logs=(
lucas_mv_encoder_AVC_CBR.log
lucas_mv_encoder_AVC_CBR_MBBRC.log
lucas_mv_encoder_AVC_CBR_MBBRC.log
lucas_mv_encoder_AVC_SKIP_CBR_Android.log
lucas_mv_encoder_AVC_SKIP_VBR_Android.log
lucas_mv_encoder_AVC_VBR.log
lucas_mv_encoder_AVC_VBR_MBBRC.log
)
logs=(`grep '(FAILED)' lucas*.log | cut -d: -f1 | sort | uniq`)

for log in ${logs[@]};do
	echo $log
	csv=`cat $log | grep 'Command line' | cut -d: -f4 | awk '{print $3}' | uniq`
#	echo $csv
	error=`grep '(issue #1)' $log | sed 's/(issue #1)//'`
	id=`grep '(FAILED)' $log | uniq |  grep -o  "'.*'" | tr -d "'"`
	echo "$csv:$id $error"
done
