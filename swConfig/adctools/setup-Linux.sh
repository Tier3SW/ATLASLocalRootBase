#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup adctools for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_ADCTOOLS_VERSION=$1

alrb_binDirVal=`\find $ATLAS_LOCAL_ROOT/adctools/$ATLAS_LOCAL_ADCTOOLS_VERSION -type d -name bin`

export ATLAS_ADC_TOOLSDIR=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_binDirVal/..`
source $ATLAS_ADC_TOOLSDIR/setup.sh

unset alrb_binDirVal

return 0
