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

alrb_fn_diagnosticsPrintMenu()
{
    local let alrb_level=$1
    
    if [[ $alrb_level -eq 1 ]] || [[ $alrb_level -eq 0 ]]; then 
	alrb_fn_menuLine  "diagnostics" "diagnostic tools menu"
    fi
    if [[ $alrb_level -eq 2 ]] || [[ $alrb_level -eq 0 ]]; then
	if [ ! -z $ALRB_diagnostics ]; then
	    alrb_fn_menuLine " checkOS" " check the system OS of your desktop"
	    alrb_fn_menuLine " db-fnget" " run fnget test for Frontier-squid access"
	    alrb_fn_menuLine " db-readReal" " run readReal test for Frontier-squid access"
	    alrb_fn_menuLine " gridCert" " check for user grid certificate issues"
	    alrb_fn_menuLine " rseCheck" " check a Rucio RSE"
	    alrb_fn_menuLine " runKV" " run Kit Validation of an Athena release"
	    alrb_fn_menuLine " setMeUp" " check readiness for tutorial"
	    alrb_fn_menuLine " setMeUpData" " download datafiles for tutorial"
	    alrb_fn_menuLine " supportInfo" " dump information to send to user support"
	    alrb_fn_menuLine " toolTest" " test one or more tools"
	fi
    fi

    return 0
}


