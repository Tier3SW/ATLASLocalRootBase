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

helpMe()
{
    ${ATLAS_LOCAL_ROOT_BASE}/utilities/generateHelpMe.sh
    return $?
}

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh helpme 1 "Post"
fi

#alias helpMe='${ATLAS_LOCAL_ROOT_BASE}/utilities/generateHelpMe.sh'

alrb_AvailableToolsPost="$alrb_AvailableToolsPost helpme"

return 0
