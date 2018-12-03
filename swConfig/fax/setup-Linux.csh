#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup fax for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_FAXTOOLS_VERSION $1

setenv FAXtoolsDir "$ATLAS_LOCAL_ROOT/FAXTools/$ATLAS_LOCAL_FAXTOOLS_VERSION/tools"
insertPath PATH "$FAXtoolsDir/bin"

if ( "$alrb_Quiet" == "YES" ) then
    set alrb_opts="--quiet"
else
    set alrb_opts=""
endif
source $FAXtoolsDir/bin/fax-setRedirector.csh $alrb_opts 
if ( $? != 0 ) then
    \echo "Error in setRedirector, aborting." > /dev/stderr
    exit 64
endif

unset alrb_opts

