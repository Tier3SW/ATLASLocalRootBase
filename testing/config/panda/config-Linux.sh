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
## panda configurations:

##
## ALRB_pandaVersion=version to test 
if [ -z "$ALRB_pandaVersion" ]; then
    if [ "$alrb_Mode" = "test" ]; then
	export ALRB_pandaVersion="testing"
    fi
fi

##
## ALRB_testPandaDataset= for a dataset to use
export ALRB_testPandaDataset="mc15_13TeV:mc15_13TeV.423202.Pythia8B_A14_CTEQ6L1_Jpsie3e13.merge.AOD.e3869_s2608_s2183_r6630_r6264*"




