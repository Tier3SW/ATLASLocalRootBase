#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script rcsetup for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_RCSETUP_VERSION $1
if ( $?ATLAS_LOCAL_RCSETUP_PATH ) then
    deletePath PATH $ATLAS_LOCAL_RCSETUP_PATH
endif
setenv ATLAS_LOCAL_RCSETUP_PATH ${ATLAS_LOCAL_ROOT}/rcSetup/${ATLAS_LOCAL_RCSETUP_VERSION}

if ( "$ALRB_RELOCATECVMFS" == "YES" ) then
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/rcsetup/relocateCvmfs.csh
endif
setenv rcSetup $ATLAS_LOCAL_RCSETUP_PATH
alias rcSetup '\echo "Warning: rcSetup is depreciated.  This sets up old ASG releases; please use asetup to setup analysis releases instead"; source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.csh'
alias rcsetup 'rcSetup'

shift

if ( ! $?ALRB_initialSetup ) then
    source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.csh $* 
    exit $?
endif

#if (( $#argv >= 2 ) && ( "$2" != "" )) then
#    shift
#    source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.csh $* 
#    exit $?
#endif

