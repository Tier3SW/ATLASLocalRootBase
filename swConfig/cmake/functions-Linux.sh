#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for cmake
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_cmakeHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for cmake

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_cmakeVersionConvert()
{
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $1 3
    return 0
}


alrb_fn_cmakeDepend()
{
    local alrb_sw="cmake"
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
    if [ ! -z $ALRB_cmakeVersion ]; then
	local alrb_swVersion=$ALRB_cmakeVersion
    else
	local alrb_swVersion="dynamic"
    fi
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_cmakeHelp
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
    alrb_fn_getToolVersion "$alrb_sw" "$alrb_swVersion" ""
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
	\echo "Error: cmake version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi
}


alrb_fn_cmakeGetInstallDirAttributes()
{
    \echo "Linux-i386  Linux-x86_64"

    return 0
}

alrb_fn_cmakePostInstall()
{
    cd $alrb_InstallDir

    local alrb_result
    
    local alrb_unpacked=`\find . -type d | \grep cmake | \head -n 1`
    alrb_result=`\echo $alrb_unpacked | \grep Linux-i386`
    if [ $? -eq 0 ]; then
	\mv $alrb_unpacked Linux-i386
    fi
    alrb_result=`\echo $alrb_unpacked | \grep Linux-x86_64`
    if [ $? -eq 0 ]; then
	\mv $alrb_unpacked Linux-x86_64
    fi

    return 0
}

