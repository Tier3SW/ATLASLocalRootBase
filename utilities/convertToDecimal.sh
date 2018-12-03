#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#!  convertToDecimal.sh
#!
#!  Given an arg, convert it to a decimal number for comparisons
#!
#!  Usage:
#!     convertToDecimal.sh --help
#!
#!  History:
#!    21Jan2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_progname=convertToDecimal.sh

#!----------------------------------------------------------------------------
print_help()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage:  convertToDecimal.sh <string> <number of sig figures> [ options ]

    Convert the arg to a decimal so that it can be used un numerical comparisons

    Options (to override defaults) are:
     -h  --help                   Print this help message
     --separator=char             Separator to parse; default=.

    Returns exit code 0 if successful, non-zero otherwise.

EOF
}



#!----------------------------------------------------------------------------
#! main
#!----------------------------------------------------------------------------

alrb_shortopts="h"
alrb_longopts="help,separator:"
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

alrb_separatorVal="."

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
	--separator)
	    alrb_separatorVal=$2
            shift 2
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

alrb_strToParse=$1
let alrb_sigFigs=$2

alrb_tmpStr="\echo $alrb_strToParse | \grep -o \"\\$alrb_separatorVal\" | \wc -l | \sed -e 's/ //g'"
let alrb_charLimit=`eval $alrb_tmpStr`
if [ $alrb_charLimit -eq 0 ]; then
    \echo "Error: $alrb_strToParse does not have $alrb_separatorVal"
    exit 64
fi
let alrb_charLimit+=1
if [ $alrb_charLimit -lt $alrb_sigFigs ]; then
    \echo "Error: argument $alrb_strToParse does not have enough delimiters $alrb_separatorVal"
    exit 64
fi


let alrb_pos=1
let alrb_resultVal=0
while [[ "$alrb_strToParse" != "" ]] && [[ $alrb_pos -le $alrb_sigFigs ]]; do
  alrb_numVal=`\echo $alrb_strToParse | \cut -d $alrb_separatorVal -f 1`
  let alrb_resultVal=`expr $alrb_resultVal \* 100 + $alrb_numVal`
  alrb_strToParse=`\echo $alrb_strToParse | \cut -d $alrb_separatorVal -f 2-`
  let alrb_pos++;
done

\echo $alrb_resultVal

unset alrb_longopts alrb_numVal alrb_opts alrb_progname alrb_result alrb_returnVal alrb_separatorVal alrb_shortopts alrb_strToParse alrb_tmpStr alrb_charLimit alrb_pos alrb_resultVal alrb_sigFigs

exit 0

