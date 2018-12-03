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
## git configurations:

##
## ALRB_gitVersion=version to test 
if [ -z "$ALRB_gitVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_gitVersion="testing"
    fi
fi


