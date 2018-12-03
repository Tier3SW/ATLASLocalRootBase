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
## pyami configurations:

##
## ALRB_pyamiVersion=version to test 
if [ -z "$ALRB_pyamiVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_pyamiVersion="testing"
    fi
fi


