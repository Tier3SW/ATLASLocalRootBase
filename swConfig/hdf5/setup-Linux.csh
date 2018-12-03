#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup hdf5 for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_HDF5_VERSION $1

set alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/hdf5/$ATLAS_LOCAL_HDF5_VERSION -type d -name bin`
setenv ALRB_HDF5_PATH `$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_tmpVal/..`

insertPath PATH "$ALRB_HDF5_PATH/bin"

if ( ! $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH "$ALRB_HDF5_PATH/lib"
else
    insertPath LD_LIBRARY_PATH "$ALRB_HDF5_PATH/lib"
endif

unset alrb_tmpVal