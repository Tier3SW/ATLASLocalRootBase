#!----------------------------------------------------------------------------
#!
#! checkAtlasLocalRoot.sh
#!
#! A simple script to check the local ATLAS infrastructure
#!
#! Usage:
#!     source checkAtlasLocalRoot.sh
#!
#! History:
#!    6Dec07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ -z $ATLAS_LOCAL_ROOT_BASE ]; then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    return 64
else

    if [ -z $ALRB_SCRATCH ]; then	
	alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh scratch`
	if [ $? -ne 0 ]; then
	    \echo "Error: Cannot determine ALRB_SCRATCH"
	fi
	export ALRB_SCRATCH="$alrb_result"
    fi
    if [ -z $ALRB_tmpScratch ]; then
	alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh tmp`
	if [ $? -ne 0 ]; then
	    \echo "Error: Cannot determine ALRB_tmpScratch"
	fi
	export ALRB_tmpScratch="$alrb_result"
    fi

    alrb_tmpVal=`\echo $ATLAS_LOCAL_ROOT_BASE | \sed 's/\/$//'`
    if [ "$alrb_tmpVal" != "$ATLAS_LOCAL_ROOT_BASE" ]; then	
	export ATLAS_LOCAL_ROOT_BASE=$alrb_tmpVal
    fi

    alrb_osInfo=`$ATLAS_LOCAL_ROOT_BASE/utilities/getOSType.sh`
    alrb_osType=`\echo $alrb_osInfo | \cut -f 1 -d " "`
    if [ -z $ALRB_OSTYPE_OVERRIDE ]; then
	export ALRB_OSTYPE=$alrb_osType
    else
	export ALRB_OSTYPE=$ALRB_OSTYPE_OVERRIDE
    fi
    alrb_osMajorVer=`\echo $alrb_osInfo | \cut -f 2 -d " "`
    if [ -z $ALRB_OSMAJORVER_OVERRIDE ]; then
	export ALRB_OSMAJORVER=$alrb_osMajorVer
    else
	export ALRB_OSMAJORVER=$ALRB_OSMAJORVER_OVERRIDE
    fi
    unset alrb_osInfo alrb_osType alrb_osMajorVer

    if [ -z $ATLAS_LOCAL_ROOT_ARCH_OVERRIDE ]; then	
	ATLAS_LOCAL_ROOT_ARCH=`$ATLAS_LOCAL_ROOT_BASE/utilities/getArchType.sh`
    else
	ATLAS_LOCAL_ROOT_ARCH=$ATLAS_LOCAL_ROOT_ARCH_OVERRIDE
    fi
    ATLAS_LOCAL_ROOT=${ATLAS_LOCAL_ROOT_BASE}/${ATLAS_LOCAL_ROOT_ARCH}
    if [ ! -e ${ATLAS_LOCAL_ROOT} ]
        then
        \echo "Missing ${ATLAS_LOCAL_ROOT}; is this architecture supported ?"
        return 64
    else
	export ATLAS_LOCAL_ROOT
	export ATLAS_LOCAL_ROOT_ARCH
    fi

    if [ -z $ALRB_cvmfs_repo ]; then
	export ALRB_cvmfs_repo="/cvmfs/atlas.cern.ch/repo"
    fi
    if [ -z $ALRB_cvmfs_condb_repo ]; then
	export ALRB_cvmfs_condb_repo="/cvmfs/atlas-condb.cern.ch/repo"
    fi
    if [ -z $ALRB_cvmfs_nightly_repo ]; then
	export ALRB_cvmfs_nightly_repo="/cvmfs/atlas-nightlies.cern.ch/repo"
    fi
    if [ -z $ALRB_cvmfs_sft_repo ]; then
	export ALRB_cvmfs_sft_repo="/cvmfs/sft.cern.ch/lcg"
    fi

    if [ -d "$ALRB_cvmfs_repo/sw" ]; then
	export ALRB_cvmfs_ALRB="$ALRB_cvmfs_repo/ATLASLocalRootBase"
	export ALRB_cvmfs_Athena="$ALRB_cvmfs_repo/sw/software"
    else
	export ALRB_cvmfs_ALRB=""
	export ALRB_cvmfs_Athena=""	
    fi

    if [ -d "$ALRB_cvmfs_condb_repo/conditions" ]; then
	export ALRB_cvmfs_CDB="$ALRB_cvmfs_condb_repo/conditions"
    else
	export ALRB_cvmfs_CDB=""
    fi

    ATLAS_LOCAL_ROOT_PACOPT=""
# is this cernvm ?
    if [ -e /etc/issue ]; then
	alrb_result=`\grep "CERN Virtual Machine" /etc/issue`
	if [ $? -eq 0 ]; then
	    ATLAS_LOCAL_ROOT_CERNVM=`\grep version /etc/issue | \sed 's/.*version \(.*\)/\1/'`
	    export ATLAS_LOCAL_ROOT_CERNVM
# for CernVM, help put pacman options 
	    ATLAS_LOCAL_ROOT_PACOPT="-pretend-platform SL-$ALRB_OSMAJORVER"
	fi
    fi
    if [ ! -z $ATLAS_LOCAL_ROOT_PACOPT_OVERRIDE ]; then
	ATLAS_LOCAL_ROOT_PACOPT="$ATLAS_LOCAL_ROOT_PACOPT_OVERRIDE"	
    fi
    export ATLAS_LOCAL_ROOT_PACOPT

    alrb_tmpVal=`\ps -o command= $$ | \cut -f 1 -d " "`
    export ALRB_SHELL=`\echo $alrb_tmpVal | \sed 's/-//g'`
    \echo $alrb_tmpVal | \grep bash > /dev/null
    if [ $? -eq 0 ]; then
	export ALRB_SHELL="bash"
    fi
    \echo $alrb_tmpVal | \grep zsh > /dev/null
    if [ $? -eq 0 ]; then
	export ALRB_SHELL="zsh"
    fi

# for backward compatibility
    if [ "$ALRB_OSTYPE" = "Linux" ]; then
	export ALRB_RHVER=$ALRB_OSMAJORVER
    else
	export ALRB_RHVER="0"
    fi

# sft repo
    if [ -d $ALRB_cvmfs_sft_repo ]; then
	export ALRB_SFT_LCG=$ALRB_cvmfs_sft_repo
	export ALRB_SFT_LCGEXT_MAP="$ALRB_SFT_LCG/mapfile.txt"
    else
	export ALRB_SFT_LCG="none"
	export ALRB_SFT_LCGEXT_MAP="/none"
    fi

fi

unset alrb_result alrb_tmpVal

