#!/bin/sh

#contact zhengguo.xu@intel.com

mArgDev="--dev"

#these two args are only for the usage to use docker file to configure the docker image
mAgrWinDocker="--win_docker" #for windows host
mAgrDocker="--linux_docker" #for linux host

mProxyFlag="#bellow_for_proxy"
mEnvConf="/etc/environment"
if [ ! -f "$mEnvConf" ]; then
    touch "$mEnvConf"
fi
grep "$mProxyFlag" "$mEnvConf" > /dev/null
if [ ! $? -eq 0 ]; then
    echo "" >> "$mEnvConf"
	echo "$mProxyFlag" >> "$mEnvConf"
    echo 'http_proxy=http://child-prc.intel.com:913' >> "$mEnvConf"
    echo 'https_proxy=https://child-prc.intel.com:913' >> "$mEnvConf"
    echo 'no_proxy=localhost,.intel.com,127.0.0.0/8,172.16.0.0/20,192.168.0.0/16,10.0.0.0/8' >> "$mEnvConf"
fi
export http_proxy=https://child-prc.intel.com:913
export https_proxy=https://child-prc.intel.com:913
#source $mEnvConf  not work

#set dcn for docker container; only for linux host
if [ "$1" = $mAgrDocker -o "$2" = $mAgrDocker ]; then
    mBashrc="/root/.bashrc"
	mDcnFile="/etc/resolv.conf"
	mDockerDcnFlag="#bellow_for_docker_container_to_set_dcn"
    grep "$mDockerDcnFlag" "$mBashrc" > /dev/null
    if [ ! $? -eq 0 ]; then
        echo "" >> "$mBashrc"
        echo "$mDockerDcnFlag" >> "$mBashrc"
		echo "echo \"nameserver 127.0.1.1\" > "$mDcnFile"" >> "$mBashrc"
		echo "echo \"nameserver 10.248.2.5\" >> "$mDcnFile"" >> "$mBashrc"
		echo "echo \"nameserver 10.239.27.228\" >> "$mDcnFile"" >> "$mBashrc"
		echo "echo \"nameserver 172.17.6.9\" >> "$mDcnFile"" >> "$mBashrc"
		echo "echo \"search sh.intel.com\" >> "$mDcnFile"" >> "$mBashrc"
    fi
    echo "nameserver 127.0.1.1" > /etc/resolv.conf
    echo "nameserver 10.248.2.5" >> /etc/resolv.conf
    echo "nameserver 10.239.27.228" >> /etc/resolv.conf
    echo "nameserver 172.17.6.9" >> /etc/resolv.conf
    echo "search sh.intel.com" >> /etc/resolv.conf
fi

arg=Y
if [ ! "$1" = $mAgrDocker -a ! "$2" = $mAgrDocker -a ! "$1" = $mAgrWinDocker -a ! "$2" = $mAgrWinDocker ]; then
    read -p "Install the dependency packets and tools? Y/N: " arg
fi
if [ "$arg" = "" -o "$arg" = "Y" -o "$arg" = "y" ]; then
	apt-get update
	apt-get install -y software-properties-common python-software-properties
    apt-get install -y vim gdb cgdb gcc g++ cmake libpthread-stubs0-dev xutils-dev python samba samba-client samba-common cifs-utils openssh-server git automake libffi-dev curl
    apt-get install -y autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx libgl1-mesa-dev
	apt-get install -y build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache bison #for compiling kmd driver
	apt-get install -y synergy tmux
	add-apt-repository -y ppa:ubuntu-toolchain-r/test
	apt-get update
	apt-get install -y libstdc++6 #for fulsim: libstdc++.so.6: version `GLIBCXX_3.4.22
	apt-get install -y ncurses-dev texinfo  libreadline-dev flex
fi

# "*****************notice: configure your /etc/ssh/sshd_config*************************"
# "*****************port 22*************************************************************"
# "*****************UsePrivilegeSeparation no*******************************************"
# "*****************PasswordAuthentication yes******************************************"
# "*****************AllowUsers youusername**********************************************"

#create folder
mHomeDir=""
if [ ! "$1" = $mAgrDocker -a ! "$2" = $mAgrDocker -a ! "$1" = $mAgrWinDocker -a ! "$2" = $mAgrWinDocker ]; then
    read -p "Please input user's work folder(absolute path please), default: /home/intel >>" homeDir
fi
if [ "$homeDir" = "" ]; then
    mHomeDir="/home/intel"
else
    mHomeDir=$homeDir
fi
#mHomeDir="/home/intel"
mShareDir="$mHomeDir/share"
if [ ! -d "$mHomeDir" ]; then
    mkdir -p "$mHomeDir"
