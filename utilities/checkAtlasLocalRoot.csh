#!----------------------------------------------------------------------------
#!
#! checkAtlasLocalRoot.csh
#!
#! A simple script to check the local ATLAS infrastructure
#!
#! Usage:
#!     source checkAtlasLocalRoot.csh
#!
#! History:
#!    6Dec07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if (! $?ATLAS_LOCAL_ROOT_BASE ) then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
else

    if ( ! $?ALRB_SCRATCH ) then
	set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh scratch`
	if ( $? != 0 ) then
	    \echo "Error: Cannot determine ALRB_SCRATCH"
	endif
	setenv ALRB_SCRATCH "$alrb_result"
    endif
    if ( ! $?ALRB_tmpScratch ) then
	set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh tmp`
	if ( $? != 0 ) then
	    \echo "Error: Cannot determine ALRB_tmpScratch"
	endif
	setenv ALRB_tmpScratch "$alrb_result"
    endif

    set alrb_tmpVal=`\echo $ATLAS_LOCAL_ROOT_BASE | \sed 's/\/$//'`
    if ( "$alrb_tmpVal" != "$ATLAS_LOCAL_ROOT_BASE" ) then
	setenv ATLAS_LOCAL_ROOT_BASE $alrb_tmpVal
    endif

    set alrb_osInfo=`$ATLAS_LOCAL_ROOT_BASE/utilities/getOSType.sh`
    set alrb_osType=`\echo $alrb_osInfo | \cut -f 1 -d " "`
    if ( ! $?ALRB_OSTYPE_OVERRIDE ) then
	setenv ALRB_OSTYPE $alrb_osType
    else
	setenv ALRB_OSTYPE $ALRB_OSTYPE_OVERRIDE
    endif
    set alrb_osMajorVer=`\echo $alrb_osInfo | \cut -f 2 -d " "`
    if ( ! $?ALRB_OSMAJORVER_OVERRIDE ) then
	setenv ALRB_OSMAJORVER $alrb_osMajorVer
    else
	setenv ALRB_OSMAJORVER $ALRB_OSMAJORVER_OVERRIDE
    endif
    unset alrb_osInfo alrb_osType alrb_osMajorVer

    if ( ! $?ATLAS_LOCAL_ROOT_ARCH_OVERRIDE ) then
	set ATLAS_LOCAL_ROOT_ARCH=`$ATLAS_LOCAL_ROOT_BASE/utilities/getArchType.sh`
    else
	set ATLAS_LOCAL_ROOT_ARCH=$ATLAS_LOCAL_ROOT_ARCH_OVERRIDE
    endif
    set ATLAS_LOCAL_ROOT=${ATLAS_LOCAL_ROOT_BASE}/${ATLAS_LOCAL_ROOT_ARCH}
    if ( ! -e ${ATLAS_LOCAL_ROOT} ) then
        \echo "Missing ${ATLAS_LOCAL_ROOT}; is this architecture supported ?"
        exit 64
    else
	setenv ATLAS_LOCAL_ROOT $ATLAS_LOCAL_ROOT
	setenv ATLAS_LOCAL_ROOT_ARCH $ATLAS_LOCAL_ROOT_ARCH
    endif

    if ( ! $?ALRB_cvmfs_repo ) then
	setenv ALRB_cvmfs_repo "/cvmfs/atlas.cern.ch/repo"
    endif
    if ( ! $?ALRB_cvmfs_condb_repo ) then
	setenv ALRB_cvmfs_condb_repo "/cvmfs/atlas-condb.cern.ch/repo"
    endif
    if ( ! $?ALRB_cvmfs_nightly_repo ) then
	setenv ALRB_cvmfs_nightly_repo "/cvmfs/atlas-nightlies.cern.ch/repo"
    endif
    if ( ! $?ALRB_cvmfs_sft_repo ) then
	setenv ALRB_cvmfs_sft_repo "/cvmfs/sft.cern.ch/lcg"
    endif

    if ( -d "$ALRB_cvmfs_repo/sw" ) then
	setenv ALRB_cvmfs_ALRB "$ALRB_cvmfs_repo/ATLASLocalRootBase"
	setenv ALRB_cvmfs_Athena "$ALRB_cvmfs_repo/sw/software"
    else
	setenv ALRB_cvmfs_ALRB ""
	setenv ALRB_cvmfs_Athena ""
    endif

    if ( -d "$ALRB_cvmfs_condb_repo/conditions" ) then
	setenv ALRB_cvmfs_CDB "$ALRB_cvmfs_condb_repo/conditions"
    else
	setenv ALRB_cvmfs_CDB ""
    endif

    set ATLAS_LOCAL_ROOT_PACOPT=""
# is this cernvm ?
    if ( -e /etc/issue ) then
	set alrb_result=`\grep "CERN Virtual Machine" /etc/issue`
	if ( $? == 0 ) then
	    set ATLAS_LOCAL_ROOT_CERNVM=`\grep version /etc/issue | \sed 's/.*version \(.*\)/\1/'`
            setenv ATLAS_LOCAL_ROOT_CERNVM $ATLAS_LOCAL_ROOT_CERNVM
# for CernVM, help put pacman options
	    set ATLAS_LOCAL_ROOT_PACOPT="-pretend-platform SL-$ALRB_OSMAJORVER"
      endif
    endif
    if ( $?ATLAS_LOCAL_ROOT_PACOPT_OVERRIDE ) then
	set ATLAS_LOCAL_ROOT_PACOPT="$ATLAS_LOCAL_ROOT_PACOPT_OVERRIDE"
    endif
    setenv ATLAS_LOCAL_ROOT_PACOPT "$ATLAS_LOCAL_ROOT_PACOPT"

    set alrb_tmpVal=`\ps -o command= $$ | \cut -f 1 -d " "`
    setenv ALRB_SHELL `\echo $alrb_tmpVal | \sed 's/-//g'`
    \echo $alrb_tmpVal | \grep csh > /dev/null
    if ( $? == 0 ) then
	setenv ALRB_SHELL "tcsh"
    endif

# retain for backward compatibility
    if ( "$ALRB_OSTYPE" == "Linux" ) then
	setenv ALRB_RHVER $ALRB_OSMAJORVER
    else
	setenv ALRB_RHVER 0
    endif

# sft repo
    if ( -d $ALRB_cvmfs_sft_repo ) then
	setenv ALRB_SFT_LCG $ALRB_cvmfs_sft_repo
	setenv ALRB_SFT_LCGEXT_MAP "$ALRB_SFT_LCG/mapfile.txt"
    else
	setenv ALRB_SFT_LCG "none"
	setenv ALRB_SFT_LCGEXT_MAP "/none"
    endif

endif
	
unset alrb_result alrb_tmpVal	

