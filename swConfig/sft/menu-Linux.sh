#!----------------------------------------------------------------------------
#!
#! menu.sh
#!
#! sets up the menu
#!
#! Usage:
#!     source menu.sh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ "$ALRB_SFT_LCG" = "none" ]; then
    return 0
fi

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh sft 1
fi

alias localSetupSFT='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh sft'

alrb_AvailableTools="$alrb_AvailableTools sft"

return 0
