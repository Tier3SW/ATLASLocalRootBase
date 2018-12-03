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

alrb_fn_podPrintMenu()
{
    local let alrb_level=$1

    if [[ $alrb_level -eq 1 ]] || [[ $alrb_level -eq 0 ]]; then    
	alrb_fn_menuLine " lsetup pod" " Proof-on-Demand (obsolete)"
    fi
    if [[ $alrb_level -eq 2 ]] || [[ $alrb_level -eq 0 ]]; then
	if [ ! -z $ALRB_POD_DIR ]; then
	    alrb_fn_menuLine "  generatePoDSetups" "  to generate the pod-remote scripts"
	fi
    fi

    return 0
}


