#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup PoD for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_POD_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/PoD/$ATLAS_LOCAL_POD_VERSION -name bin -type d`
ALRB_POD_DIR=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`
export ALRB_POD_DIR

if [ "$ALRB_SHELL" = "zsh" ]; then
# temporary fix to accomodate zsh
    alrb_myOldDir=`pwd`
    cd $ALRB_POD_DIR
fi

source $ALRB_POD_DIR/PoD_env.sh

if [ "$ALRB_SHELL" = "zsh" ]; then
# ads, temporary fix to accomodate zsh
    cd $alrb_myOldDir
fi

alias generatePoDSetups='source $ATLAS_LOCAL_ROOT_BASE/swConfig/pod/generatePoDSetups.sh'

unset alrb_tmpVal alrb_myOldDir
