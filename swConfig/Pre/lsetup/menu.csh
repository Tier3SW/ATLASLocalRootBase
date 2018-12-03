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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh lsetup 1 "Pre"
endif

alias lsetup 'source $ATLAS_LOCAL_ROOT_BASE/packageSetups/localSetup.csh'

set alrb_AvailableToolsPre="$alrb_AvailableToolsPre lsetup"

exit 0
