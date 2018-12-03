#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup png for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_PNG_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/png/${ATLAS_LOCAL_PNG_VERSION} -type d -name lib`
setenv ALRB_PNG_PATH `$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`


if ( ! $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH "$ALRB_PNG_PATH/lib"
else
    insertPath LD_LIBRARY_PATH "$ALRB_PNG_PATH/lib"
endif

unset alrb_tmpVal

