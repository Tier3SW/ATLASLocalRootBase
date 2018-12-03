#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup git for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_GIT_VERSION=$1
export ATLAS_LOCAL_GIT_PATH=${ATLAS_LOCAL_ROOT}/git/${ATLAS_LOCAL_GIT_VERSION}

if [ -e $ATLAS_LOCAL_GIT_PATH/setup.sh ]; then
    source $ATLAS_LOCAL_GIT_PATH/setup.sh 
else

    insertPath PATH $ATLAS_LOCAL_GIT_PATH/bin

    insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_GIT_PATH/lib64

    insertPath MANPATH $ATLAS_LOCAL_GIT_PATH/share/man

    export GIT_EXEC_PATH=$ATLAS_LOCAL_GIT_PATH/libexec/git-core
fi
