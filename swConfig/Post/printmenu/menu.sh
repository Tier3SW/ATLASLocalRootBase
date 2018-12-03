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

printMenu()
{
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh "all"
    return $?
}

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh printmenu 1 "Post"
fi

#alias printMenu='$ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh "all"'

alrb_AvailableToolsPost="$alrb_AvailableToolsPost printmenu"

return 0
