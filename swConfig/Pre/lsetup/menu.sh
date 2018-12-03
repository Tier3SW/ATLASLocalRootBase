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

lsetup()
{
    source $ATLAS_LOCAL_ROOT_BASE/packageSetups/localSetup.sh "$@"
    return $?
}

if [ "$alrb_Quiet" = "NO" ]; then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh lsetup 1 "Pre"
fi

# keep this as a reminder that tcsh uses aliases
#alias lsetup='source $ATLAS_LOCAL_ROOT_BASE/packageSetups/localSetup.sh "$@"'

alrb_AvailableToolsPre="$alrb_AvailableToolsPre lsetup"


return 0
