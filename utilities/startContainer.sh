#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! startContainer.sh
#!
#! Start up an appropriate singularity / docker container and setupATLAS
#!
#! Usage:
#!     startContainer.sh -h
#!
#! History:
#!    11Dec17: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=startContainer.sh


alrb_fn_startContainerHelp()
{
    \cat <<EOF 

    $alrb_progname [options] 

    By default, Singularity is run except for MacOSX where Docker is run.
      You can override this with the options below but this is not guaranteed.

    Options (to override defaults) are:
     -c --container=STRING  Container name (can be one to guess of path to one)
     -h --help              Print this help message
     -q --quiet             Print no output     

    env variables available to set:
      ALRB_CONT_OPTS        additional options to pass to singularity or docker
                             eg (singularity [opt] )
      ALRB_CONT_CMDOPTS     additional options to pass to singularity or docker
                             commands (eg singularity exec [opt] )
      ALRB_CONT_SWTYPE      container software (singularity/docker) to use 
                             default: docker (MacOSX), singularity (others)
      ALRB_CONT_PRESETUP    pre setupATLAS commands to run 
      ALRB_CONT_POSTSETUP   post setupATLAS commands to run
      ALRB_CONT_RUNPAYLOAD  run these commands and exit
      ALRB_CONT_CONDUCT     comma delimited keywords affecting bahaviour

EOF

    return 0
}


alrb_fn_cleanup()
{
    if [ ! -z $ALRB_CONT_PIPEDIRHOST ]; then
	\rm -rf $ALRB_CONT_PIPEDIRHOST
    fi
    if [ "$alrb_contDummyHome" != "" ]; then
	\rm -rf $alrb_contDummyHome
    fi
    if [ "$alrb_pipeExecutor" != "" ]; then
	kill -9 $alrb_pipeExecutor > /dev/null 2>&1
    fi

    return 0
}


alrb_fn_saveEnvs()
{

# in certain circumstances, save the proxy to another dir if it exists
    if [ ! -z $X509_USER_PROXY ]; then
	\echo $X509_USER_PROXY | \grep -E "^/tmp" 2>&1 > /dev/null
	if [ $? -ne 0 ]; then
	    alrb_copyProxy="YES"
	fi
	if [[ "$alrb_copyProxy" = "YES" ]] && [[ -e $X509_USER_PROXY ]]; then
	    \cp $X509_USER_PROXY $alrb_contDummyHome/
	    local alrb_tmpVal=`basename $X509_USER_PROXY`
	    X509_USER_PROXY="$ALRB_CONT_DUMMYHOME/$alrb_tmpVal"
	fi    
    fi

    if [ "$alrb_containerSkipCvmfs" = "YES" ]; then
	export ALRB_CONT_HOSTALRBDIR=$ATLAS_LOCAL_ROOT_BASE
    fi

    alrb_envFile="$alrb_contDummyHome/envs"
    touch $alrb_envFile
    alrb_tmpVal='env | \grep 
 -e "USER="
 -e "DISPLAY="
 -e "SITE_NAME="
 -e "PANDA_SITE_NAME="
 -e "SSH_AUTH_SOCK="
 -e "ATLAS_SITE_NAME="
 -e "X509_USER_PROXY="
 -e "RUCIO_ACCOUNT="
 -e "FRONTIER_SERVER="
 -e "ALRB_[[:alnum:]]*Version="
 -e "ALRB_menuFmtSkip="
 -e "ALRB_CONT_[[:alnum:]]*="
 -e "ALRB_localConfigDir="
 -e "ALRB_testPath="
| \cut -f 1 -d "="
'

    if [[ "$ALRB_SHELL" = "bash" ]] || [[ "$ALRB_SHELL" = "zsh" ]]; then
	alrb_envStr1="export"
	alrb_envStr2="="
    else
	alrb_envStr1="setenv"
	alrb_envStr2=" "
    fi
    for alrb_item in `eval $alrb_tmpVal`; do
	\echo $alrb_envStr1 ${alrb_item}${alrb_envStr2}\"${!alrb_item}\" >> $alrb_envFile
    done

    if [ "$alrb_cont_display" != "" ]; then
	\echo "$alrb_envStr1 DISPLAY${alrb_envStr2}\"$alrb_cont_display\"" >> $alrb_envFile
    fi
    \echo "$alrb_envStr1 ALRB_CONT_HOSTOS${alrb_envStr2}\"$ALRB_OSTYPE\"" >> $alrb_envFile

    return 0
}


