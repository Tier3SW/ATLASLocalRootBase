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
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh asetup 1
fi

alias changeASetup='source $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/changeAsetup.sh'

alrb_AvailableTools="$alrb_AvailableTools asetup"
export ALRB_availableTools="$alrb_AvailableTools"

command -v asetup > /dev/null 2>&1
if [[ $? != 0 ]] || [[ -z $ATLAS_LOCAL_ASETUP_VERSION ]]; then
    source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh asetup -q
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createUserASetup.sh
fi

return 0
