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

export VIEWSDIR="$ALRB_SFT_LCG/views"

function views
{
    source $VIEWSDIR/setupViews.sh $@
    return $?
}


alrb_AvailableTools="$alrb_AvailableTools views"
export ALRB_availableTools="$alrb_AvailableTools"

return 0
