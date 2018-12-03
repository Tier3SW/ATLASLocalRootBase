#!----------------------------------------------------------------------------
#!
#! config-Linux.sh 
#!
#! configs for tool testing
#!
#! Usage:
#!     not directly
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------
##
## emi configurations:

##
## ALRB_emiVersion=version to test 
if [ -z "$ALRB_emiVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_emiVersion="testing"
    fi
fi





