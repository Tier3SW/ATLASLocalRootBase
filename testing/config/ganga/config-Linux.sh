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
## ganga configurations:

##
## ALRB_gangaVersion=version to test 
if [ -z "$ALRB_gangaVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_gangaVersion="testing"
    fi
fi


