#!----------------------------------------------------------------------------
#!
#! atlasLocalSetup.sh
#!
#! A simple script for users to setup the cluster environment for ATLAS
#!
#! This script adopts a minimilist approach - nothing is added to paths,
#!  only some environment variables and aliases are defined.
#!  Paths to executables and libraries are added when the aliases are 
#!  later invoked by the user.
#!
#!
#! Usage: 
#!     source atlasLocalSetup.sh --help
#!
#! History:
#!   10Oct07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ALRB_initialSetup="True"

alrb_progname=atlasLocalSetup.sh

alrb_fn_setupAtlasHelp()
{
    \cat <<EOF

Usage: atlasLocalSetup.sh [options]
       or setupATLAS [options]

    This sets up the ATLAS environment for a cluster user

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help                   Print this help message
     -q  --quiet                  Print no output
     -p  --noLocalPostSetup       Skip running local/site post-setup script
     -r  --relocateCvmfs          Use relocated cvmfs
     -t  --test=STRING            Used for testing
     -c  --container=name         setupATLAS in a container
                                   name can be eg sl6 or sl7 or
                                   the path to a container 
EOF

if [ -e ${ATLAS_LOCAL_ROOT_BASE}/ALRBTests.txt ]; then
   \cat ${ATLAS_LOCAL_ROOT_BASE}/ALRBTests.txt
fi
}

export ATLAS_LOCAL_SETUP_OPTIONS="$*"

alrb_shortopts="h,q,p,t:,o:,c:"
alrb_longopts="help,quiet,noLocalPostSetup,test:,relocateCvmfs,overrideARCH:,gangaVersion:,pacmanVersion:,rootVersion:,pandaClientVersion:,gccVersion:,asetupVersion:,rucioVersion:,pyAMIVersion:,emiVersion:,agisVersion:,xrootdVersion:,rcSetupVersion:,faxtoolsVersion:,rucioclientsVersion:,atlantisVersion:,davixVersion:,eiClientVersion:,container:"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    return 64
fi
eval set -- "$alrb_opts"

# backward compatibility
agisVersionVal="dynamic"
atlantisVersionVal="dynamic"
gangaVersionVal="dynamic"
davixVersionVal="dynamic"
eiClientVersionVal="dynamic"
emiVersionVal="dynamic"
gccVersionVal="dynamic"
pacmanVersionVal="dynamic"
rootVersionVal="dynamic"
pandaClientVersionVal="dynamic"
asetupVersionVal="dynamic"
rucioVersionVal="dynamic"
rucioclientsVersionVal="dynamic"
xrootdVersionVal="dynamic"
pyAMIVersionVal="dynamic"
rcSetupVersionVal="dynamic"
faxtoolsVersionVal="dynamic"

# obsolete, remove this
export ALRB_allowSL6onSL5="NO"

unset ATLAS_LOCAL_ROOT_ARCH_OVERRIDE
unset ALRB_OSTYPE_OVERRIDE
unset ALRB_OSMAJORVER_OVERRIDE

alrb_Quiet="NO"
alrb_quietOpt=""
alrb_noLocalPostSetup="NO"
alrb_container=""

if [ -z $ALRB_RELOCATECVMFS ]; then
    export ALRB_RELOCATECVMFS="NO"
fi
if [ -z $ALRB_testPath ]; then
    ALRB_testPath=""
    if [ ! -z $ALRBtestPath ]; then
# obsolete but backward compatible
	ALRB_testPath="$ALRBtestPath"
	unset ALRBtestPath
    fi
fi

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_setupAtlasHelp
            return 0
            ;;
        -q|--quiet)
            alrb_Quiet="YES"
	    alrb_quietOpt=" --quiet"
            shift
            ;;
        -p|--noLocalPostSetup)
	    alrb_noLocalPostSetup="YES"
            shift
            ;;
	-o|--overrideARCH)
	    export ATLAS_LOCAL_ROOT_ARCH_OVERRIDE=$2
	    shift 2
	    ;;
	-t|--test)
	    ALRB_testPath=$2
	    shift 2
	    ;;	    
	-r|--relocateCvmfs)
	    export ALRB_RELOCATECVMFS="YES"
            shift
            ;;	    
	-c|--container)
	    alrb_container=$2
	    shift 2
	    ;;
        --agisVersion| \
        --asetupVersion| \
	--eiClientVersion| \
        --emiVersion| \
	--faxtoolsVersion| \
	--gangaVersion| \
        --faxtoolsVersion | \
        --gangaVersion| \
        --gccVersion| \
        --pacmanVersion| \
        --pandaClientVersion | \
        --rootVersion| \
        --rucioVersion| \
        --rucioclientsVersion| \
        --atlantisVersion| \
        --davixVersion| \
        --xrootdVersion| \
        --pyAMIVersion| \
        --rcSetupVersion)
	    \echo "option $1 is obsolete.  Please do not use it." 1>&2
            shift 2
            ;;
	--)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2 
            return 1
            ;;
    esac