alrb_fn_createDummyHome()
{

    alrb_contDummyHome=`\mktemp -d $alrb_contWorkdir/home.XXXXXX`
    if [ $? -ne 0 ]; then
	return 64
    fi
    \mkdir -p $alrb_contDummyHome/ATLASLocalRootBase

    \cat << EOF >> $alrb_contDummyHome/checkArch.sh
#! /bin/bash

let alrb_installedTools=\`\grep -e "\$ATLAS_LOCAL_ROOT_ARCH/" \$ATLAS_LOCAL_ROOT_BASE/logDir/installed | wc -l\`
if [ \$alrb_installedTools -eq 0 ]; then
    \echo "Error: no tools available for this platform \$ATLAS_LOCAL_ROOT_ARCH"
    \echo "       The host platform was $ATLAS_LOCAL_ROOT_ARCH ($ALRB_OSTYPE)"
    \echo "       Host had ALRB on $ATLAS_LOCAL_ROOT_BASE"
    \echo "       Install ALRB tools for \$ATLAS_LOCAL_ROOT_ARCH (\$ALRB_OSTYPE) on host."
    exit 64
fi

exit 0
EOF
    chmod +x $alrb_contDummyHome/checkArch.sh 

    if [ "$ALRB_SHELL" = "bash" ]; then
	touch $alrb_contDummyHome/.bashrc
	if [ ! -z "$ALRB_CONT_RUNPAYLOAD" ]; then
	    \echo "#! /bin/bash" > $alrb_contDummyHome/.bashrc
	    chmod +x $alrb_contDummyHome/.bashrc
	    alrb_cont_payload="$ALRB_CONT_DUMMYHOME/.bashrc"
	fi
	\cat <<EOF >> $alrb_contDummyHome/.bashrc
source $ALRB_CONT_DUMMYHOME/envs

if [ -e /etc/profile.d/container-date.sh ]; then
  source /etc/profile.d/container-date.sh
fi

if [ ! -z \$ALRB_CONT_REALHOME ]; then
    export HOME=\$ALRB_CONT_REALHOME
    if [[ -d \$ALRB_CONT_REALHOME/.globus ]] && [[ ! -e \$ALRB_CONT_DUMMYHOME/.globus ]]; then
	ln -s \$ALRB_CONT_REALHOME/.globus  \$ALRB_CONT_DUMMYHOME/
    fi
    if [ ! -e \$ALRB_CONT_DUMMYHOME/.ssh ]; then
      if [ -d \$ALRB_CONT_REALHOME/.ssh.container ]; then
        ln -s \$ALRB_CONT_REALHOME/.ssh.container \$ALRB_CONT_DUMMYHOME/.ssh
      else
        mkdir -p \$ALRB_CONT_REALHOME/.ssh
        ln -s \$ALRB_CONT_REALHOME/.ssh  \$ALRB_CONT_DUMMYHOME/
      fi
    fi
fi

if [ ! -z \$ALRB_CONT_REALTMPDIR ]; then
    export TMPDIR=\$ALRB_CONT_REALTMPDIR
fi

# workaround for ssh keys for MacOS
if [ "\$ALRB_CONT_HOSTOS" = "MacOSX" ]; then
  eval \`ssh-agent -s | \sed -e 's/^echo/#echo/'\`
fi

if [ -e \$HOME/.bashrc.container ]; then
  source \$HOME/.bashrc.container
fi

cd \$ALRB_CONT_CHANGEPWD

if [ ! -z "\$ALRB_CONT_PRESETUP" ]; then
    eval \$ALRB_CONT_PRESETUP
fi

if [ ! -z \$ALRB_CONT_HOSTALRBDIR ]; then
  export ATLAS_LOCAL_ROOT_BASE=\$ALRB_CONT_DUMMYALRB
elif [ -z \$ATLAS_LOCAL_ROOT_BASE ]; then
  export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
fi
source \$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh $alrb_QuietOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
$ALRB_CONT_DUMMYHOME/checkArch.sh
if [ \$? -ne 0 ]; then
  exit 64
fi
if [[ "\$ALRB_noGridMW" != "YES" ]] && [[ -d \$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates ]] ; then
  export X509_CERT_DIR=\$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
fi

# temporary solution for singularity missing this
\grep -e "CERN\.CH" /etc/krb5.conf 2>&1 > /dev/null
if [ \$? -ne 0 ]; then
  export KRB5_CONFIG=\$ATLAS_LOCAL_ROOT_BASE/user/krb5.conf
fi

if [ ! -z "\$ALRB_CONT_BATCHPATH" ]; then
  eval \$ALRB_CONT_BATCHPATH
fi

appendPath PATH \$ATLAS_LOCAL_ROOT_BASE/containerUtils
 
if [ ! -z "\$ALRB_CONT_POSTSETUP" ]; then
    eval \$ALRB_CONT_POSTSETUP
fi

if [ ! -z "\$ALRB_CONT_RUNPAYLOAD" ]; then
  eval \$ALRB_CONT_RUNPAYLOAD
  exit \$?
fi

EOF

    elif [ "$ALRB_SHELL" = "zsh" ]; then
	touch $alrb_contDummyHome/.zshrc
	if [ ! -z "$ALRB_CONT_RUNPAYLOAD" ]; then
	    \echo "#! /bin/zsh" > $alrb_contDummyHome/.zshrc
	    chmod +x $alrb_contDummyHome/.zshrc
	    alrb_cont_payload="$ALRB_CONT_DUMMYHOME/.zshrc"
	fi
	\cat <<EOF >> $alrb_contDummyHome/.zshrc

source $ALRB_CONT_DUMMYHOME/envs

if [ -e /etc/profile.d/container-date.sh ]; then
  source /etc/profile.d/container-date.sh
fi

if [ ! -z \$ALRB_CONT_REALHOME ]; then
    export HOME=\$ALRB_CONT_REALHOME
    if [[ -d \$ALRB_CONT_REALHOME/.globus ]] && [[ ! -e \$ALRB_CONT_DUMMYHOME/.globus ]]; then
	ln -s \$ALRB_CONT_REALHOME/.globus  \$ALRB_CONT_DUMMYHOME/
    fi
    if [ ! -e \$ALRB_CONT_DUMMYHOME/.ssh ]; then
      if [ -d \$ALRB_CONT_REALHOME/.ssh.container ]; then
        ln -s \$ALRB_CONT_REALHOME/.ssh.container \$ALRB_CONT_DUMMYHOME/.ssh
      else
        mkdir -p \$ALRB_CONT_REALHOME/.ssh
        ln -s \$ALRB_CONT_REALHOME/.ssh  \$ALRB_CONT_DUMMYHOME/
      fi
    fi
fi

if [ ! -z \$ALRB_CONT_REALTMPDIR ]; then
    export TMPDIR=\$ALRB_CONT_REALTMPDIR
fi

# workaround for ssh keys for MacOS
if [ "\$ALRB_CONT_HOSTOS" = "MacOSX" ]; then
  eval \`ssh-agent -s | \sed -e 's/^echo/#echo/'\`
fi

if [ -e \$HOME/.zshrc.container ]; then
  source \$HOME/.zshrc.container
fi

cd \$ALRB_CONT_CHANGEPWD

if [ ! -z "\$ALRB_CONT_PRESETUP" ]; then
    eval \$ALRB_CONT_PRESETUP
fi

if [ ! -z \$ALRB_CONT_HOSTALRBDIR ]; then
  export ATLAS_LOCAL_ROOT_BASE=\$ALRB_CONT_DUMMYALRB
elif [ -z \$ATLAS_LOCAL_ROOT_BASE ]; then
  export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
fi
source \$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh $alrb_QuietOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
$ALRB_CONT_DUMMYHOME/checkArch.sh
if [ \$? -ne 0 ]; then
  exit 64
fi
if [[ "\$ALRB_noGridMW" != "YES" ]] && [[ -d \$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates ]] ; then
  export X509_CERT_DIR=\$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
fi

# temporary solution for singularity missing this
\grep -e "CERN\.CH" /etc/krb5.conf 2>&1 > /dev/null
if [ \$? -ne 0 ]; then
  export KRB5_CONFIG=\$ATLAS_LOCAL_ROOT_BASE/user/krb5.conf
fi

if [ ! -z "\$ALRB_CONT_BATCHPATH" ]; then
  eval \$ALRB_CONT_BATCHPATH
fi

appendPath PATH \$ATLAS_LOCAL_ROOT_BASE/containerUtils
 
if [ ! -z "\$ALRB_CONT_POSTSETUP" ]; then
    eval \$ALRB_CONT_POSTSETUP
fi

if [ ! -z "\$ALRB_CONT_RUNPAYLOAD" ]; then
  eval \$ALRB_CONT_RUNPAYLOAD
  exit \$?
fi

EOF

    elif [ "$ALRB_SHELL" = "tcsh" ]; then
	touch $alrb_contDummyHome/.cshrc
	if [ ! -z "$ALRB_CONT_RUNPAYLOAD" ]; then
	    \echo "#! /bin/tcsh" > $alrb_contDummyHome/.cshrc
	    chmod +x $alrb_contDummyHome/.cshrc
	    alrb_cont_payload="/bin/$ALRB_SHELL -c exit"
	fi
	\cat <<EOF >> $alrb_contDummyHome/.cshrc

source $ALRB_CONT_DUMMYHOME/envs

if ( -e /etc/profile.d/container-date.sh ) then
  source /etc/profile.d/container-date.csh
endif

if ( \$?ALRB_CONT_REALHOME ) then
    setenv HOME \$ALRB_CONT_REALHOME
    if (( -d \$ALRB_CONT_REALHOME/.globus ) && ( ! -e \$ALRB_CONT_DUMMYHOME/.globus )) then
	ln -s \$ALRB_CONT_REALHOME/.globus  \$ALRB_CONT_DUMMYHOME/
    endif
    if ( ! -e \$ALRB_CONT_DUMMYHOME/.ssh ) then
      if ( -d \$ALRB_CONT_REALHOME/.ssh.container ) then
        ln -s \$ALRB_CONT_REALHOME/.ssh.container \$ALRB_CONT_DUMMYHOME/.ssh
      else
        mkdir -p \$ALRB_CONT_REALHOME/.ssh
        ln -s \$ALRB_CONT_REALHOME/.ssh  \$ALRB_CONT_DUMMYHOME/
      endif
    endif
endif

if ( \$?ALRB_CONT_REALTMPDIR ) then
    setenv TMPDIR \$ALRB_CONT_REALTMPDIR
endif

# workaround for ssh keys for MacOS
if ( "\$ALRB_CONT_HOSTOS" == "MacOSX" ) then
  eval \`ssh-agent -c | \sed -e 's/^echo/#echo/'\`
endif

if ( -e \$HOME/.cshrc.container ) then
  source \$HOME/.cshrc.container
endif

cd \$ALRB_CONT_CHANGEPWD

if ( "\$?ALRB_CONT_PRESETUP" ) then
    eval \$ALRB_CONT_PRESETUP
endif


if ( \$?ALRB_CONT_HOSTALRBDIR ) then
  setenv ATLAS_LOCAL_ROOT_BASE \$ALRB_CONT_DUMMYALRB
else if ( ! \$?ATLAS_LOCAL_ROOT_BASE ) then
  setenv ATLAS_LOCAL_ROOT_BASE /cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
endif
source \$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.csh $alrb_QuietOpt
if ( \$? != 0 ) then
  exit 64
endif
$ALRB_CONT_DUMMYHOME/checkArch.sh
if ( \$? != 0 ) then
  exit 64
endif

if ( -d \$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates ) then
  if ( ! \$?ALRB_noGridMW ) then
    setenv X509_CERT_DIR \$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
  else 
    if ( "\$ALRB_noGridMW" != "YES" ) then
      setenv X509_CERT_DIR \$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
    endif  
  endif
endif

# temporary solution for singularity missing this
set alrb_tmpVal=\`\grep -e "CERN\.CH" /etc/krb5.conf\`
if ( \$? != 0 ) then
  setenv KRB5_CONFIG \$ATLAS_LOCAL_ROOT_BASE/user/krb5.conf
endif
unset alrb_tmpVal

if ( "\$?ALRB_CONT_POSTSETUP" ) then
    eval \$ALRB_CONT_POSTSETUP
endif

if ( "\$?ALRB_CONT_RUNPAYLOAD" ) then
  eval \$ALRB_CONT_RUNPAYLOAD
  exit \$?
endif

EOF

    else
	\echo "Error unknown shell type $ALRB_SHELL" 1>&2
	return 64
    fi

    return 0
}


alrb_fn_parseContainerOptions()
{
    alrb_containerCandidate=""
    alrb_imageType=""
    alrb_containerSkipCvmfs=""
    alrb_containerBatch=""

    local alrb_item
    local alrb_itemLower
    for alrb_item in $(\echo $alrb_guessContainer | \sed "s/+/ /g"); do
	alrb_itemLower=`\echo $alrb_item | tr '[:upper:]' '[:lower:]'`
	case "$alrb_itemLower" in
            images)
		alrb_imageType="images"
		;;         
            nocvmfs)
		alrb_containerSkipCvmfs="YES"
		;;
            batch)
		alrb_containerBatch="YES"
		;;
            *)
		alrb_containerCandidate="$alrb_item"
		;;
	esac
    done

    return 0
}


alrb_fn_setSingularityContainer()
{
    local alrb_tmpVal

    alrb_fn_parseContainerOptions

    export ALRB_CONT_DUMMYHOME="/alrb"
    if [ "$alrb_containerSkipCvmfs" = "YES" ]; then
	export ALRB_CONT_DUMMYALRB="/alrb/ATLASLocalRootBase"
    fi

    alrb_container=$alrb_containerCandidate

    if [ "$alrb_imageType" = "images" ]; then
	local alrb_singRepo="$ALRB_cvmfs_repo/containers/images/singularity"
	local alrb_imageSuffix=".img"
    else
	local alrb_singRepo="$ALRB_cvmfs_repo/containers/fs/singularity"
	local alrb_imageSuffix=""
    fi
    
    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "slc5" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="$alrb_singRepo/x86_64-slc5${alrb_imageSuffix}"
	return 0
    fi
    
    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "sl6" -e "slc6" -e "centos6" -e "rhel6" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="$alrb_singRepo/x86_64-centos6${alrb_imageSuffix}"
	return 0
    fi
    
    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "sl7" -e "slc7" -e "centos7" -e "rhel7" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="$alrb_singRepo/x86_64-centos7${alrb_imageSuffix}"
	return 0
    fi
    
    return 0
}


alrb_fn_setDockerContainer()
{
    local alrb_tmpVal

    alrb_fn_parseContainerOptions
    alrb_containerCandidate=`\echo $alrb_containerCandidate | \sed -e 's|docker://||'`

    export ALRB_CONT_DUMMYHOME="/alrb/home"
    if [ "$alrb_containerSkipCvmfs" = "YES" ]; then
	export ALRB_CONT_DUMMYALRB="/alrb/ATLASLocalRootBase"
    fi

    alrb_container="$alrb_containerCandidate"

    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "slc5" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="atlasadc/atlas-grid-slc5"
	return 0
    fi
    
    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "sl6" -e "slc6" -e "centos6" -e "rhel6" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="atlasadc/atlas-grid-centos6"
	return 0
    fi
    
    alrb_tmpVal=`\echo $alrb_containerCandidate | \grep -i -e "sl7" -e "slc7" -e "centos7" -e "rhel7" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_container="atlasadc/atlas-grid-centos7"
	return 0
    fi
    
    return 0
}


