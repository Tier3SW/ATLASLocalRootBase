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
## agis configurations:

##
## ALRB_agisVersion=version to test 
if [ -z "$ALRB_agisVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_agisVersion="testing"
    fi
fi


