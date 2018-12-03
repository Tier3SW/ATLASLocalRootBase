#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for views
#!
#!  History:
#!    09Oct2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fb_viewsHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for views

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    For help, type "lsetup views --help"

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
}


alrb_fn_viewsVersionConvert()
{
# ignoring this as the versioning is not under our control and the developers use HEAD and versioning which are inconsistent.
    \echo "0"

    return $?
}


alrb_fn_viewsDepend()
{
    local alrb_sw="views"
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
    if [ ! -z $ALRB_viewsVersion ]; then
	local alrb_swVersion=$ALRB_viewsVersion
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
 
    export VIEWSDIR="$ALRB_SFT_LCG/views"

    alrb_result=`\echo $alrb_CandToolArg | \grep -w -e "-h" -e "--help" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_addHelp=( ${alrb_addHelp[@]} "source $VIEWSDIR/setupViews.sh" )
	return 0
    fi

    local alrb_testAr=( `\echo $alrb_CandToolArg` )
    if [ ${#alrb_testAr[@]} -ne 2 ]; then
	\echo "Error (views) : incorrect number of arguments"
	source $VIEWSDIR/setupViews.sh
	return 64
    elif [ ! -d "$VIEWSDIR/${alrb_testAr[0]}/${alrb_testAr[1]}" ]; then
	\echo "Error (views) : views release not found"
	source $VIEWSDIR/setupViews.sh ${alrb_testAr[0]} ${alrb_testAr[1]}
	return 64
    fi

    alrb_setVer=`\echo $alrb_CandToolArg | \sed -e 's/ /:/g'`
    alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_setVer" -c "$alrb_swVersion"
    if [ $? -ne 0 ]; then
	return 64
    fi

    return 0    
}


