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

alrb_fn_gangaPrintMenu()
{
    local let alrb_level=$1

    if [[ $alrb_level -eq 1 ]] || [[ $alrb_level -eq 0 ]]; then
	alrb_fn_menuLine " lsetup ganga" " Ganga: job definition and management client"
    fi
    if [[ $alrb_level -eq 2 ]] || [[ $alrb_level -eq 0 ]]; then
	if [ ! -z $ATLAS_LOCAL_GANGA_PATH ]; then
	    alrb_fn_menuLine "  generateGangarc" "  to recreate .gangarc settings file"
	fi
    fi

    return 0
}


