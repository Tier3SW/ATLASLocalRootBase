#!----------------------------------------------------------------------------
#!
#! menu.csh
#!
#! sets up the menu
#!
#! Usage:
#!     source menu.csh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv VIEWSDIR "$ALRB_SFT_LCG/views"
alias views 'source $VIEWSDIR/setupViews.csh'

set alrb_AvailableTools="$alrb_AvailableTools views"
setenv ALRB_availableTools "$alrb_AvailableTools"

exit 0