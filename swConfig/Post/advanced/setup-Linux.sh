#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup advanced tools for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ALRB_advancedTools="YES"

if [ "$alrb_Quiet" != "YES" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh advanced 2 Post
fi

