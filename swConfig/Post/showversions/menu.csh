#!----------------------------------------------------------------------------
#!
#! menu.csh
#!
#! sets up the menu
#!
#! Usage:
#!     source menu.csh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if ( "$alrb_Quiet" == "NO" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh showversions 1 "Post"
endif

alias showVersions '${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh'

set alrb_AvailableToolsPost="$alrb_AvailableToolsPost showversions"

exit 0
