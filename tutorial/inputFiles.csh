#!----------------------------------------------------------------------------
#!
#! inputFiles.csh
#!
#! check the inputFiles are correct
#!
#! Usage:
#!     inputFiles.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

$ATLAS_LOCAL_ROOT_BASE/tutorial/checkInput.sh 
if ( $? != 0 ) then
    set alrb_errorFound="YES"        
endif

if ( "$alrb_errorFound" == "YES" ) then
    unset alrb_errorFound
    exit 64
endif

unset alrb_errorFound
exit 0
