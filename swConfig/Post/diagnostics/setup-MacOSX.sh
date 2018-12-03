#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup diagnostics for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ALRB_diagnostics="YES"

alias checkOS='${ATLAS_LOCAL_ROOT_BASE}/utilities/installCheck.sh'
alias supportInfo='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/generateDumpFile.sh'

if [ "$alrb_Quiet" != "YES" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh diagnostics 2 Post
fi

