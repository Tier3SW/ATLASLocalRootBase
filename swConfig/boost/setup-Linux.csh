#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup boost for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_BOOST_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/boost/$ATLAS_LOCAL_BOOST_VERSION -type d -name lib`
if ( $? != 0 ) then
    \echo "   Error: Could not find boost lib dir" > /dev/stderr
    exit 64
endif
if ( ! $?LD_LIBRARY_PATH ) then
    setenv  LD_LIBRARY_PATH $alrb_tmpVal
else
    insertPath LD_LIBRARY_PATH $alrb_tmpVal
endif

set ALRB_BOOST_ROOT=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

setenv ALRB_BOOST_ROOT $ALRB_BOOST_ROOT

unset alrb_tmpVal
