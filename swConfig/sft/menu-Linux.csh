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

if ( "$ALRB_SFT_LCG" == "none" ) then
    exit 
endif

if ( "$alrb_Quiet" == "NO" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh sft 1
endif

alias localSetupSFT 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.csh sft'

set alrb_AvailableTools="$alrb_AvailableTools sft"

exit 0
