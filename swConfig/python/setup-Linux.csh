#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup pythom for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_PYTHON_VERSION $1

set alrb_pythonBinDir=`\find $ATLAS_LOCAL_ROOT/python/$ATLAS_LOCAL_PYTHON_VERSION -type d -name bin`
set alrb_pythonLibDir=`\find $ATLAS_LOCAL_ROOT/python/$ATLAS_LOCAL_PYTHON_VERSION -type d -name lib`

insertPath PATH $alrb_pythonBinDir
if ( $?LD_LIBRARY_PATH ) then
    insertPath LD_LIBRARY_PATH $alrb_pythonLibDir
else
    setenv LD_LIBRARY_PATH $alrb_pythonLibDir
endif
# to avoid compile time afs references which fail if afs does not exist 
if ( $?LIBRARY_PATH ) then
    insertPath LIBRARY_PATH $alrb_pythonLibDir
else
    setenv LIBRARY_PATH $alrb_pythonLibDir
endif

unset alrb_pythonBinDir alrb_pythonLibDir

source $ATLAS_LOCAL_ROOT_BASE/swConfig/python/pythonFix-Linux.csh
