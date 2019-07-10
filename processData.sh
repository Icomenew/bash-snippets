#!/bin/bash

ResultHEVC=$PWD/result.csv
rm -frv *.par scenarios
CaseName=(`ls -d *.[0-3]`)
echo "casename,PSNR" | tee ${ResultHEVC} 
for name in ${CaseName[@]};do
       cd $name
       PSNR=`cat *0.csv |grep "avg_metric=PSNR" |cut -c 19-26`
       BitSize=`ls -l *bin|cut -d " " -f 5`
#       ISliceQP=`cat ../../scenarios/FEI_HEVC_CQP_Quality.csv| grep "${TempName}" | cut -d, -f $((SubNum+12)) | tr -d \"`
#	PSliceQP=`cat ../../scenarios/FEI_HEVC_CQP_Quality.csv| grep "${TempName}" | cut -d, -f $((SubNum+16)) | tr -d \"`
#	BSliceQP=`cat ../../scenarios/FEI_HEVC_CQP_Quality.csv| grep "${TempName}" | cut -d, -f $((SubNum+20)) | tr -d \"`
       RealName=`echo $name |cut -d "." -f -9`
       echo "${RealName},${ISliceQP},${PSliceQP},${BSliceQP},${BitSize},${PSNR}" |  tee -a ${ResultHEVC}
       cd ../
done
