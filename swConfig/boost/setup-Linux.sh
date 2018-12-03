#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup boost for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_BOOST_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/boost/$ATLAS_LOCAL_BOOST_VERSION -type d -name lib`
if [ $? -ne 0 ]; then
    \echo "   Error: Could not find boost lib dir" 1>&2
    return 64
fi
if [ -z "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=$alrb_tmpVal
else
    insertPath LD_LIBRARY_PATH $alrb_tmpVal
fi

ALRB_BOOST_ROOT=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

export ALRB_BOOST_ROOT

unset alrb_tmpVal