alrb_fn_buildDocker()
{

    local alrb_dockerContDir="$alrb_contWorkdir/files/$alrb_container"
    mkdir -p $alrb_dockerContDir

    \cat << EOF > ${alrb_dockerContDir}/dockerfile
FROM $alrb_container

RUN adduser -M -d $ALRB_CONT_DUMMYHOME -u $alrb_uid -s /bin/$ALRB_SHELL $alrb_whoami

RUN mkdir -p $ALRB_CONT_DUMMYHOME $ALRB_CONT_DUMMYALRB /srv /scratch

USER $alrb_whoami

CMD [ "/bin/$ALRB_SHELL" ]

EOF

    docker build --pull $alrb_QuietOpt -t $alrb_containerName ${alrb_dockerContDir}
    return $?
}


alrb_fn_X11Support()
{    

    if [ "$ALRB_OSTYPE" = "MacOSX" ]; then	
	if [ "$alrb_Quiet" = "NO" ]; then
	    \echo "MacOS X: Wait for XQuartz to start"
	fi
	open -a XQuartz
	if [ $? -ne 0 ]; then
	    return 64
	fi
	osascript -e 'activate application "Terminal"'

	local alrb_idx
	for alrb_idx in `seq 1 10`; do
	    sleep 1
	    alrb_result=`ps -eo command | \grep -e "^/Applications/Utilities/XQuartz.app/Contents/MacOS/X11.bin"`
	    if [ $? -eq 0 ]; then
		break
	    fi    
        done    

	alrb_cont_display="docker.for.mac.localhost:0"

	xhost + localhost
    fi

    return 0

}


