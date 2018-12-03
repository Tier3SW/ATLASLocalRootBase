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
## eiclient configurations:

##
## ALRB_eiclientVersion=version to test 
if [ -z "$ALRB_eiclientVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_eiclientVersion="testing"
    fi
fi


