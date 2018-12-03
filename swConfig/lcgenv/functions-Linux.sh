#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for lcgenv
#!
#!  History:
#!    09Oct2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fb_lcgenvHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for lcgenv

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    For asetup help, type "lcgenv --help"

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
}


alrb_fn_lcgenvVersionConvert()
{
# 2 significant figures 
#    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $1 2 --separator="."

# ads, 14Apr2016
# ignoring this as the versioning is not under our control and the developers use HEAD and versioning which are inconsistent.
    \echo "0"

    return $?
}


alrb_fn_lcgenvDepend()
{
    local alrb_sw="lcgenv"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"

    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi
    
    local alrb_shortopts="h,q,s,f,c:"
    local alrb_longopts="help,quiet,skipConfirm,force"
    local alrb_opts
    local alrb_result
    alrb_result=`getopt -T >/dev/null 2>&1`
    if [ $? -eq 4 ] ; then # New longopts getopt.
	alrb_opts=$(getopt -o $alrb_shortopts --long $alrb_longopts -n "$alrb_progname" -- "$@")
	local alrb_returnVal=$?
    else # use wrapper
	alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_getopt.py $alrb_shortopts $alrb_longopts $*`
	local alrb_returnVal=$?
    fi
    
# do we have an error here ?
    if [ $alrb_returnVal -ne 0 ]; then
	\echo $alrb_opts 1>&2
	\echo "'lsetup \"$alrb_sw --help\"' for more information" 1>&2
	return 1
    fi
    
    eval set -- "$alrb_opts"
    
    local alrb_caller="unknown"
# version is the latest and not under our control
    local alrb_swVersion="latest"
# but users can override that if really needed    
    if [ ! -z $ALRB_lcgenvVersion ]; then
	local alrb_swVersion=$ALRB_lcgenvVersion
    fi
    local alrb_passThrough=""
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
#		alrb_fb_asetupHelp
#		return 0
		shift
		;;
            -c|--caller)
		local alrb_caller=$2
		shift 2
		;;
	    -q|--quiet)	    
		shift
		;;
	    -s|--skipConfirm)	    
		shift
		;;
            -f|--force)    
		shift
		;;
	    --)
		shift
		break
		;;
            *)
		\echo "Internal Error: option processing error: $1" 1>&2
		return 1
		;;
	esac
    done
 
    export LCGENV_PATH=$ALRB_SFT_LCG/releases
   
    alrb_result=`\echo $alrb_CandToolArg | \grep -w -e "-h" -e "--help" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_addHelp=( ${alrb_addHelp[@]} "$LCGENV_PATH/lcgenv/$alrb_swVersion/lcgenv -h" ) 
	return 0
    fi

    alrb_result=`\echo $alrb_CandToolArg | \grep -w -e "-p" -e "--lcgpath" -e "-v" -e "--version" 2>&1`
    if [ $? -ne 0 ]; then
	\echo "Error (lcgenv): you need to specify a LCG release with the \"-p LCG_<version>\" option" 1>&2
	\echo "  Possibilities are: " 1>&2
	\find  $ALRB_SFT_LCG/releases -maxdepth 1 -name "LCG_*" | \sed -e 's|.*/releases/||g' | env LC_ALL=C  \sort -u 1>&2
	return 64
    fi
#lcgenv --version returns versions which do not match dir name (eg HEAD) which
#  developers use; so ignore this.
#    local alrb_setVer=`$LCGENV_PATH/lcgenv/$alrb_swVersion/lcgenv --version 2>&1 | \cut -f 2 -d " "`
    local alrb_setVer=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $LCGENV_PATH/lcgenv/$alrb_swVersion | \rev | \cut -d "/" -f 1 | \rev`
    alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_setVer" -c "$alrb_swVersion"
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_lcgenvSetupFile="${alrb_lsWorkarea}/do_lcgenv${alrb_setupScriptExt}"
    touch $alrb_lcgenvSetupFile

    if [ "$alrb_Quiet" = "NO" ]; then
	\echo "\echo \"  lcgenv $alrb_CandToolArg ...\"" >> $alrb_lcgenvSetupFile
	$LCGENV_PATH/lcgenv/$alrb_swVersion/lcgenv -s $ALRB_clientShell -i Grid $alrb_CandToolArg | \sed -e 's|\(^#.*\)|\\echo "\1"|g' >> $alrb_lcgenvSetupFile
    else
	$LCGENV_PATH/lcgenv/$alrb_swVersion/lcgenv -s $ALRB_clientShell -i Grid $alrb_CandToolArg >> $alrb_lcgenvSetupFile
    fi
    
    alrb_lcgenv_extra="$alrb_lcgenvSetupFile"
    
    return 0    
}


alrb_fn_lcgenvFilterArgs()
{
    alrb_ToolOpts=${alrb_ToolOpts/$alrb_CandToolArg/}
    return $?
}