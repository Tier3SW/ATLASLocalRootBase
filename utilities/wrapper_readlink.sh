#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! A wrapper to mimic Linux bash readlink -e
#! (this is primarily for MacOSX which cannot otherwise handle it) 
#!
#! Usage:
#!    wrapper_readlink.sh file
#!
#! History:
#!   17Mar14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname="wrapper_readlink"

alrb_fn_wrapperReadLinkHelp()
{
    \cat <<EOF

Usage: wrapper_readlink.sh [options] <path>

    This mimics readlink (default readlink -e)

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help                   Print this help message
     --basename                   Do not print the full path

EOF
}


alrb_shortopts="h"
alrb_longopts="help,basename"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_basenameVal=0

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_wrapperReadLinkHelp
            exit 0
            ;;
        --basename)
	    alrb_basenameVal=1
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

alrb_myArgVal=""
if [ "$*" != "" ]; then
    alrb_myArgVal=`\echo $* | \cut -f 1 -d " "`
else
    \echo "Error: argument not provided !"
    exit 64
fi

let alrb_retCode=0

if [ -z $ALRB_OSTYPE ]; then
    alrb_osInfo=`$ATLAS_LOCAL_ROOT_BASE/utilities/getOSType.sh`
    ALRB_OSTYPE=`\echo $alrb_osInfo | \cut -f 1 -d " "`    
fi

if [ "$ALRB_OSTYPE" = "MacOSX" ]; then
# with thanks to Shuwei Ye for this next line
    alrb_tmpFile=`python -c 'from __future__ import print_function;import os,sys;print(os.path.realpath(sys.argv[1]))' $alrb_myArgVal`
    if [[ -h $alrb_tmpFile ]] || [[ ! -e $alrb_tmpFile ]]; then
	let alrb_retCode=1
    else
	if [ $alrb_basenameVal -eq 0 ]; then
	    \echo $alrb_tmpFile
	else
	    basename $alrb_tmpFile
	fi
    fi
else
    if [ $alrb_basenameVal -eq 0 ]; then
	\readlink -e $alrb_myArgVal
    else
	\readlink $alrb_myArgVal
    fi
    alrb_retCode=$?
fi

exit $alrb_retCode
