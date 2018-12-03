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

alias localSetupPython 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/oldAliasSetup.csh python'
alias atlasLocalPythonSetup 'localSetupPython' # backward compatibility

set alrb_AvailableTools="$alrb_AvailableTools python"

exit 0
