#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup acm for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_ACM_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/acm/${ATLAS_LOCAL_ACM_VERSION} -type d -name bin`
setenv ALRB_ACM_PATH `$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

if ( -e $ALRB_ACM_PATH/acmSetup.csh ) then
    alias acmSetup 'source $ALRB_ACM_PATH/acmSetup.csh'
else
    if ( "$alrb_Quiet" == "NO" ) then
	\echo " acm:"
	\echo "   Warning: acm does not support csh so your setup is incomplete."
    endif
endif

unset alrb_tmpVal

