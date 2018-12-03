#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup hdf5 for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_HDF5_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/hdf5/$ATLAS_LOCAL_HDF5_VERSION -type d -name bin`
export ALRB_HDF5_PATH=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

insertPath PATH "$ALRB_HDF5_PATH/bin"

if [ -z $LD_LIBRARY_PATH ]; then
    export LD_LIBRARY_PATH="$ALRB_HDF5_PATH/lib"
else
    insertPath LD_LIBRARY_PATH "$ALRB_HDF5_PATH/lib"
fi




unset alrb_tmpVal