alrb_fn_joinRunningDocker()
{

    local let alrb_rc=0    
    local alrb_result
    alrb_result=`\echo $ALRB_CONT_CONDUCT | \grep -e ",dockerJoin,"`
    if [ $? -eq 0 ]; then
	alrb_result=`docker ps -f ancestor=$alrb_containerName -f status=running --format "{{.Names}}" | env LC=ALL \sort | \tail -n 1`
	if [[ $? -eq 0 ]] && [[ "$alrb_result" != "" ]]; then
	    \echo "Docker: Join already running $alrb_result"
	    \echo "        Remember that if you exit that container, this session will die"
	    alrb_joinedRunningDocker="YES"
	    docker exec -it $alrb_result /bin/$ALRB_SHELL
	    alrb_rc=$?
	fi
    fi

    return $alrb_rc
}


alrb_fn_dockerOptsParser()
{
# nothing to do at the moment for docker ...
    return 0
}

    
alrb_fn_singularityOptsParser()
{

    if [ ! -z "$ALRB_CONT_CMDOPTS" ]; then
	eval set -- "$ALRB_CONT_CMDOPTS"
	
	while [ $# -gt 0 ]; do
	    case $1 in
		-c|--contain|-C|--containall)
		    alrb_containMinimal="YES"
		    alrb_copyProxy="YES"
		    shift
		    ;;
		--pwd)
		    alrb_setContainerPwd="$2"
		    shift
		    ;;
		--)
		    shift
		    break
		    ;;
		*)
		    shift
		    ;;
	    esac
	done
    fi
    
    return 0
    
}