done

if [ -z $ATLAS_LOCAL_ROOT_BASE ]  
then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set" 1>&2
    return 64
else
    if [ ! -z $ALRB_CONT_HOSTALRBDIR ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/relocate/container.sh
    elif [ "$ALRB_RELOCATECVMFS" = "YES" ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/relocate/relocateCvmfs.sh
    fi
    source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh
fi

if [ ! -z ALRB_SHELL ]; then
    if [ "$ALRB_SHELL" = "bash" ]; then
	source $ATLAS_LOCAL_ROOT_BASE/utilities/checkShell.sh
    elif [ "$ALRB_SHELL" = "zsh" ]; then
	source $ATLAS_LOCAL_ROOT_BASE/utilities/checkShell.zsh
    fi
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/setupAliases.sh

export ALRB_testPath=",$ALRB_testPath,"

# if container, then go away; need to copy it since the container can run long
if [ "$alrb_container" != "" ]; then
    mkdir -p $ALRB_SCRATCH/container/scripts
    alrb_scriptFile=`mktemp $ALRB_SCRATCH/container/scripts/startContainer.sh.XXXXXX`
    if [ $? -ne 0 ]; then
	return 64
    fi
    \cp $ATLAS_LOCAL_ROOT_BASE/utilities/startContainer.sh $alrb_scriptFile
    chmod +x $alrb_scriptFile
    eval $alrb_scriptFile  -c "$alrb_container" $alrb_quietOpt
    alrb_rc=$?
    \rm -f $alrb_scriptFile
    return $alrb_rc
elif [ "$ALRB_containerSiteOnly" = "YES" ]; then
    \echo 'Error: setupATLAS is meant to only run on a container at this site'
    \echo '       You should do "setupATLAS -c slc6"'
    \echo 'see https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Containers'
    return 64
fi

alrb_AvailableTools=""
alrb_AvailableToolsPre=""
alrb_AvailableToolsPost=""

alrb_menuTypeAr=( "Pre" "." "Post" ) 
for alrb_menuType in "${alrb_menuTypeAr[@]}"; do 
    alrb_dirAr=( `\find $ATLAS_LOCAL_ROOT_BASE/swConfig/${alrb_menuType} -maxdepth 1 -mindepth 1 -type d | \sed -e 's/.*\///' | env LC_ALL=C \sort` )
    for alrb_menuItem in ${alrb_dirAr[@]}; do
	alrb_QuietSaved=$alrb_Quiet
	if [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu-${ALRB_OSTYPE}.sh" ]; \
	    then
	    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}//menu-${ALRB_OSTYPE}.sh
	elif [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu.sh" ]; then
	    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu.sh
	fi
	alrb_Quiet=$alrb_QuietSaved
    done
done

export ALRB_availableTools="$alrb_AvailableTools"
export ALRB_availableToolsPre="$alrb_AvailableToolsPre"
export ALRB_availableToolsPost="$alrb_AvailableToolsPost"

# save this application as an alias
alias atlasLocalRootBaseSetup='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup-v2.sh'

# check if more than one grid middleware is available
alrb_result=`${ATLAS_LOCAL_ROOT_BASE}/utilities/checkGridUse.sh`
alrb_nGridSW=`\echo $alrb_result | \cut -f 1 -d " "`
alrb_availableSW=`\echo $alrb_result | \cut -f 2- -d " "`
if [ -z $ALRB_useGridSW ];  then
    if [ "$alrb_nGridSW" -eq 0 ]; then
	export ALRB_useGridSW=0
    else
	export ALRB_useGridSW=`\echo $alrb_result | \cut -f 2 -d " "`
    fi
fi
if [[ "$alrb_nGridSW" -gt 1 ]] && [[ "${alrb_Quiet}" = "NO" ]]; then    
    \echo "*******************************************************************************"
    \echo "Grid middleware note:"
    \echo "  $availableSW are available on this machine."
    \echo "  Current value is $ALRB_useGridSW"
    \echo "  The default value is set by the environment variable ALRB_useGridSW"
    \echo "    possible values for ALRB_useGridSW: $availableSW"
    \echo "*******************************************************************************"
fi

# motd
if [ "${alrb_Quiet}" = "NO" ]; then
    if [ -e $ATLAS_LOCAL_ROOT_BASE/etc/motd ]; then
	$ATLAS_LOCAL_ROOT_BASE/etc/motd
    fi
fi

# warnings

alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $ATLAS_LOCAL_ROOT_BASE | \grep -e "^/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"`
if [ $? -eq 0 ]; then
    if [ ! -d $ATLAS_LOCAL_ROOT_BASE ]; then
	\echo "Error: \$ATLAS_LOCAL_ROOT_BASE does not exist." 1>&2
    elif [ "$ATLAS_LOCAL_ROOT_ARCH" = "i686" ]; then
	\echo "Error: \$ATLAS_LOCAL_ROOT_BASE on cvmfs is not available for i686" 1>&2
    fi
fi

if [[ "$ALRB_RHVER" -ge 6 ]] && [[ "$ATLAS_LOCAL_ROOT_ARCH" = "i686" ]]; then
    \echo "Warning: 32-bit is unsupported on SL${ALRB_RHVER}." 1>&2
    \echo "  Please migrate to 64-bit OS for SL${ALRB_RHVER}." 1>&2
fi

if [[ "$ALRB_RHVER" -le 5 ]] && [[ "$ALRB_RHVER" -ne 0 ]]; then
    \echo "Warning: SL${ALRB_RHVER} is unsupported." 1>&2
    \echo " Please switch to using SL6 machines now (all SL${ALRB_RHVER} releases work on SL6)." 1>&2
    if [ ! -z $ATLAS_LOCAL_ROOT_CERNVM ]; then
	\echo "  CernVM users: please upgrade to CernVM3; see
   https://twiki.cern.ch/twiki/bin/view/AtlasComputing/CernVMFS#Setup_Instructions_for_CernVM_Us" 1>&2
    fi
fi

# PFC exists ?
if [ -z $ATLAS_POOLCOND_PATH ]; then
    if [ "$ALRB_cvmfs_CDB" != "" ]; then
	export ATLAS_POOLCOND_PATH=$ALRB_cvmfs_CDB
    fi
fi
if [ "$ALRB_RELOCATECVMFS" = "YES" ]; then
    source ${ATLAS_LOCAL_ROOT_BASE}/relocate/relocateCvmfs-pool.sh
fi

# Frontier setup
if [ -e $ATLAS_LOCAL_ROOT_BASE/config/localFrontierSquid.sh ]; then
    source $ATLAS_LOCAL_ROOT_BASE/config/localFrontierSquid.sh
fi

# Missing Frontier in flat files - try to "guess" (may be from AGIS)
if [ -z $FRONTIER_SERVER ]; then
    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/guessFrontier.sh`
    if [ $? -eq 0 ]; then
	export FRONTIER_SERVER=$alrb_result
    fi
fi
if [ ! -z $FRONTIER_SERVER ]; then
    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/addBackupFrontier.sh`
    if [ $? -eq 0 ]; then
	export FRONTIER_SERVER=$alrb_result
    fi
fi

# here we will allow a site to run their own post configuration; but users 
# can override it - especially when asked by user spport.

if [[ ! -z $ALRB_localConfigDir ]] && [[ -d $ALRB_localConfigDir ]] && [[ "$alrb_noLocalPostSetup" = "NO" ]]; then
    alrb_appList=( "localFrontierSquid.sh" "localPostUserSetup.sh" )
    for alrb_item in ${alrb_appList[@]}; do
	if [ -e "$ALRB_localConfigDir/$alrb_item" ]; then
	    source $ALRB_localConfigDir/$alrb_item
	fi
    done
fi

if [[ -e $ATLAS_LOCAL_ROOT_BASE/config/localPostUserSetup.sh ]] && [[ "$alrb_noLocalPostSetup" = "NO" ]]; then
    source $ATLAS_LOCAL_ROOT_BASE/config/localPostUserSetup.sh
fi

# cvmfs validity check
eval $ATLAS_LOCAL_ROOT_BASE/utilities/checkValidity.sh $alrb_quietOpt
alrb_returnVal=$?  # suppress exit code from this 

# fix manpath so that it does not get clobbered
if [ -z $MANPATH ]; then
    export MANPATH=`manpath`
fi

# tab completion
if [ "$ALRB_SHELL" = "bash" ]; then
    complete -W "$ALRB_availableTools" lsetup
elif [ "$ALRB_SHELL" = "zsh" ]; then
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/Pre/lsetup/zshTabComp/init.sh
fi

export ALRB_printHelpMain="$printHelpMain"
unset alrb_shortopts alrb_longopts alrb_result alrb_returnVal alrb_Quiet alrb_QuietSaved alrb_dirAr alrb_menuItem alrb_nGridSW alrb_availableSW alrb_menuTypeAr alrb_menuType alrb_item alrb_appList ALRB_initialSetup

