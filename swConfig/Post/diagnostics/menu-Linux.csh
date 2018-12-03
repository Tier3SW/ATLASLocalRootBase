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

if ( ! $?alrb_Quiet ) then
    set alrb_Quiet=""
endif

if ( "$alrb_Quiet" != "YES" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh diagnostics 1 "Post"
endif

alias diagnostics 'source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/Post/diagnostics/setup-Linux.csh'

set alrb_AvailableToolsPost="$alrb_AvailableToolsPost diagnostics"

if ( "$alrb_Quiet" == "" ) then
    unset alrb_Quiet
endif

exit 0