fi
if [ ! -d "$mShareDir" ]; then
    mkdir -p "$mShareDir"
fi

# "*****************notice: configure your /etc/samba/smb.conf*************************"
# "*****************set workgroup=CCR**************************************************"
if [ ! "$1" = $mAgrDocker -a ! "$2" = $mAgrDocker -a ! "$1" = $mAgrWinDocker -a ! "$2" = $mAgrWinDocker ]; then
    chmod 777 "$mHomeDir"
    mSambaFlag="#bellow_for_samba_share"
    mSambaConf="/etc/samba/smb.conf"
    if [ -f "$mSambaConf" ]; then
        grep "$mSambaFlag" "$mSambaConf" > /dev/null
        if [ ! $? -eq 0 ]; then
            echo "" >> "$mSambaConf"
            echo "$mSambaFlag" >> "$mSambaConf"
            echo "[intel]" >> "$mSambaConf"
            echo "    comment = intel" >> "$mSambaConf"
            echo "    path = $mHomeDir" >> "$mSambaConf"
			echo "    available  = yes" >> "$mSambaConf"
            echo "    browseable = yes" >> "$mSambaConf"
			echo "    writable  = yes" >> "$mSambaConf"
			echo "    public  = yes" >> "$mSambaConf"
			
			echo "" >> "$mSambaConf"
			echo "[share]" >> "$mSambaConf"
            echo "    comment = share" >> "$mSambaConf"
            echo "    path = $mHomeDir/share" >> "$mSambaConf"
            echo "    available  = yes" >> "$mSambaConf"
            echo "    browseable = yes" >> "$mSambaConf"
			echo "    writable  = yes" >> "$mSambaConf"
			echo "    public  = yes" >> "$mSambaConf"
			
    		read -p "Input your user name to configure samba: " userName
    		mUserName=""
            if [ "$userName" = "" ]; then
               mUserName="root"
    	    else
    		   mUserName=$username 
    		fi
    		#echo "    valid users = $mUserName" >> "$mSambaConf"
    	    #echo "    force users = $mUserName" >> "$mSambaConf"
    		#echo "    force group = $mUserName" >> "$mSambaConf"
    		echo "enter passwork for samba, same as user's password"
    		smbpasswd -a $mUserName
            /etc/init.d/samba restart
        fi
    fi
fi

