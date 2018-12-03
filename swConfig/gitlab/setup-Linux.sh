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

export ATLAS_LOCAL_GITLAB_VERSION=$1
export ATLAS_LOCAL_GITLAB_PATH=${ATLAS_LOCAL_ROOT}/gitlab/${ATLAS_LOCAL_GITLAB_VERSION}

alrb_tmpVal=`\find $ATLAS_LOCAL_GITLAB_PATH -type d -name lib`
if [ -z "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=$alrb_tmpVal
else
    insertPath LD_LIBRARY_PATH $alrb_tmpVal
fi

alrb_tmpVal=`\find $alrb_tmpVal -type d -name site-packages`
if [ -z "${PYTHONPATH}" ]; then
    export PYTHONPATH=$alrb_tmpVal
else
    insertPath PYTHONPATH $alrb_tmpVal
fi

alrb_tmpVal=`\find $ATLAS_LOCAL_GITLAB_PATH -type d -name bin`
if [ $? -eq 0 ]; then
 insertPath PATH $alrb_tmpVal
fi

unset alrb_tmpVal



