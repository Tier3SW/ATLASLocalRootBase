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
## root configurations:

##
## ALRB_rootVersion=version to test 

if [ -z $ALRB_rootVersion ]; then
    export ALRB_rootVersion="recommended"
fi