alrb_fn_singularityGetPathLookup()
{

    ALRB_CONT_SED2HOST=""
    ALRB_CONT_SED2CONT=""

    if [ ! -z "$ALRB_CONT_STARTCMD" ]; then
	eval set -- "$ALRB_CONT_STARTCMD"
	
	while [ $# -gt 0 ]; do
	    case $1 in
		-B|--bind|-H|--home)
		    local alrb_tmp1=`\echo $2 | \cut -f 1 -d ":"`
		    local alrb_tmp2=`\echo $2 | \cut -f 2 -d ":"`
		    if [ "$alrb_tmp1" != "$alrb_tmp2" ]; then
			ALRB_CONT_SED2HOST="$ALRB_CONT_SED2HOST -e 's|$alrb_tmp2|$alrb_tmp1|g'"
			ALRB_CONT_SED2CONT="$ALRB_CONT_SED2CONT -e 's|$alrb_tmp1|$alrb_tmp2|g'"
		    fi
		    shift 2
		    ;;
		--)
		    shift
		    break
		    ;;
		*)
		    shift
		    ;;
	    esac
	done
    fi

    if [ "$ALRB_CONT_SED2HOST" != "" ]; then
	export ALRB_CONT_SED2HOST
    fi
    if [ "$ALRB_CONT_SED2CONT" != "" ]; then
	export ALRB_CONT_SED2CONT
    fi
    
    return 0    
}


alrb_fn_dockerGetPathLookup()
{

    ALRB_CONT_SED2HOST=""
    ALRB_CONT_SED2CONT=""

    if [ ! -z "$ALRB_CONT_STARTCMD" ]; then
	eval set -- "$ALRB_CONT_STARTCMD"
	
	while [ $# -gt 0 ]; do
	    case $1 in
		-v|--volume)
		    local alrb_tmp1=`\echo $2 | \cut -f 1 -d ":"`
		    local alrb_tmp2=`\echo $2 | \cut -f 2 -d ":"`
		    if [ "$alrb_tmp1" != "$alrb_tmp2" ]; then
			ALRB_CONT_SED2HOST="$ALRB_CONT_SED2HOST -e 's|$alrb_tmp2|$alrb_tmp1|g'"
			ALRB_CONT_SED2CONT="$ALRB_CONT_SED2CONT -e 's|$alrb_tmp1|$alrb_tmp2|g'"
		    fi
		    shift 2
		    ;;
		--)
		    shift
		    break
		    ;;
		*)
		    shift
		    ;;
	    esac
	done
    fi

    if [ "$ALRB_CONT_SED2HOST" != "" ]; then
	export ALRB_CONT_SED2HOST
    fi
    if [ "$ALRB_CONT_SED2CONT" != "" ]; then
	export ALRB_CONT_SED2CONT
    fi
    
    return 0    
}


