#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup png for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


export ATLAS_LOCAL_PNG_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/png/${ATLAS_LOCAL_PNG_VERSION} -type d -name lib`
export ALRB_PNG_PATH=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

if [ -z $LD_LIBRARY_PATH ]; then
    export LD_LIBRARY_PATH="$ALRB_PNG_PATH/lib"
else
    insertPath LD_LIBRARY_PATH "$ALRB_PNG_PATH/lib"
fi

unset alrb_tmpVal

