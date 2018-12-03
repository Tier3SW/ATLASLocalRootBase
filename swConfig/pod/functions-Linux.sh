#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for PoD
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_podHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for PoD

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
     --rootVersion=STRING      Version of ROOT to use
                                (you can do instead: lsetup pod root)
     --skipRootSetup           Do not setup ROOT (eg. use one already setup)
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_podVersionConvert()
{
# 2 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 2 -d "-" | \sed -e 's/\([0-9\.]*\).*/\1/g'`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 2
    return $?
}


alrb_fn_podDepend()
{
    local alrb_sw="pod"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_shortopts="h,q,s,f,c:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,rootVersion:,skipRootSetup"
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
    if [ ! -z $ALRB_podVersion ]; then
	local alrb_swVersion=$ALRB_podVersion
    else
	local alrb_swVersion="dynamic"
    fi

    alrb_result=`\echo ${alrb_SetupToolAr[@]} | \grep -e root`
    if [ $? -eq 0 ]; then
	local alrb_skipRootSetup="YES"
    else
	local alrb_skipRootSetup="NO"
    fi

    local alrb_rootVersion=""
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_podHelp
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
# backward compatibility
	        alrb_SkipConfirm="YES"
		shift
		;;
	    -f|--force)    
		shift
		;;
            --rootVersion)
                local alrb_rootVersion=$2
                shift 2
                ;;
	    --skipRootSetup)
	        local alrb_skipRootSetup="YES"
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
    
    local alrb_abort="NO"
    if [ -e $ATLAS_LOCAL_ROOT_BASE/config/localNoPOD ]; then
	local alrb_abort="YES"
    elif [[ ! -z $ALRB_localConfigDir ]] && [[ -e $ALRB_localConfigDir/localNoPOD ]]; then
	local alrb_abort="YES"
    elif [ ! -z $ALRB_noPOD ]; then
	local alrb_abort="YES"
    fi
    if [ "$alrb_abort" = "YES" ]; then
	\echo "   Error: abort  because site admin has disabled POD from running on the site." 1>&2
	return 64
    fi

    if [ "$ALRB_clientShell" = "tcsh" ]; then
	\echo "   Error: PoD is not available for $ALRB_clientShell" 1>&2
	return 64
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

	    alrb_fn_parseVersionVar "$alrb_setVer"
	    
# root
	    if [ "$alrb_skipRootSetup" = "NO" ]; then
		if [ "$alrb_rootVersion" != "" ]; then
		    local alrb_tmpVal="$alrb_rootVersion"
		else
		    local alrb_tmpVal="dynamic"
		fi
		alrb_fn_depend root "$alrb_tmpVal" -c "$alrb_sw"
		if [ $? -ne 0 ]; then
		    return 64
		fi
	    fi

# gcc
	    alrb_fn_depend gcc "gcc${alrb_gcc}-${alrb_setVer}" -c "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

# python
	    alrb_fn_depend python "python${alrb_python}-${alrb_setVer}" -c "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

# boost
	    alrb_fn_depend boost "boost${alrb_boost}-${alrb_setVer}" -c "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

	    return 0
	fi
    else
	\echo "Error: PoD version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi
}


alrb_fn_podPostInstall()
{

    \echo " Manually getting compiled wn bins ..."
    local alrb_addFile="`\echo $alrb_InstallVersion | \cut -f 1-2 -d "-"`-add.tar.gz"

    local alrb_wnbinsDir=`\find . -name PoD_env.sh | \sed 's|PoD_env.sh|bin/wn_bins|'`
    mkdir -p $alrb_wnbinsDir
    cd $alrb_wnbinsDir
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh http://atlas-tier3-sw.web.cern.ch/atlas-Tier3-SW/repo/PoD/$alrb_addFile
    tar zxf $alrb_addFile
    \rm -f $alrb_addFile
    cd $alrb_InstallDir
    
    return 0
}
