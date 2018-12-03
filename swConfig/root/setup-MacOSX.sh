#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup root for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_rootVirtVersion=$1
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	rVer)
	    alrb_rootRealVersion=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
	cmt)
	    rootCmtConfig=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
	xrdMin)
	    alrb_rootXrdMinVer=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

# check if root is already available
alrb_oldRootSys="NONEXISTINGROOTSYS"
if [ ! -z ${ROOTSYS} ]; then
    alrb_result=`\echo $ROOTSYS | \grep ATLASLocalRootBase`
    if [ $? -eq 0 ]; then
	alrb_oldRootSys=$ROOTSYS
    fi
fi

export ATLAS_LOCAL_CERNROOT_VERSION=$alrb_rootRealVersion
export ROOTSYS=${ATLAS_LOCAL_ROOT}/root/${ATLAS_LOCAL_CERNROOT_VERSION}


deletePath PATH $alrb_oldRootSys/bin
insertPath PATH $ROOTSYS/bin

if [ -z "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=$ROOTSYS/lib
else
    deletePath LD_LIBRARY_PATH $alrb_oldRootSys/lib
    insertPath LD_LIBRARY_PATH $ROOTSYS/lib
fi

if [ -z "${DYLD_LIBRARY_PATH}" ]; then
    export DYLD_LIBRARY_PATH=$ROOTSYS/lib
else
    deletePath DYLD_LIBRARY_PATH $alrb_oldRootSys/lib
    insertPath DYLD_LIBRARY_PATH $ROOTSYS/lib
fi

if [ -z "${PYTHONPATH}" ]; then
    export PYTHONPATH=$ROOTSYS/lib
else
    deletePath PYTHONPATH $alrb_oldRootSys/lib
    insertPath PYTHONPATH $ROOTSYS/lib
fi

if [ -z "${MANPATH}" ]; then
    export MANPATH=$ROOTSYS/man
else
    deletePath MANPATH $alrb_oldRootSys/man
    insertPath MANPATH $ROOTSYS/man
fi

export rootCmtConfig

unset alrb_oldRootSys alrb_result alrb_rc alrb_tmpAr alrb_item alrb_tmpVal alrb_rootRealVersion 


