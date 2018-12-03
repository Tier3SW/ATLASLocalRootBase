#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script asetup for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

function asetup
{
    source $AtlasSetup/scripts/asetup.sh $@
    return $?
}

export ATLAS_LOCAL_ASETUP_VERSION=$1
deletePath PATH $ATLAS_LOCAL_ASETUP_PATH
export ATLAS_LOCAL_ASETUP_PATH=${ATLAS_LOCAL_ROOT}/AtlasSetup/${ATLAS_LOCAL_ASETUP_VERSION}
export AtlasSetup=$ATLAS_LOCAL_ASETUP_PATH/AtlasSetup

alrb_asetupVerN=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh asetup $ATLAS_LOCAL_ASETUP_VERSION`

if [ -z $CMTUSERCONTEXT ]; then
    alrb_result=`\echo $ALRB_testPath | \grep -e ",cmtSL6-dev,"`
    if [ $? -eq 0 ]; then
        alrb_opts="--dev"
    else 
        alrb_opts=""
    fi
    if [ "$alrb_Quiet" != "NO" ]; then
	alrb_opts="$alrb_opts --quiet"
    fi
    if [ -e  $ALRB_cvmfs_repo/sw/local/setup-compat.sh ]; then
	eval source  $ALRB_cvmfs_repo/sw/local/setup-compat.sh $alrb_opts 
    else
	\echo " asetup:"
	\echo "   Warning: $ALRB_cvmfs_repo/sw/local/setup-compat.sh not found"
    fi
fi

export AtlasSetupSite=${ATLAS_LOCAL_ROOT}/AtlasSetup/.config/.asetup.site
if [ $alrb_asetupVerN -ge 10003 ]; then
    export AtlasSetupSiteCMake=${ATLAS_LOCAL_ROOT}/AtlasSetup/.configCMake/.asetup.site
fi

if [ "$ALRB_RELOCATECVMFS" = "YES" ]; then
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/relocateCvmfs.sh
fi
#alias asetup='source $AtlasSetup/scripts/asetup.sh'
alrb_tmpVal=`alias asetup 2>&1`
if [ $? -eq 0 ]; then
    unalias asetup
fi

unset alrb_asetupVerN alrb_result alrb_opts alrb_tmpVal

if [[ "$#" -ge 2 ]] && [[ "$2" != "" ]]; then
    shift
    eval source $AtlasSetup/scripts/asetup.sh $@ 
    return $?    
fi

return 0


