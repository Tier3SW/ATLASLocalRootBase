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

alrb_fn_advancedPrintMenu()
{
    local let alrb_level=$1
    
    if [[ $alrb_level -eq 1 ]] || [[ $alrb_level -eq 0 ]]; then 
	alrb_fn_menuLine  "advancedTools" "advanced tools menu"
    fi
    if [[ $alrb_level -eq 2 ]] || [[ $alrb_level -eq 0 ]]; then
	if [ ! -z $ALRB_advancedTools ]; then
	    alrb_fn_menuLine " lsetup adctools" " Tools for ADC and cloud support use"
	    alrb_fn_menuLine " lsetup art" " Atlas Releasse Tester"
	    alrb_fn_menuLine " lsetup cmake" " CMake software build tools"
	    alrb_fn_menuLine " lsetup cppcheck" " Static C/C++ analysis tool"
	    alrb_fn_menuLine " lsetup davix" " davix: file management over http"
	    alrb_fn_menuLine " lsetup gcc" " GCC complier"
	    alrb_fn_menuLine " lsetup git" " git version control"
	    alrb_fn_menuLine " lsetup gitlab" " git repo manager"
	    alrb_fn_menuLine " lsetup hdf5" " hdf5: hierarchical data format tools"
	    alrb_fn_menuLine " lsetup python" " Python interpreter"
	    alrb_fn_menuLine " lsetup views" " Set up an LCG release (caution !)"
	fi
    fi

    return 0
}


