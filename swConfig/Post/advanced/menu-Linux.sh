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

advancedTools()
{
    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/Post/advanced/setup-Linux.sh
    return $?
}

if [ "$alrb_Quiet" != "YES" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh advanced 1 "Post"
fi

alrb_AvailableToolsPost="$alrb_AvailableToolsPost advanced"

return 0
