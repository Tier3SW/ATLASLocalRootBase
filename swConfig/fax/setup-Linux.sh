#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup fax for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export  ATLAS_LOCAL_FAXTOOLS_VERSION=$1

export FAXtoolsDir="$ATLAS_LOCAL_ROOT/FAXTools/$ATLAS_LOCAL_FAXTOOLS_VERSION/tools"
insertPath PATH "$FAXtoolsDir/bin"

if [ "$alrb_Quiet" = "YES" ]; then
    alrb_opts="--quiet"
else
    alrb_opts=""
fi
eval source $FAXtoolsDir/bin/fax-setRedirector.sh $alrb_opts 
if [ $? -ne 0 ]; then
    \echo "Error in setRedirector, aborting." 1>&2
    return 64
fi

unset alrb_opts

