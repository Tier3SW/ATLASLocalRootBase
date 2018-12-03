#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for rcsetup
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fb_rcsetupHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for rcSetup

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    For rcSetup help, type "rcSetup --help"

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_rcsetupVersionConvert()
{
# 3 significant figures 
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $1 3 --separator="-"
    return $?
}


alrb_fn_rcsetupDepend()
{
    local alrb_sw="rcsetup"
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
    if [ ! -z $ALRB_rcsetupVersion ]; then
	local alrb_swVersion=$ALRB_rcsetupVersion
    elif [ ! -z $ATLAS_LOCAL_RCSETUP_VERSION ]; then
	local alrb_swVersion=$ATLAS_LOCAL_RCSETUP_VERSION
    else
	local alrb_swVersion="dynamic"
    fi
    local alrb_passThrough=""
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
#		alrb_fb_rcsetupHelp
#		return 0
		shift
		;;
            -c|--caller)
		local alrb_caller=$2
		shift 2
		;;
	    -q|--quiet)	    
# backward compatibility
#		local alrb_Quiet="YES"
# quiet is not used in alrbV1
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
    
    alrb_result=`\echo $alrb_CandToolArg | \grep -w -e "-h" -e "--help" 2>&1`
    if [ $? -eq 0 ]; then
        alrb_addHelp=( ${alrb_addHelp[@]} "source \$ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh -h" )
        return 0
    fi

    alrb_rcsetup_extra="$alrb_CandToolArg"
    
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
	fi
    else
	\echo "Error: ${alrb_sw} version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi

    return 0
    
}


alrb_fn_rcsetupFilterArgs()
{
    alrb_ToolOpts=${alrb_ToolOpts/$alrb_CandToolArg/}
    return $?
}


alrb_fn_rcsetupGetInstallDirAttributes()
{
    \echo "rcSetup.sh"

    return 0
}


alrb_fn_rcsetupShowVersions()
{
    alrb_toolDir=`alrb_fn_getInstallDir $alrb_tool`
    if [ -e $alrb_toolDir/.alrb/mapfile.txt ]; then
	\echo "
$alrb_tool versions;"
	\cat $alrb_toolDir/.alrb/mapfile.txt | \cut -f 4-  -d "|" |  \column -t -s "|" |  \sed -e 's/^/ --> /g' -e 's/\([[:space:]]\)current/\1default/g' | env LC_ALL=C \sort
	\echo "Type lsetup -r <version> \"$alrb_tool ...\" to use $alrb_tool"
    fi

    return 0
}
