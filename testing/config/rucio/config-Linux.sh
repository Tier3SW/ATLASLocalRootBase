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
## rucio configurations:

##
## ALRB_testRucioRseList="rucio sites to use in order of priority separated by ;"
if [ -z $ALRB_testRucioRseList ]; then
    export ALRB_testRucioRseList="TRIUMF-LCG2_SCRATCHDISK;CA-VICTORIA-WESTGRID-T2_SCRATCHDISK;CA-SFU-T2_SCRATCHDISK"
fi

##
## ALRB_rucioVersion=version to test 
if [ -z "$ALRB_rucioVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_rucioVersion="testing"
    fi
fi





