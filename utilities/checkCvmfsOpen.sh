#! /bin/bash
#!----------------------------------------------------------------------------
#! 
#! checkCvmfsOpen.sh
#!
#! Check if cvmfs has an issue with opening files 
#!   reported on SL6 so we need this for early SL6 kernels
#!
#! Usage: 
#!     checkCvmfsOpen.sh --help
#!
#! History:
#!   17Jun13: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=checkCvmfsOpen.sh

#!----------------------------------------------------------------------------
alrb_fn_checkCvmfsOpenHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF
Usage: checkCvmfsOpen.sh [options]

    Check if cvmfs has an issue with open()
      This is reported on SL6 early kernels

    Options (to override defaults) are:
     -h  --help               Print this help message
     --quiet                  No messages; only indication is exit code

return code: 0: OK, non-zero: error 
EOF
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h,v" 
alrb_longopts="help,quiet"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_quietVal="NO"
while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_checkCvmfsOpenHelp
            exit 0
            ;;
        --quiet)
	    alrb_quietVal="YES"
	    shift
            ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

if [ -z $ATLAS_LOCAL_ROOT_BASE ]
then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

alrb_retCode=0

mkdir -p $ALRB_SCRATCH/cvmfs
alrb_testDir=`\mktemp -d $ALRB_SCRATCH/cvmfs/cvmfsOpenXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "Error: unable to create fir in $ALRB_SCRATCH/cvmfs"
    exit 64
fi
\rm -f $alrb_testDir/test.c

\cat <<EOF > $alrb_testDir/test.c
// Test the behavior of open() with O_RDONLY|O_CREAT flags.
// The expected output is a file descriptor >= 0.
// Requires CernVM-FS configured for the atlas.cern.ch repository

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int main() {
  int fd = open("$ALRB_cvmfs_repo/../.cvmfsdirtab", O_RDONLY | O_CREAT, 0666);
  int error = errno;

  printf("number of File Descriptors is %d, ERROR is %d\n", fd, error);
  return error;
}
EOF

if [ ! -e $alrb_testDir/test.c ]; then
    \echo "unable to find test.c; exiting."
    \rm -rf $alrb_testDir
    exit 64
fi
cd $alrb_testDir
\rm -f a.out
g++ test.c
alrb_tmpVal=`./a.out`
alrb_retCode=$?
\rm -f a.out test.c
if [ "$alrb_quietVal" != "YES" ]; then
    \echo "$alrb_tmpVal"
fi

\rm -rf $alrb_testDir
 
exit $alrb_retCode
