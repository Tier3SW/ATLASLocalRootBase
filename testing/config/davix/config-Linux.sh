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
## davix configurations:

##
## ALRB_davixVersion=version to test 
if [ -z "$ALRB_davixVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_davixVersion="testing"
    fi
fi


