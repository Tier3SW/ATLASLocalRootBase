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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh lcgenv 1
fi

alrb_AvailableTools="$alrb_AvailableTools lcgenv"
export ALRB_availableTools="$alrb_AvailableTools"

return 0
