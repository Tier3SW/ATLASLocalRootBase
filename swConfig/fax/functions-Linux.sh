#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for fax
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_faxHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for fax

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
     -r --rootVersion=STRING   Optional version of ROOT to setup
                                (you can do instead: lsetup fax root)
     -x --xrootdVersion=STRING Version of xrootd to setup instead of default
                                (you can do instead: lsetup fax xrootd)
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_faxVersionConvert()
{
# 3 significant figures 
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh --separator="-" $1 3 
    return $?
}


alrb_fn_faxDepend()
{
    local alrb_sw="fax"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_shortopts="h,q,s,f,c:,r:,x:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,rootVersion:,xrootdVersion:,faxtoolsVersion:"
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
    if [ ! -z $ALRB_faxVersion ]; then
	local alrb_swVersion=$ALRB_faxVersion
    else
	local alrb_swVersion="dynamic"
    fi
    local alrb_rootVersion="dynamic"
    local alrb_xrootdVersion="dynamic"
    local alrb_doRoot=""
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_faxHelp
		return 0
		;;
            --${alrb_sw}Version|--faxtoolsVersion)
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
# backward compatibility
	        alrb_SkipConfirm="YES"
		shift
		;;
	    -f|--force)    
		shift
		;;
	    -r|--rootVersion)
		alrb_rootVersion=$2
	        alrb_doRoot="YES"
		shift 2
		;;
            -x|--xrootdVersion)
		alrb_xrootdVersion=$2
		shift 2
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
	fi
    else
	\echo "Error: fax version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi

# dependencies   
    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_faxNumVer=`alrb_fn_faxVersionConvert $alrb_setVer`
    if [ "$alrb_faxNumVer" -ge 35 ]; then
	alrb_fn_depend rucio "dynamic" -c "$alrb_sw"
    else
	\echo "Error: fax versions older than 00-00-35 need dq2 which does not exist."
	return 64
    fi

    if [ "$alrb_doRoot" = "YES" ]; then
	alrb_fn_depend root "$alrb_rootVersion" -c "$alrb_sw"
    fi
    
    alrb_fn_depend xrootd "$alrb_xrootdVersion" -c "$alrb_sw"
    
    return 0

}


alrb_fn_faxGetInstallDirAttributes()
{
    \echo "tools/README.txt"

    return 0
}
