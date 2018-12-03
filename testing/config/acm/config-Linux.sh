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
## acm configurations:

##
## ALRB_acmVersion=version to test 
if [ -z "$ALRB_acmVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_acmVersion="testing"
    fi
fi


##
## alrb_acmAthenaRel=Release version to setup
alrb_acmAthenaRel="AthAnalysis,21.2.39"
