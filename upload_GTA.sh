#!/bin/bash


#scenario
./gta-asset push gfx-media-assets-fm/PROD/scenario/transcode SKL 18.7 ./GTA-Scenarios/CI-SKL_18.6/ --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory
./gta-asset push gfx-media-assets-fm/PROD/scenario/transcode BDW 14.1 ./123/ --base 14.0 --merge --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory
#MSDK
./gta-asset push gfx-sandbox-fm/PROD/testapps test_msdk b221.1 ./MSDK_manual-dev-media-20773/ --root-url https://gfx-assets.fm.intel.com/artifactory
#Lucas
./gta-asset push gfx-sandbox-fm/PROD/testapps/test_lucas Ubuntu Lucas.01.05.224.0622-rel-ww23.4 ./GTA-Scenarios/Lucas.01.05.224.0622-rel-ww23.4 --root-url https://gfx-assets.fm.intel.com/artifactory
#yuv
./gta-asset push gfx-media-assets-fm/PROD/content/RAW YUV 143 ./123/ --base 142 --merge --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory




#experiment:
./gta-asset push gfx-sandbox-fm/PROD/testapps CentOS_lucas 1.0 /***local_path***/ --no-archive(default archive) --root-url https://gfx-assets.fm.intel.com/artifactory

#local lucas
./gta-asset push gfx-sandbox-fm/PROD/testapps CentOS_lucas 1.0 /home/intel/work/GTA/Lucas.01.05.132.0468-rel-ww34.5-CentOS_7_Mainline --root-url https://gfx-assets.fm.intel.com/artifactory --user hanlongx --password 'nibvs65@'

#MSDK
./gta-asset push gfx-media-assets-fm/PROD/testapps/MSDK MSDK_CentOS b642 ./mediasdk_WW06.4_b642 --root-url https://gfx-assets.fm.intel.com/artifactory

#csv files
./gta-asset push gfx-sandbox-fm/PROD/scenario transcode 1.4 /opt/local/diff_content/PROD/scenario/CSV --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory

#decode jpeg reference
./gta-asset push gfx-sandbox-fm/PROD/reference/decode jpeg 1.0 /opt/remote/task/content/From_Android/decode/jpeg/reference --root-url https://gfx-assets.fm.intel.com/artifactory

#for yuv upddate
./gta-asset push gfx-sandbox-fm/PROD/content/RAW YUV 3.0 /opt/local/yuv-0909/ --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory

#encode mjpeg content
./gta-asset push gfx-sandbox-fm/PROD/content/EJPEG Internal 1.0 /opt/local/content/encode_mjpeg --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory

#vpp blending/combination content
./gta-asset push gfx-sandbox-fm/PROD/content/VPP Blending 1.0 /opt/remote/task/content/From_Android/vp/content_skl/blending --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory
./gta-asset push gfx-sandbox-fm/PROD/content/VPP Combination 1.0 /opt/remote/task/content/From_Android/vp/content_skl/combination --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory

#FEI quality
./gta-asset push gfx-sandbox-sh/PROD/testapps FEI_LINUX 1.0 ./FEI-CI --user hanlongx --password 'nibvs65@'

#FEI ASG
./gta-asset push gfx-sandbox-sh/PROD/testapps FEI_LINUX 1.0 ./FEI-CI --user hanlongx --password 'nibvs65@'

#FEI-function
./gta-asset push gfx-sandbox-fm/PROD/testapps FEI_function 5.0 ./FEI-function-upload --base 4.0 --merge --no-archive --root-url https://gfx-assets.fm.intel.com/artifactory --user hanlongx --password 'nibvs65@'
