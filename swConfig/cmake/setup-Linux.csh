#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup cmake for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_CMAKE_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/Cmake/$ATLAS_LOCAL_CMAKE_VERSION -type d -name bin`

insertPath PATH $alrb_tmpVal

unset alrb_tmpVal