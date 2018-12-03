#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for Ganga
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_gangaHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for Ganga

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
      -s --skipGangaRcCheck    Skip checking .gangarc 
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_gangaVersionConvert()
{
# 3 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 1 -d "-"`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 3
    return $?
}


alrb_fn_gangaDepend()
{
    local alrb_sw="ganga"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_shortopts="h,q,s,f,c:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,skipGangaRcCheck"
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
    if [ ! -z $ALRB_gangaVersion ]; then
	local alrb_swVersion=$ALRB_gangaVersion
    else
	local alrb_swVersion="dynamic"
    fi
    local alrn_skipGangaRcCheck="NO"    

    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_gangaHelp
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
	        alrb_Quiet="YES"
# backward compatibility
		shift
		;;
	    -s|--skipConfirm)	    
		shift
		;;
	    -f|--force)    
		shift
		;;
	    --skipGangaRcCheck)
 	        alrb_skipGangaRcCheck="YES"
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
	    alrb_ganga_extra="$alrb_ganga_extra,skipGangaRcCheck=$alrb_skipGangaRcCheck,"

# dependencies
	    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

	    return 0
	fi
    else
	\echo "Error: Ganga version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi
}


alrb_fn_gangaGetInstallDirAttributes()
{
    \echo "install"

    return 0
}


alrb_fn_gangaPostInstall()
{
    python ganga-install --extern=GangaAtlas,GangaPanda --prefix=$alrb_InstallDir $alrb_InstallVersion
    return $?
}
