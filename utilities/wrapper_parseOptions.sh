#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! wrapper_parseOptions.sh
#!
#! A wrapper script to provide consistent arg parsing
#!
#! Usage: 
#!     wrapper_parseOptions.sh <shell> <shortopts> <longopts> <progname> <args>
#!
#! For bash/zsh, return delimited string of parsed options and args
#!  usage: wrapper_parseOptions.sh bash $SHORTOPTS $LONGOPTS $progname "$@"
#! For tcsh, return a limk to a tmp file which should be sourced to setup 
#!   the array alrb_opts; client responsible to delete dir pointed by alrb_tempDir.
#!  usage: wrapper_parseOptions.sh bash $SHORTOPTS $LONGOPTS $progname $*:q
#!
#! History:
#!   10Sep15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_shell=$1
alrb_shortopts=$2
alrb_longopts=$3
alrb_prog=$4
shift 4

alrb_result=`getopt -T >/dev/null 2>&1`
if [ $? -eq 4 ] ; then # New longopts getopt.
    alrb_opts=$(getopt -o $alrb_shortopts --long $alrb_longopts -n "$alrb_prog" -- "$@")
    alrb_returnVal=$?
else # use wrapper
    alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_getopt_parser.py $alrb_shortopts $alrb_longopts "$@"`
    alrb_returnVal=$?
    if [ $alrb_returnVal -ne 0 ]; then
	\echo $alrb_opts 1>&2
    fi
fi

# do we have an error here ?
if [ $alrb_returnVal -ne 0 ]; then
    \echo "'$alrb_prog --help' for more information" 1>&2
    exit 1
fi


if [ "$alrb_shell" = "tcsh" ]; then
    if [ -z $ALRB_tmpScratch ]; then
	alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh tmp`
	if [ $? -eq 0 ]; then
	    export ALRB_tmpScratch=$alrb_tmpVal
	fi
    fi
    alrb_lsWorkdir="${ALRB_tmpScratch}/localSetup"
    \mkdir -p $alrb_lsWorkdir
    alrb_rc=$?
    if [ $alrb_rc -ne 0 ]; then
	unset alrb_lsWorkdir
	exit $alrb_rc
    fi
    alrb_lsWorkarea=`\mktemp -d $alrb_lsWorkdir/ls.XXXXXX`
    if [ $? -ne 0 ]; then
	exit 64
    fi
    \echo "set alrb_tempDir=$alrb_lsWorkarea" > ${alrb_lsWorkarea}/parse.csh
    \echo "set alrb_opts=( " ${alrb_opts[@]} " )" >> ${alrb_lsWorkarea}/parse.csh
    \echo "${alrb_lsWorkarea}/parse.csh"    
else
    \echo ${alrb_opts[*]}
fi

exit 0
