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

if [ "$ALRB_cvmfs_Athena" = "" ]; then
    return
fi

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh rcsetup 1
fi

alias changeRCSSetup='source $ATLAS_LOCAL_ROOT_BASE/swConfig/rcsetup/changeRcsetup.sh'

alrb_AvailableTools="$alrb_AvailableTools rcsetup"
export ALRB_availableTools="$alrb_AvailableTools"

command -v rcsetup > /dev/null 2>&1
if [[ $? != 0 ]] || [[ -z $ATLAS_LOCAL_RCSETUP_VERSION ]]; then
    source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh rcsetup -q
fi

return 0