alrb_fn_BatchInterface()
{
    ALRB_CONT_BATCHPATH=""
    if [ "$alrb_containerBatch" = "YES" ]; then
	which bsub > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    ALRB_CONT_BATCHPATH="$ALRB_CONT_BATCHPATH appendPath PATH \\\$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/lsf;"
	fi
	which condor_submit > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    ALRB_CONT_BATCHPATH="$ALRB_CONT_BATCHPATH appendPath PATH \\\$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/condor;"
	fi
	which sbatch > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    ALRB_CONT_BATCHPATH="$ALRB_CONT_BATCHPATH appendPath PATH \\\$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/slurm;"
	fi
    fi

    if [ "$ALRB_CONT_BATCHPATH" != "" ]; then

	alrb_fn_getFifoDir

	$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/executor.sh > $alrb_contDummyHome/executor.log 2>&1 &
	alrb_pipeExecutor=$!
	disown
	local alrb_tmpVal=`ps $alrb_pipeExecutor > /dev/null`
	if [ $? -ne 0 ]; then
	    \echo "Error: Batch system not integrated into container"
	    \echo "         because executor failed."
	    return 64
	fi
	export ALRB_CONT_BATCHPATH
    fi

    return $?
}


alrb_fn_getFifoDir()
{

    mkfifo $ALRB_CONT_HOSTDUMMYHOME/testpipeDeleteMe > /dev/null 2>&1
    if [ $? -eq 0 ]; then
	\rm -f $ALRB_CONT_HOSTDUMMYHOME/testpipeDeleteMe
	\mkdir -p $ALRB_CONT_HOSTDUMMYHOME/.pipe
	export ALRB_CONT_PIPEDIRHOST="$ALRB_CONT_HOSTDUMMYHOME/.pipe"
	export ALRB_CONT_PIPEDIR="/alrb/.pipe"	
    elif [ "$alrb_containMinimal" != "YES" ]; then
	\mkdir -p /tmp/$alrb_whoami/.alrb/pipe
	local alrb_tmpVal=`\mktemp -d /tmp/$alrb_whoami/.alrb/pipe/pipe.XXXXX`
	if [ $? -ne 0 ]; then
	    \echo "ErrorL unable to create dir on /tmp/$alrb_whoami"
	    return 64
	fi
	export ALRB_CONT_PIPEDIRHOST="$alrb_tmpVal"
	export ALRB_CONT_PIPEDIR="$alrb_tmpVal"
    else
	\echo "Error: Unable to create pipe.  \$HOME filesystem dows not allow."
	\echo "       Also, you started container with contain/containall option"
	\echo "       That prevents using /tmp."
	return 64
    fi

    return 0
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

if [ -z $ALRB_OSTYPE ]; then
    \echo "Error: This needs to run in the ATLASLocalRootBase environment" 1>&2
    exit 64
fi

# transition (temporary)
if [ ! -z "$ALRB_SING_OPTS" ]; then
#    \echo "Warnng: \$ALRB_SING_OPTS obsolete; replace with \$ALRB_CONT_OPTS"
    export ALRB_CONT_OPTS="$ALRB_SING_OPTS"
fi
if [ ! -z "$ALRB_SING_PRESETUP" ]; then
#    \echo "Warnng: \$ALRB_SING_PRESETUP obsolete; replace with \$ALRB_CONT_PRESETUP"
    export ALRB_CONT_PRESETUP="$ALRB_SING_PRESETUP"
fi
if [ ! -z "$ALRB_SING_POSTSETUP" ]; then
#    \echo "Warnng: \$ALRB_SING_POSTSETUP obsolete; replace with \$ALRB_CONT_POSTSETUP"
    export ALRB_CONT_POSTSETUP="$ALRB_SING_POSTSETUP"
fi
if [ ! -z "$ALRB_SING_RUNPAYLOAD" ]; then
#    \echo "Warnng: \$ALRB_SING_RUNPAYLOAD obsolete; replace with \$ALRB_CONT_RUNPAYLOAD"
    export ALRB_CONT_RUNPAYLOAD="$ALRB_SING_RUNPAYLOAD"
fi


alrb_shortopts="h,q,c:" 
alrb_longopts="help,quiet,container:"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_Quiet="NO"
if [ -z "$ALRB_CONT_SWTYPE" ]; then
    if [ "$ALRB_OSTYPE" = "MacOSX" ]; then
	export ALRB_CONT_SWTYPE="docker"
    else
	export ALRB_CONT_SWTYPE="singularity"
    fi
fi
alrb_guessContainer=""
alrb_QuietOpt=""

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
	    alrb_fn_startContainerHelp
	    exit 0
            ;;
        -q|--quiet)
            alrb_Quiet="YES"
	    alrb_QuietOpt="-q"
            shift 
            ;;
	-c|--container)
	    alrb_guessContainer="$2"
	    export ALRB_CONT_SETUPATLASOPT="$alrb_guessContainer"
	    shift 2
	    ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

# unset these in case user forgets to submt batch jobs with envs
unset ALRB_CONT_PIPEDIR
unset ALRB_CONT_PIPEDIRHOST
unset ALRB_CONT_BATCHPATH

export ALRB_CONT_CONDUCT=",$ALRB_CONT_CONDUCT,"

export ALRB_CONT_SWTYPE=`\echo $ALRB_CONT_SWTYPE | tr '[:upper:]' '[:lower:]'`

if [ "$alrb_guessContainer" = "" ]; then
    \echo "Error: container to guess not specified" 1>&2
    alrb_fn_startContainerHelp
    exit 64
