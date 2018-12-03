#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#!  getCurrentEnvVal.sh
#!
#!  Extract information from the putput of getCurrentEnv
#!
#!  Usage:
#!    getCurrentEnvVal --help
#!
#!  History:
#!    21Jan2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_progname=getCurrentEnvVal.sh

#!----------------------------------------------------------------------------
print_help()
#!----------------------------------------------------------------------------
{
\cat <<EOF

Usage: getCurrentEnvVal.sh <env string> <values to extract>

    Extract values frm <env string> which is the output of getCurrentEnv.*sh

    Requirements:
     You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help                   Print this help message
     --decimal=X                  Print out version for comparisons  to X significant figs.
     --nodot=X                    Print out version to X significant figs without separators

    Values to extract are of the form <key>:<value> where
      key = python|gcc
      value= ver|arch

    Returns exit code 0 if found, non-zero otherwise.

EOF
}



#!----------------------------------------------------------------------------
#! main
#!----------------------------------------------------------------------------

alrb_shortopts="h"
alrb_longopts="help,decimal:,nodot:"
alrb_result=`getopt -T >/dev/null 2>&1`
if [ $? -eq 4 ] ; then # New longopts getopt.
    alrb_opts=$(getopt -o $alrb_shortopts --long $alrb_longopts -n "$alrb_progname" -- "$@")
    alrb_returnVal=$?
else # use wrapper
    alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_getopt.py $alrb_shortopts $alrb_longopts $*`
    alrb_returnVal=$?
    if [ $alrb_returnVal -ne 0 ]; then
	\echo $alrb_opts
    fi
fi

# do we have an error here ?
if [ $alrb_returnVal -ne 0 ]; then
    \echo "'$alrb_progname --help' for more information" 1>&2
    exit 1
fi

eval set -- "$alrb_opts"

let alrb_decimalVal=0
let alrb_nodotVal=0

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
	--decimal)
	    let alrb_decimalVal=$2
            shift
            shift
	    ;;
	--nodot)
	    let alrb_nodotVal=$2
            shift
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

if [ $# -ne 2 ]; then
    \echo "Error: incorrect arguments ... type --help"
    exit 64
fi

alrb_envStr=$1
alrb_extractVar=$2

alrb_key=`\echo $alrb_extractVar | \cut -f 1 -d ":"`
alrb_val=`\echo $alrb_extractVar | \cut -f 2 -d ":"`

alrb_result="Failed: Cannot find $alrb_extractVar in $alrb_envStr"
alrb_exitCode=64

alrb_envStr1=`\echo ${alrb_envStr#*$alrb_key} | \cut -f 1 -d ";"`
alrb_envStr2=`\echo ${alrb_envStr1#*$alrb_val=} | \cut -f 1 -d ":"`
if [[ "$alrb_envStr1" != "" ]] && [[ "$alrb_envStr2" != "" ]]; then
    alrb_result=$alrb_envStr2
    alrb_exitCode=0
fi

if [ $alrb_nodotVal -gt 0 ]; then
    alrb_result=`\echo $alrb_result | \cut -f 1-$alrb_nodotVal -d "." | \sed -e 's/\.//g'`
elif [ $alrb_decimalVal -gt 0 ]; then
     alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_result $alrb_decimalVal`
fi

\echo $alrb_result

exit $alrb_exitCode

