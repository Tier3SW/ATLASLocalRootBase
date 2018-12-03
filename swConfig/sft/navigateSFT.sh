#! /bin/bash
#!----------------------------------------------------------------------------
#! 
#! navigateSFT.sh
#!
#! figure out how to setup the SFT dir packages
#!
#! Usage: 
#!     navigateSFT.sh --help
#!
#! History:
#!   03Feby14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname="navigateSFT.sh"

#!----------------------------------------------------------------------------
alrb_fn_navigateSftHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF
Usage: navigateSFT.sh [options] <package> <cmtconfig> <pythonVersion>

    Figures out how to setup the SFT dir packages

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --quiet                  No messages; only indication is exit code


return code: 0 if ok, non-zero if error.

prints out what to setup; output is of the form, delimited by "|"
  Header: H%$package%$version
  InsertPath: IP%PATH%bin
  source: S%tcsh%rivetenv.csh
  set env (path): EP%BOOST_INCLUDE%result 
  echo: EC%text
EOF
}


#!----------------------------------------------------------------------------
doMy_Boost()
#!----------------------------------------------------------------------------
{
doMy_Generic

alrb_result=`\find include  -maxdepth 2 -mindepth 2 -name boost -type d`
if [[ $? -eq 0 ]] && [[ "$alrb_result" != "" ]] ; then
    alrb_myResult="$alrb_myResult|EP%SFT_BOOST_INCLUDE%$alrb_result"
    alrb_myResult="$alrb_myResult|EC%The env "'$SFT_BOOST_INCLUDE'" is the include dir"
fi

return 0
}


#!----------------------------------------------------------------------------
doMy_rivet()
#!----------------------------------------------------------------------------
{

if [ -e rivetenv.csh ] ; then
    alrb_myResult="$alrb_myResult|S%tcsh%rivetenv.csh"
fi
if [ -e rivetenv.sh ] ; then
    alrb_myResult="$alrb_myResult|S%bash%rivetenv.sh"
    alrb_myResult="$alrb_myResult|S%zsh%rivetenv.sh"
fi

return 0
}


#!----------------------------------------------------------------------------
doMy_Generic()
#!----------------------------------------------------------------------------
{

if [ -d bin ]; then
    alrb_myResult="$alrb_myResult|IP%PATH%bin"
fi

# careful - reverse order here since client should first put 
#  64-bit in path (if it exists)

if [ -d lib ] ; then
    alrb_myResult="$alrb_myResult|IP%LD_LIBRARY_PATH%lib"

    alrb_arList=( `\find lib -name site-packages -type d` )
    alrb_candidate=""
    alrb_diffOld="-100"
    for alrb_item in ${alrb_arList[@]}; do
	alrb_result=`\echo $alrb_item | \grep "python$pythonVer"`
	if [ $? -eq 0 ]; then
	    alrb_candidate=$alrb_item
	    break
	else
	    alrb_thisPy=`\echo $alrb_item | \sed -e 's|.*python\(.*\)/.*|\1|g'`
	    alrb_diff=`\echo "$alrb_thisPy - $pythonVer" | bc`
	    alrb_condition1=`\echo "$alrb_diff < 0" | bc`
	    alrb_condition2=`\echo "$alrb_diff > $alrb_diffOld" | bc`
	    if [[ "$alrb_condition1" = "1" ]] && [[ "$alrb_condition2" = "1" ]]; then
		alrb_diffOld=$alrb_diff
		alrb_candidate=$alrb_item
	    fi
	fi
    done
    if [ "$alrb_candidate" != "" ]; then
	alrb_myResult="$alrb_myResult|IP%PYTHONPATH%$alrb_candidate"
    fi

    let alrb_npyfiles=`\find lib -maxdepth 1 -mindepth 1 -name "*.py" | wc -l`
    if [ $alrb_npyfiles -gt 0 ]; then
	alrb_myResult="$alrb_myResult|IP%PYTHONPATH%$lib"
    fi
fi

if [ -d lib64 ] ; then
    alrb_myResult="$alrb_myResult|IP%LD_LIBRARY_PATH%lib64"

    alrb_arList=( `\find lib64 -name site-packages -type d` )
    alrb_candidate=""
    alrb_diffOld="-100"
    for alrb_item in ${alrb_arList[@]}; do
	alrb_result=`\echo $alrb_item | \grep "python$pythonVer"`
	alrb_rc=$?
	if [ $alrb_rc -eq 0 ]; then
	    alrb_candidate=$alrb_item
	    break
	else
	    alrb_thisPy=`\echo $alrb_item | \sed -e 's|.*python\(.*\)/.*|\1|g'`
	    alrb_diff=`\echo "$alrb_thisPy - $pythonVer" | bc`
	    alrb_condition1=`\echo "$alrb_diff < 0" | bc`
	    alrb_condition2=`\echo "$alrb_diff > $alrb_diffOld" | bc`
	    if [[ "$alrb_condition1" = "1" ]] && [[ "$alrb_condition2" = "1" ]]; then
		alrb_diffOld=$alrb_diff
		alrb_candidate=$alrb_item
	    fi
	fi
    done
    if [ "$alrb_candidate" != "" ]; then
	alrb_myResult="$alrb_myResult|IP%PYTHONPATH%$alrb_candidate"
    fi

    let alrb_npyfiles=`\find lib64 -maxdepth 1 -mindepth 1 -name "*.py" | wc -l`
    if [ $alrb_npyfiles -gt 0 ]; then
	alrb_myResult="$alrb_myResult|IP%PYTHONPATH%$lib64"
    fi

fi


return 0

}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_exitCode=0
alrb_myResult=""

alrb_shortopts="h,v" 
alrb_longopts="help,quiet"
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

alrb_quiet="NO"
while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_navigateSftHelp
            exit 0
            ;;
        --quiet)
	    alrb_quiet="YES"
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

let alrb_numVars=$#
if [ $alrb_numVars -lt 3 ]; then
    alrb_fn_navigateSftHelp
    \echo "Error: Incorrect number of arguments" 1>&2
    exit 64
fi

alrb_pkgPath=$1
alrb_cmtConfig=$2
alrb_pythonVer=$3

if [ -z $ATLAS_LOCAL_ROOT_BASE ]; then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set" 1>&2
    exit 64
fi

if [ -e ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh ]; then
    source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh
else
    \echo "Missing ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh" 1>&2
    exit 64
fi

# this should already be defined 
if [ "$ALRB_SFT_LCG" = "none" ]; then
    \echo "Error: cvmfs sft repo is missing" 1>&2
    exit 64
fi

alrb_fullPath="$ALRB_SFT_LCG/$alrb_pkgPath/$alrb_cmtConfig"

if [ ! -d $alrb_fullPath ]; then
    \echo "Error: $alrb_fullPath does not exist."  1>&2
    exit 64
fi
cd $alrb_fullPath

alrb_tmpAr=( `\echo $alrb_pkgPath | \sed -e 's|/| |g'` )
alrb_package=`\echo ${alrb_tmpAr[@]:(-2):(1)}`
alrb_version=`\echo ${alrb_tmpAr[@]:(-1)}`

alrb_myResult="H%$alrb_package%$alrb_version"

alrb_myCmd="doMy_$alrb_package"
alrb_result=`type -t $alrb_myCmd`
if [ "$alrb_result" = "function" ]; then
    eval $alrb_myCmd
else
    doMy_Generic    
fi
alrb_exitCode=$?

if [ "$alrb_exitCode" = "0" ]; then
    \echo $alrb_myResult
fi

exit $alrb_exitCode


