#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup git for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_GITLAB_VERSION $1
setenv ATLAS_LOCAL_GITLAB_PATH ${ATLAS_LOCAL_ROOT}/gitlab/${ATLAS_LOCAL_GITLAB_VERSION}

set alrb_tmpVal=`\find $ATLAS_LOCAL_GITLAB_PATH -type d -name lib`
if ( ! $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH "$alrb_tmpVal"
else
    insertPath LD_LIBRARY_PATH "$alrb_tmpVal"
endif

set alrb_tmpVal=`\find $alrb_tmpVal -type d -name site-packages`
if ( ! $?PYTHONPATH ) then
    setenv PYTHONPATH "$alrb_tmpVal"
else
    insertPath PYTHONPATH "$alrb_tmpVal"
endif

set alrb_tmpVal=`\find $ATLAS_LOCAL_GITLAB_PATH -type d -name bin`
if ( $? == 0 ) then
 insertPath PATH "$alrb_tmpVal"
endif

unset alrb_tmpVal


