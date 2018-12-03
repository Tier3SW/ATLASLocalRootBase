#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup acm for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_ACM_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/acm/${ATLAS_LOCAL_ACM_VERSION} -type d -name bin`
export ALRB_ACM_PATH=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

alrb_tmpVal=`alias acmSetup 2>&1`
if [ $? -eq 0 ]; then
    unalias acmSetup
fi

function acmSetup
{
    source $ALRB_ACM_PATH/acmSetup.sh $@
    return $?
}


unset alrb_tmpVal

