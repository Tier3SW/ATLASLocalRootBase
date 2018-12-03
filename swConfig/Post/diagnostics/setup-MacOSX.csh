#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup diagnostics for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ALRB_diagnostics "YES"

alias checkOS '${ATLAS_LOCAL_ROOT_BASE}/utilities/installCheck.sh'
alias supportInfo 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/generateDumpFile.csh'

if ( ! $?alrb_Quiet ) then
    set alrb_Quiet=""
endif

if ( "$alrb_Quiet" != "YES" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh diagnostics 2 Post
endif

if ( "$alrb_Quiet" == "" ) then
    unset alrb_Quiet
endif
