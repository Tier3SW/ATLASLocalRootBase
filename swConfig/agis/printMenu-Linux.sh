#!----------------------------------------------------------------------------
#!
#! printMenu.sh
#!
#! prints out the menu
#!
#! Usage:
#!     source printMenu.sh <level>
#!  where level =0 means print all or <int> means only print a certail level.
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fn_agisPrintMenu()
{
    local let alrb_level=$1
    
    alrb_fn_menuLine " lsetup agis" " ATLAS Grid Information System"
    
    return 0
}

