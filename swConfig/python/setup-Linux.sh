#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup pythom for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_PYTHON_VERSION=$1

alrb_pythonBinDir=`\find $ATLAS_LOCAL_ROOT/python/$ATLAS_LOCAL_PYTHON_VERSION -type d -name bin`
alrb_pythonLibDir=`\find $ATLAS_LOCAL_ROOT/python/$ATLAS_LOCAL_PYTHON_VERSION -type d -name lib`

insertPath PATH $alrb_pythonBinDir
if [ -z "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=$alrb_pythonLibDir
else
    insertPath LD_LIBRARY_PATH $alrb_pythonLibDir
fi
# to avoid compile time afs references which fail if afs does not exist 
if [ -z $LIBRARY_PATH ]; then
    export LIBRARY_PATH=$alrb_pythonLibDir
else
    insertPath LIBRARY_PATH $alrb_pythonLibDir
fi

unset alrb_pythonBinDir alrb_pythonLibDir

source $ATLAS_LOCAL_ROOT_BASE/swConfig/python/pythonFix-Linux.sh 

