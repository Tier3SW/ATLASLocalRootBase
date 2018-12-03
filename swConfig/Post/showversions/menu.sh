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

showVersions()
{
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $@
    return $?
}

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh showversions 1 "Post"
fi

#alias showVersions='${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh'

alrb_AvailableToolsPost="$alrb_AvailableToolsPost showversions"

return 0
