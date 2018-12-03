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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh root 1
endif

alias localSetupROOT 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.csh root'

set alrb_AvailableTools="$alrb_AvailableTools root"

exit 0
