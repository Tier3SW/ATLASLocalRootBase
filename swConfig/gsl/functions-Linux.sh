#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for gsl
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_gslHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for gsl

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_gslVersionConvert()
{
# 2 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 1 -d "-" | \sed -e 's/\([0-9\.]*\).*/\1/g'`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 2
    return $?    
}


alrb_fn_gslDepend() 
{
    local alrb_sw="gsl"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi
    
    local alrb_shortopts="h,q,s,f,c:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force"
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
    if [ ! -z $ALRB_gslVersion ]; then
	local alrb_swVersion=$ALRB_gslVersion
    else
	local alrb_swVersion="dynamic"
    fi
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_gslHelp
		return 0
		;;
            --${alrb_sw}Version)
                local alrb_swVersion=$2
		shift 2
		;;
            -c|--caller)
		local alrb_caller=$2
		shift 2
		;;
	    -q|--quiet)	    
# backward compatibility
	        alrb_Quiet="YES"
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

    if [ $# -ge 1 ]; then
	local alrb_swVersion=$1
	shift
	alrb_fn_unrecognizedExtraArgs "$@"
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi
    
    if [ "$alrb_swVersion" = "" ]; then
	\echo "Error: ${alrb_sw} version not specified" 1>&2
	return 64
    fi

    local alrb_candRealVersion=""
    local alrb_candVirtVersion=""
    alrb_fn_getToolVersion "$alrb_sw" "$alrb_swVersion" "alrb_gcc:alrb_slc:alrb_arch:alrb_firstVer"
    if [ $? -ne 0 ]; then
	return 64
    fi
    local alrb_setVer="$alrb_candVirtVersion"
    
    if [ "$alrb_setVer" != "" ]; then
	alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_setVer" -c "$alrb_swVersion"
	if [ $? -ne 0 ]; then
	    return 64
	else

# dependencies
	    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

	    return 0
	fi
    else
	\echo "Error: gsl version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi
}
