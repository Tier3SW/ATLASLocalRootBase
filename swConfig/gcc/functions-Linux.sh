#!----------------------------------------------------------------------------
#!
#! functions.sh
#!
#!    functions to setup gcc
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_gccHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "gcc [options] <version>"
  
    This sets up the ATLAS environment for an alternate gcc compiler

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_gccVersionConvert() 
{
# 3 significant figures - append a 0 if it is 2 digits
    local alrb_result
    alrb_result=`\echo $1 | \sed -e 's/.*gcc\([0-9]\{2,3\}\).*/\1/g'`
    if [ $? -ne 0 ]; then
	return 64
    fi
    if [ ${#alrb_result} = 2 ]; then
	alrb_result="${alrb_result}0"
    fi
    \echo $alrb_result
    return 0
}


alrb_fn_gccDepend() 
{
    local alrb_sw="gcc"
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
    if [ ! -z $ALRB_gccVersion ]; then
	local alrb_swVersion=$ALRB_gccVersion
    else
	local alrb_swVersion="dynamic"
    fi
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_gccHelp
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
    alrb_fn_getToolVersion "$alrb_sw" "$alrb_swVersion" "alrb_gcc:alrb_slc"
    if [ $? -ne 0 ]; then
	return 64
    fi
    local alrb_setVer="$alrb_candVirtVersion"
    
    if [ "$alrb_setVer" != "" ]; then
	alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_setVer" -c "$alrb_swVersion"
	if [ $? -ne 0 ]; then
	    return 64
	else
	    if [ $alrb_Force != "YES" ]; then
		local alrb_tmpVal1=`alrb_fn_versionConvert gcc "$alrb_gcc_setup"`
		local alrb_tmpVal2=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv gcc:ver --nodot=3`
		if [ "$alrb_tmpVal1" = "$alrb_tmpVal2" ]; then
		    alrb_gcc_skip="gcc$alrb_tmpVal2 already setup."
		else
		    alrb_gcc_skip=""
		fi
	    fi

	    return 0
	fi
    else
	\echo "Error: $alrb_sw version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi

    return 0
}


alrb_fn_gccPostInstall()
{

    cd $alrb_InstallDir
# bug in gcc346_i686_slc4 version where dir permissions are incorrect.  fix 
    \find . -type d  | \awk '{print "chmod o+rx,g+rx  "$0"" }' | sh

    return 0
}