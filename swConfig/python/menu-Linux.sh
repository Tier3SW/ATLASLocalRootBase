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

alias localSetupPython='source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.sh python'
alias atlasLocalPythonSetup='localSetupPython' # backward compatibility

alrb_AvailableTools="$alrb_AvailableTools python"


return 0
