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
## xrootd configurations:

##
## ALRB_xrootdVersion=version to test 
if [ -z "$ALRB_xrootdVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_xrootdVersion="testing"
    fi
fi


