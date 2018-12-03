#!----------------------------------------------------------------------------
#!
#! inputFiles.sh
#!
#! check the inputFiles are correct
#!
#! Usage:
#!     inputFiles.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

$ATLAS_LOCAL_ROOT_BASE/tutorial/checkInput.sh
if [ $? -ne 0 ]; then
    alrb_errorFound="YES"        
fi

if [ "$alrb_errorFound" = "YES" ]; then
    unset alrb_errorFound 
    return 64
fi

unset alrb_errorFound
return 0