elif [[ "$ALRB_CONT_SWTYPE" != "singularity" ]] && [[ "$ALRB_CONT_SWTYPE" != "docker" ]]; then
    \echo "Error: container type needs to be singularity or docker"
    alrb_fn_startContainerHelp
    exit 64
fi

# migration of delimiters from : to ?
\echo "$alrb_guessContainer" | \grep -e "images:" 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    \echo "Warning: please use '+' for delimitor instead of ':'"
    alrb_guessContainer=`\echo $alrb_guessContainer | \sed -e 's/images:/images+/'`
    \echo "         container should be specified as : $alrb_guessContainer" 
fi

alrb_pwd=`pwd`
alrb_uid=`id -u`
alrb_whoami=`whoami`
alrb_cont_display=""
alrb_cont_payload=""
alrb_copyProxy="NO"
alrb_setContainerPwd=""
alrb_containMinimal=""
alrb_pipeExecutor=""

alrb_fn_${ALRB_CONT_SWTYPE}OptsParser

if [ "$ALRB_CONT_SWTYPE" = "singularity" ]; then
    alrb_contVer=`singularity --version 2>&1`
    if [ $? -ne 0 ]; then
	\echo "Error: Singularity is not installed and so cannot create container" 1>&2
	exit 64
    fi
    alrb_contVer=`\echo $alrb_contVer | \cut -f 1 -d "-" 2>&1`
    let alrb_contVerN=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_contVer 3`
    if [ "$alrb_contVerN" -lt 20401 ]; then
	\echo "Warning: Singularity version is $alrb_contVer; 2.4.1 or newer recommended."
    fi
else
    alrb_contVer=`docker --version 2>&1`
    if [ $? -ne 0 ]; then
	\echo "Error: Docker is not installed and so cannot create container" 1>&2
	exit 64
    fi
    alrb_contVer=`docker version --format '{{.Client.Version}}' | \cut -f 1 -d "-"`
    let alrb_contVerN=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_contVer 3`
    if [ "$alrb_contVerN" -lt 171200 ]; then
	\echo "Warning: Docker version is $alrb_contVer; 17.12.0  or newer recommended."
    fi
fi

if [ -z $HOME ]; then
    alrb_contWorkdir="${ALRB_tmpScratch}/container/$ALRB_CONT_SWTYPE"
    alrb_homeDir=`cd; pwd; cd $OLDPWD`
else
    alrb_contWorkdir="$HOME/.alrb/container/$ALRB_CONT_SWTYPE"
    alrb_homeDir=$HOME
fi
\mkdir -p $alrb_contWorkdir
if [ $? -ne 0 ]; then
    alrb_fn_cleanup
    exit 64
fi

alrb_container=""
if [ "$ALRB_CONT_SWTYPE" = "singularity" ]; then
    alrb_fn_setSingularityContainer
    if [[ $? -ne 0 ]] || [[ "$alrb_container" = "" ]]; then
	\echo "Error: unable to guess what singularity container to use for $alrb_guessContainer" 1>&2
	alrb_fn_cleanup
	exit 64
    fi
else
    alrb_fn_setDockerContainer    
    if [[ $? -ne 0 ]] || [[ "$alrb_container" = "" ]]; then
	\echo "Error: unable to guess what docker container to use for $alrb_guessContainer" 1>&2
	alrb_fn_cleanup
	exit 64
    fi
    alrb_containerName="my-`\echo $alrb_container | rev | \cut -f 1 -d "/" |rev`"
fi

# allow docker to join running container
if [ "$ALRB_CONT_SWTYPE" = "docker" ]; then
    alrb_joinedRunningDocker="NO"
    alrb_fn_joinRunningDocker
    alrb_rc=$?
    if [ "$alrb_joinedRunningDocker" = "YES" ]; then
	alrb_fn_cleanup
	exit $alrb_rc
    fi
fi

alrb_contDummyHome=""
alrb_fn_createDummyHome
if [ $? -ne 0 ]; then
     alrb_fn_cleanup
     exit 64
fi

export ALRB_CONT_IMAGE="$ALRB_CONT_SWTYPE $alrb_contVer $alrb_container"

alrb_username=`basename $alrb_homeDir`
alrb_userParent=`dirname $alrb_homeDir`
alrb_homeDirNew="/home/$alrb_username"
alrb_contDummyHomeNew=`\echo $alrb_contDummyHome | \sed -e 's|'$alrb_homeDir'|'$alrb_homeDirNew'|g'`
export ALRB_CONT_REALHOME="$alrb_homeDirNew"
export ALRB_CONT_HOSTDUMMYHOME="$alrb_contDummyHome"

if [ "$alrb_setContainerPwd" != "" ]; then
    export ALRB_CONT_CHANGEPWD="$alrb_setContainerPwd"
elif [ "$alrb_pwd" != "$HOME" ]; then
    export ALRB_CONT_CHANGEPWD="/srv"
else
    export ALRB_CONT_CHANGEPWD=""
