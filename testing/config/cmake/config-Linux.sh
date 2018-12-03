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
## cmake configurations:

##
## ALRB_cmakeVersion=version to test 
if [ -z "$ALRB_cmakeVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_cmakeVersion="testing"
    fi
fi





