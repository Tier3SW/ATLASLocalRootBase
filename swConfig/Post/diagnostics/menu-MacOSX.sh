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

diagnostics()
{
    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/Post/diagnostics/setup-MacOSX.sh
    return $?
}

if [ "$alrb_Quiet" != "YES" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh diagnostics 1 "Post"
fi

#alias diagnostics='source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/Post/diagnostics/setup-MacOSX.sh'

alrb_AvailableToolsPost="$alrb_AvailableToolsPost diagnostics"

return 0