fi
alrb_pwd=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_pwd`

unset ALRB_CONT_REALTMPDIR
if [ ! -z $TMPDIR ]; then
    export TMPDIR=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $TMPDIR`
    alrb_result=`\echo $TMPDIR | \grep -e "^/tmp" 2>&1`
    if [ $? -eq 0 ]; then
	export ALRB_CONT_REALTMPDIR=$TMPDIR
    else
	alrb_tmpdirNew=`\echo $TMPDIR | \sed -e 's|^'$alrb_homeDir'|'$alrb_homeDirNew'|g' -e 's|^'$alrb_pwd'|\/srv|g'`
	if [ "$alrb_tmpdirNew" != "$TMPDIR" ]; then
	    export ALRB_CONT_REALTMPDIR=$alrb_tmpdirNew
	else
	    export ALRB_CONT_REALTMPDIR="/scratch"
	fi
    fi
fi

alrb_fn_X11Support
if [ $? -ne 0 ]; then
    alrb_fn_cleanup
    exit 64
fi


if [[ ! -z "$ATLAS_SW_BASE" ]] && [[ "$ALRB_RELOCATECVMFS" = "YES" ]]; then
    alrb_cvmfs_mount="$ATLAS_SW_BASE"
else
    alrb_cvmfs_mount="/cvmfs"
fi

if [ "$ALRB_CONT_SWTYPE" = "singularity" ]; then
    if [ -z $SINGULARITY_CACHEDIR ]; then
	export SINGULARITY_CACHEDIR="`pwd`/singularity"
    fi

    if [ "$alrb_containerSkipCvmfs" != "YES" ]; then
	alrb_optStr="-H $alrb_contDummyHome:$ALRB_CONT_DUMMYHOME -B $alrb_cvmfs_mount:/cvmfs"
    else
	alrb_optStr="-H $alrb_contDummyHome:$ALRB_CONT_DUMMYHOME -B $ATLAS_LOCAL_ROOT_BASE:$ALRB_CONT_DUMMYALRB"
    fi	
    alrb_optStr="$alrb_optStr -B $alrb_userParent:/home"
    alrb_optStr="$alrb_optStr -B $alrb_pwd:/srv"
    if [[ ! -z $ALRB_CONT_REALTMPDIR ]] && [[ "$ALRB_CONT_REALTMPDIR" = "/scratch" ]]; then
	alrb_optStr="$alrb_optStr -B $TMPDIR:/scratch"
    fi

    alrb_cmd="singularity $ALRB_CONT_OPTS exec $ALRB_CONT_CMDOPTS"
# versions 2.3.1 and newer have -e option
    if [ $alrb_contVerN -ge 20301 ]; then
	alrb_cmd="$alrb_cmd -e "
    fi
    if [ "$alrb_cont_payload" = "" ]; then
	alrb_cont_payload="/bin/$ALRB_SHELL"
    fi
    alrb_cmd="$alrb_cmd $alrb_optStr $alrb_container $alrb_cont_payload"

    if [ "$alrb_Quiet" = "NO" ]; then
	\echo "------------------------------------------------------------------------------"
	\echo "Singularity: $alrb_contVer"
	\echo "$alrb_cmd"
	\echo "------------------------------------------------------------------------------"
    fi
else
    if [ "$alrb_containerSkipCvmfs" != "YES" ]; then
	alrb_optStr="-v $alrb_contDummyHome:$ALRB_CONT_DUMMYHOME -v $alrb_cvmfs_mount:/cvmfs "
    else
	alrb_optStr="-v $alrb_contDummyHome:$ALRB_CONT_DUMMYHOME -v $ATLAS_LOCAL_ROOT_BASE:$ALRB_CONT_DUMMYALRB"
    fi
    alrb_optStr="$alrb_optStr -v $alrb_userParent:/home"
    alrb_optStr="$alrb_optStr -v $alrb_pwd:/srv"
    if [[ ! -z $ALRB_CONT_REALTMPDIR ]] && [[ "$ALRB_CONT_REALTMPDIR" = "/scratch" ]]; then
	alrb_optStr="$alrb_optStr -v $TMPDIR:/scratch"
    fi
    
    alrb_fn_buildDocker
    if [ $? -ne 0 ]; then
	alrb_fn_cleanup
	exit 64
    fi
    
    alrb_dockerName="$alrb_containerName-`date +%s`" 
    alrb_cmd="docker $ALRB_CONT_OPTS run $ALRB_CONT_CMDOPTS "
    if [[ ! -z "$ALRB_CONT_RUNPAYLOAD" ]] && [[ "$ALRB_SHELL" = "tcsh" ]]; then
	alrb_cont_shellops="/bin/tcsh  -c exit"
    else
	alrb_cont_shellops=""
    fi

    alrb_cmd="$alrb_cmd $alrb_optStr -v /tmp:/tmp -it --rm --name $alrb_dockerName -w $ALRB_CONT_DUMMYHOME $alrb_containerName $alrb_cont_shellops"
    if [ "$alrb_Quiet" = "NO" ]; then
	\echo "------------------------------------------------------------------------------"
	\echo "Docker: $alrb_contVer"
	\echo "$alrb_cmd"
	\echo "------------------------------------------------------------------------------"
    fi
fi

export ALRB_CONT_STARTCMD="$alrb_cmd"

alrb_fn_${ALRB_CONT_SWTYPE}GetPathLookup

alrb_fn_BatchInterface

alrb_fn_saveEnvs

eval $alrb_cmd
alrb_rc=$?

alrb_fn_cleanup

exit $alrb_rc
