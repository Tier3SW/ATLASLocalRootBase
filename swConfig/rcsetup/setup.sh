#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script rcsetup for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

function rcSetup
{
    \echo "Warning: rcSetup is depreciated.  This sets up old ASG releases; please use asetup to setup analysis releases instead"
    source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh $@
    return $?
}

function rcsetup
{
    rcSetup $@
    return $?
}

export ATLAS_LOCAL_RCSETUP_VERSION=$1
deletePath PATH $ATLAS_LOCAL_RCSETUP_PATH
export ATLAS_LOCAL_RCSETUP_PATH=${ATLAS_LOCAL_ROOT}/rcSetup/${ATLAS_LOCAL_RCSETUP_VERSION}
if [ "$ALRB_RELOCATECVMFS" = "YES" ]; then
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/rcsetup/relocateCvmfs.sh
fi
export rcSetup=$ATLAS_LOCAL_RCSETUP_PATH
#alias rcSetup='source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh'
#alias rcsetup='rcSetup'
alrb_tmpVal=`alias rcSetup 2>&1`
if [ $? -eq 0 ]; then
    unalias rcSetup
fi
alrb_tmpVal=`alias rcsetup 2>&1`
if [ $? -eq 0 ]; then
    unalias rcsetup
fi

shift

if [ -z $ALRB_initialSetup ]; then
    eval source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh $@
    return $?       
fi

#if [[ "$#" -ge 2 ]] && [[ "$2" != "" ]] ; then
#    shift
#    eval source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh $@
#    return $?    
#fi

unset alrb_tmpVal

return 0


