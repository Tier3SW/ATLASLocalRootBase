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
alias db-fnget '${ATLAS_LOCAL_ROOT_BASE}/utilities/fngetTest.sh'
alias db-readReal '${ATLAS_LOCAL_ROOT_BASE}/utilities/readRealTest.sh'
alias gridCert '${ATLAS_LOCAL_ROOT_BASE}/utilities/checkUserGrid.sh'
alias rseCheck '${ATLAS_LOCAL_ROOT_BASE}/utilities/checkRucioRSE.sh'
alias runKV '${ATLAS_LOCAL_ROOT_BASE}/utilities/runKV.sh'
alias setMeUp 'source ${ATLAS_LOCAL_ROOT_BASE}/tutorial/setMeUp.csh'
alias setMeUpData '${ATLAS_LOCAL_ROOT_BASE}/tutorial/fetchFiles.sh'
alias supportInfo 'source ${ATLAS_LOCAL_ROOT_BASE}/utilities/generateDumpFile.csh'
alias toolTest '${ATLAS_LOCAL_ROOT_BASE}/testing/tester.sh'

if ( ! $?alrb_Quiet ) then
    set alrb_Quiet=""
endif

if ( "$alrb_Quiet" != "YES" ) then
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh diagnostics 2 Post
endif

if ( "$alrb_Quiet" == "" ) then
    unset alrb_Quiet
endif
