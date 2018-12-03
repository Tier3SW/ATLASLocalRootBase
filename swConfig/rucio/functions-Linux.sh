#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for rucio-clients
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_rucioHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for rucio

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
     -w  --wrapper          Set up as wrapper to avoid polluting environment
                             works only for CLI and no rucio APIs available
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_rucioVersionConvert()
{
# 3 significant figures 
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $1 3
    return $?
}


alrb_fn_rucioDepend()
{
    local alrb_sw="rucio"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi
    
    local alrb_shortopts="h,q,s,f,c:,w"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,wrapper"
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
    if [ ! -z $ALRB_rucioVersion ]; then
	local alrb_swVersion=$ALRB_rucioVersion
    else
	local alrb_swVersion="dynamic"
    fi
    local alrb_wrapper="NO"    

    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_rucioHelp
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
	    -w|--wrapper)	    
   	        local alrb_wrapper="YES"
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
	fi
    else
	\echo "Error: rucio version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi

    if [ -z $alrb_rucio_wrapper ]; then
        alrb_rucio_wrapper=$alrb_wrapper
    elif [ $alrb_rucio_wrapper != "YES" ]; then
	alrb_wrapper="NO"
    fi
    if [ "$alrb_rucio_extra" != "" ]; then
	alrb_rucio_extra=`\echo $alrb_rucio_extra | \sed -e 's/alrb_wrapper=YES//g'`
    fi
    if [ "$alrb_wrapper" = "YES" ]; then
	alrb_rucio_extra="$alrb_rucio_extra,alrb_wrapper=$alrb_wrapper,"
	alrb_fn_depend "$ALRB_useGridSW" "-w" -c "$alrb_sw"
	if [ $? -ne 0 ]; then
            exit 64
        fi	
	return 0
    fi

# dependencies
    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
    if [ $? -ne 0 ]; then
	return 64
    fi

# emi
    alrb_fn_depend "$ALRB_useGridSW" dynamic -c "$alrb_sw"
    if [ $? -ne 0 ]; then
        exit 64
    fi

# temporary test for testRucioPy26
    alrb_result=`\echo $ALRB_testPath | \grep -e ",testRucioPy27,"`
    if [ $? -ne 0 ]; then

# requires python 2.6 or newer
    local let alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv python:ver --decimal=2`
    if [ "$alrb_tmpVal" -lt 206 ]; then
	if [ ! -z $CMTCONFIG ]; then
	    local alrb_tmpVal="python2.6-$CMTCONFIG"
	elif [ ! -z $rootCmtConfig ]; then
	    local alrb_tmpVal="python2.6-$rootCmtConfig"
	elif [ $ALRB_RHVER = "6" ]; then
	    local alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv python:arch`
# since we do not distribute pythonn 2.6 for sl6, use python 2.7
	    local alrb_tmpVal="python2.7-${alrb_tmpVal}-slc${ALRB_RHVER}-gcc48"
	else
	    \echo "Error: unsupported platform ? (RHEL $ALRB_RHVER)" 1>&2
	    return 64
	fi	
	alrb_fn_depend python "$alrb_tmpVal" -c "$alrb_sw"
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi


# temporary
    else
# requires python 2.7 or newer
    local let alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv python:ver --decimal=2`
    if [ "$alrb_tmpVal" -lt 207 ]; then
	if [ ! -z $CMTCONFIG ]; then
	        local alrb_tmpVal="python2.7-$CMTCONFIG"
		elif [ ! -z $rootCmtConfig ]; then
	        local alrb_tmpVal="python2.7-$rootCmtConfig"
		elif [ $ALRB_RHVER = "6" ]; then
	        local alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv python:arch`
		    local alrb_tmpVal="python2.7-${alrb_tmpVal}-slc${ALRB_RHVER}-gcc44"
		    else
	        \echo "Error: unsupported platform ? (RHEL $ALRB_RHVER)" 1>&2
		    return 64
	fi
	alrb_fn_depend python "$alrb_tmpVal" -c "$alrb_sw"
	if [ $? -ne 0 ]; then
	        return 64
		fi
    fi
    fi

    return 0
}
