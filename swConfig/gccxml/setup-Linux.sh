#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup gccxml for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_GCCXML_VERSION=$1
export ATLAS_LOCAL_GCCXML_PATH=${ATLAS_LOCAL_ROOT}/gccxml/${ATLAS_LOCAL_GCCXML_VERSION}

alrb_gccxmlBin=`\find $ATLAS_LOCAL_GCCXML_PATH -name bin -type d`
if [ -d "${alrb_gccxmlBin}" ]; then
    insertPath PATH $alrb_gccxmlBin
else
    \echo "Error: bin dir for gccxml not found in $ATLAS_LOCAL_GCCXML_PATH ..." 1>&2
fi

unset alrb_gccxmlBin