#bellow for development env
if [ "$1" = $mArgDev -o "$2" = $mArgDev ]; then
    #check folder
	mWorkDir="$mHomeDir/share/perforce"
	mScripDir="$mHomeDir/share/script"
	if [ ! -d "$mWorkDir" ]; then
	    mkdir -p "$mWorkDir"
	fi
	if [ ! -d "$mScripDir" ]; then
	    mkdir -p "$mScripDir"
	fi
    #configure alians
	mBashrc="/root/.bashrc"
    mAlianFlag="#bellow_for_alians"
	mShowBranchName="#bellow_for_show_branch_name"
    mBackupAlians="aliansBackup"
    mBackupGitConfig="gitConfigBackup"
    mGitConfig=".gitconfig"
    cd "$mScripDir"

	#configure alias
    grep "$mAlianFlag" "$mBashrc" > /dev/null
    if [ ! $? -eq 0 ]; then
        echo "" >> "$mBashrc"
        echo "$mAlianFlag" >> "$mBashrc"
        #cat $mBackupAlians >> "$mBashrc"
		#todo: use echo xxx >> 
		echo "alias cd-zhengg='cd /home/intel/share/zhengg'" >> "$mBashrc"
		echo "alias cd-perforce='cd /home/intel/share/perforce'" >> "$mBashrc"
		echo "alias cd-umd-build='cd /home/intel/share/perforce/gfx_dev_linux/gfx-driver/Source/build_media/'" >> "$mBashrc"
		echo "alias cd-umd-temp-build='cd /home/intel/share/perforce/gfx_dev_linux_temp/gfx-driver/Source/build_media/'" >> "$mBashrc"
		echo "alias cd-lucas-build='cd /home/intel/share/perforce/xuzhengg_xzg_dev_linux_lucas/mainline/build/'" >> "$mBashrc"
		echo "alias cd-build-iHD='cd /home/intel/share/perforce/xuzhengg_xzg_dev_linux/gfx_Development/DEV/DEV_Media/Source/build_media/media_driver/'" >> "$mBashrc"
		echo "alias cd-codechaldump='cd /tmp/codechal_dump/'" >> "$mBashrc"
		echo "alias cmake-umd='cmake ../media/ -DMEDIA_VERSION=2.0.0 -DBUILD_TYPE=release-internal -DCenc_Decode_Supported=yes -DGMM_DYNAMIC_MOCS_TABLE=TRUE -DLIBVA_INSTALL_PATH=/usr/include -DCP_LIBDRM_DIR=/usr/lib/x86_64-linux-gnu'" >> "$mBashrc"
		echo "alias cmake-umd-debug='cmake ../media/ -DMEDIA_VERSION=2.0.0 -DBUILD_TYPE=debug -DCenc_Decode_Supported=yes -DGMM_DYNAMIC_MOCS_TABLE=TRUE -DLIBVA_INSTALL_PATH=/usr/include -DCP_LIBDRM_DIR=/usr/lib/x86_64-linux-gnu'" >> "$mBashrc"
		echo "alias cmake-umd-opencource-code='cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug -DBUILD_TYPE=Debug ../media-driver'" >> "$mBashrc"
		echo "alias cmake-build-gmmlib='cmake -DCMAKE_INSTALL_PREFIX=/usr/ -DCMAKE_BUILD_TYPE=Debug .. && make -j8'" >> "$mBashrc"
		echo "alias build-umd='mv /etc/igfx_user_feature.txt /etc/igfx_user_feature.txt.bak && make -j8 && mv /etc/igfx_user_feature.txt.bak /etc/igfx_user_feature.txt'" >> "$mBashrc"
		echo "alias build-libva='./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu'" >> "$mBashrc"
		echo "alias disable-solo='mv /etc/igfx_user_feature.txt /etc/igfx_user_feature.txt.bak'" >> "$mBashrc"
		echo "alias enable-solo='mv /etc/igfx_user_feature.txt.bak /etc/igfx_user_feature.txt'" >> "$mBashrc"
		echo "alias cp-iHD-to-x86dri='cp media_driver/iHD_drv_video.so /usr/lib/x86_64-linux-gnu/dri/'" >> "$mBashrc"
		echo "alias chown_grp='chown intel . -R && chgrp intel . -R'" >> "$mBashrc"
		echo "" >> "$mBashrc"
    fi
	
	#configure auto check git branch name
	grep "$mShowBranchName" "$mBashrc" > /dev/null
    if [ ! $? -eq 0 ]; then
	    echo "" >> "$mBashrc"
        echo "$mShowBranchName" >> "$mBashrc"
		echo "function git_branch {" >> "$mBashrc"
		####echo "branch="`git branch 2>/dev/null | grep "^\*" | sed -e "s/^\*\ //"`"" >> "$mBashrc"
		echo "branch=\"\`git branch 2>/dev/null | grep \"^\\*\" | sed -e \"s/^\\*\\ //\"\`\"" >> "$mBashrc"
		####echo "if [ "${branch}" != "" ];then" >> "$mBashrc"
		echo "if [ \"\${branch}\" != \"\" ];then" >> "$mBashrc"
		####echo "if [ "${branch}" = "(no branch)" ];then" >> "$mBashrc"
		echo "if [ \"\${branch}\" = \"(no branch)\" ];then" >> "$mBashrc"
		####echo "branch="(`git rev-parse --short HEAD`...)"" >> "$mBashrc"
		echo "branch=\"(\`git rev-parse --short HEAD\`...)\"" >> "$mBashrc"
		echo "fi" >> "$mBashrc"
		####echo "echo " ($branch)"" >> "$mBashrc"
		echo "echo \" (\$branch)\"" >> "$mBashrc"
		echo "fi" >> "$mBashrc"
		echo "}" >> "$mBashrc"
		####echo "export PS1='\u@\h \[\033[01;36m\]\W\[\033[01;32m\]$(git_branch)\[\033[00m\] \$ '" >> "$mBashrc"
		echo "export PS1='\u@\h \[\033[01;36m\]\W\[\033[01;32m\]\$(git_branch)\[\033[00m\] \$ '" >> "$mBashrc"
	fi

	#configure gitconfig   
    cd "$mHomeDir"
    if [ ! -f "$mGitConfig" ]; then
       touch "$mGitConfig" 
    fi

	#todo: use git config --global ...
	if [ ! "$1" = $mAgrDocker -a ! "$2" = $mAgrDocker -a ! "$1" = $mAgrWinDocker -a ! "$2" = $mAgrWinDocker ]; then
	    echo "Please input your git user name: "
	    read gitUserName
	    git config --global user.name $gitUserName
	    echo "Please input yout git user email, must be your intel email address if you want to configure devtool as well: "
	    read gitUserEmail
	    git config --global user.email $gitUserEmail
	fi
	git config --global alias.st status
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit
	git config --global alias.pl "pull --rebase"
	git config --global alias.ps push
	git config --global alias.mg "merge --no-ff"
	git config --global alias.mt mergetool
	git config --global alias.dt difftool
	git config --global alias.lol "log --pretty=oneline"
	git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
	git config --global alias.lh "log --pretty=\"%C(yellow)%h%Creset -%C(red)%d%C(white) %s %C(bold blue)(%cd) %Cblue<%an>\" --graph --date=short --branches=* --date-order"
	git config --global core.autocrlf input
	git config --global core.fileMode false
	git config --global core.editor vim
	git config --global color.diff auto
	git config --global color.branch auto
	git config --global color.ui true
	git config --global push.default upstream
	git config --global diff.tool vimdiff
	git config --global difftool.prompt false
	git config --global merge.tool p4merge
	##git config --global mergetool.p4merge.cmd "p4merge "$BASE" "$LOCAL" "$REMOTE" "$MERGED""
	git config --global mergetool.p4merge.keepTemporaries false
	git config --global mergetool.p4merge.trustExitCode false
	git config --global mergetool.p4merge.keepBackup false
	git config --global mergetool.prompt false
	git config --global credential.helper store

	#configure driver path env
	mDriverEnvFlag="#below_for_iHD_driver_env"
    mProfilef="/etc/profile"
    mDriverName="export LIBVA_DRIVER_NAME=iHD"
    mDriverPath="export LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri"
    grep "$mDriverEnvFlag" "$mProfilef" > /dev/null
    if [ ! $? -eq 0 ]; then
        echo "" >> "$mProfilef"
        echo "$mDriverEnvFlag" >> "$mProfilef"
        echo "$mDriverName" >> "$mProfilef"
        echo "$mDriverPath" >> "$mProfilef"
    fi
	grep "$mDriverEnvFlag" "$mBashrc" > /dev/null
    if [ ! $? -eq 0 ]; then
        echo "" >> "$mBashrc"
        echo "$mDriverEnvFlag" >> "$mBashrc"
        echo "$mDriverName" >> "$mBashrc"
        echo "$mDriverPath" >> "$mBashrc"
    fi
	
	if [ ! "$1" = $mAgrDocker -a ! "$2" = $mAgrDocker -a ! "$1" = $mAgrWinDocker -a ! "$2" = $mAgrWinDocker ]; then
	    #configure dev tool and source code
        echo "*****************notice: configure devtool*************************"
	    mDtLog="/tmp/dtLog"
	    if [ ! -f "$mDtLog" ]; then
	        touch $mDtLog
	    fi
        curl -sSL https://github.intel.com/raw/vpgsw/devtool/master/scripts/linux_install.sh | bash
		#after dt install is finished, must close terminal and re-open it to make dt variable work
		#todo: to set the env variable for dt here instead of re-open?
        dt self-update
	    dt workstation check > "$mDtLog"
	    grep "no" "$mDtLog" > /dev/null
	    if [ $? -eq 0 ]; then
	      dt workstation setup  
	    fi
	    
	    dt workstation check > "$mDtLog"
	    grep "no" "$mDtLog" > /dev/null
	    if [ ! $? -eq 0 ]; then
	        mDriverDir="$mWorkDir/gfx_work1"
            if [ ! -d "$mDriverDir" ]; then
                mkdir -p "$mDriverDir"
                cd "$mDriverDir"
                dt workspace init gfx-driver
            fi 
            if [ ! -d "$mWorkDir/libva" ]; then
                cd "$mWorkDir"
                git clone https://github.com/intel/libva
            fi
	    fi
	fi
fi

#todo:change the folder permission
cd $mHomeDir
chown $mUserName . -R
chgrp $mUserName . -R

echo '\033[33m*****************notice: configure your /etc/ssh/sshd_config as bellow if you want to use ssh to login this device*************************\033[0m'
echo '\033[33m*****************port 22*************************************************************\033[0m'
echo '\033[33m*****************UsePrivilegeSeparation no*******************************************\033[0m'
echo '\033[33m*****************PasswordAuthentication yes******************************************\033[0m'
echo '\033[33m*****************AllowUsers youusername**********************************************\033[0m'
echo '\033[33m**************************************************************end***************************************************************************\033[0m'
echo '\033[33m*****************notice: configure your /etc/samba/smb.conf as bellow if you want to access to share folder /home/intel*********************\033[0m'
echo '\033[33m*****************set workgroup=CCR**************************************************\033[0m'
echo '\033[33m**************************************************************end***************************************************************************\033[0m'
