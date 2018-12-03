#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for setting up the SFT repo packages
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_sftHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"
  
    This sets up the ATLAS environment for the SFT repo packages

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    <version> are software from the cvmfs sft repo to setup.  (see list below).
    Separate multiple values with commas.

    Options (to override defaults) are:
     --cmtconfig=STRING     CMTCONFIG version to use 
                             Default is Athena or Standalone ROOT's cmtconfig

     For more details, please see 
       https://twiki.atlas-canada.ca/bin/view/AtlasCanada/LocalSetupSFT

EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_sftVersionConvert()
{
# always return 0 - this is a pseudo package
    \echo 0
    return 0
}


alrb_fn_sftDepend()
{
    local alrb_sw="sft"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"
    
    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_shortopts="h,q,s,f,c:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,lcgExtSW:,cmtConfig:,cmtconfig:"
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
    local alrb_swVersion=""
    local alrb_cmtConfig=""
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_sftHelp
		return 0
		;;
            --lcgExtSW)
# backward compatibility
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
	    --cmtConfig|--cmtconfig)
                alrb_cmtConfig=$2
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
	\echo "Error: (sft) You need to specify which packages to setup." 1>&2
	return 64
    fi

    if [ "$ALRB_SFT_LCG" = "none" ]; then
	\echo "Error: cvmfs sft repo is missing" 1>&2
	return 64
    fi	

# look for correct cmtconfig versions 
    if [ "$alrb_root_setup" != "" ]; then
	local alrb_sftRootCmt=`\echo $alrb_root_extra | \sed -e 's|.*,cmt=\(.*\),.*|\1|g'`
	local alrb_rootToSetup=$alrb_sftRootCmt
    elif [ ! -z $rootCmtConfig ]; then
	local alrb_sftRootCmt=$rootCmtConfig
    fi

    if [ "$alrb_cmtConfig" != "" ]; then
# root and cmtconfig spefified here do not match
	if [[ ! -z $alrb_rootToSetup ]] && [[ "$alrb_cmtConfig" != "$alrb_rootToSetup" ]]; then
	    \echo "Error: (sft) specified --cmtConfig=$alrb_cmtConfig but root $alrb_rootToSetup will be setup" 1>&2
	    return 64
	fi	
    else
	if [ ! -z $alrb_rootToSetup ]; then
	    if [ ! -z $CMTCONFIG ]; then
		alrb_result=`\echo $CMTCONFIG | \grep $alrb_rootToSetup`
		if [ $? -ne 0 ]; then
	            \echo "Error: (sft) Athena does not match requested root cmtconfig:" 1>&2
		    \echo " Athena (setup): $CMTCONFIG" 1>&2
		    \echo " ROOT (requested): $alrb_rootToSetup" 1>&2
		    \echo " Please seecify a valid cmtconfig value to use" 1>&2
		    return 64    
		fi
	    fi	
	    local alrb_cmtConfig=$alrb_rootToSetup
	elif [ ! -z $rootCmtConfig ]; then
	    if [ ! -z $CMTCONFIG ]; then
		alrb_result=`\echo $CMTCONFIG | \grep $rootCmtConfig`
		if [ $? -ne 0 ]; then
	            \echo "Error: (sft) Both Athena and Root have been setup:" 1>&2
		    \echo " Athena: $CMTCONFIG" 1>&2
		    \echo " ROOT: $rootCmtConfig" 1>&2
		    \echo " Please seecify a valid cmtconfig value to use" 1>&2
		    return 64    
		fi
	    fi
	    local alrb_cmtConfig=$rootCmtConfig
	elif [ ! -z $CMTCONFIG ]; then
	    local alrb_cmtConfig=$CMTCONFIG
	else
	    \echo "Error: (sft) unable to determine cmtconfig value." 1>&2
	    \echo " Please specify it as an option --cmtConfig or also setup ROOT or Athena." 1>&2
	    return 64
	fi
    fi

    local alrb_tmpVal=$alrb_cmtConfig
    alrb_result=`\echo $alrb_swVersion | \tr ',' '\n' | \grep python | \sed -e 's|.*python\(.*\)|\1|g' | env LC_ALL=C \sort -u | \tail -n 1`
    if [ "$alrb_result" != "" ]; then
	local alrb_tmpVal="${alrb_tmpVal}-python${alrb_result}"
    fi
    alrb_fn_parseVersionVar "$alrb_tmpVal"

# gcc
    alrb_fn_depend gcc "gcc${alrb_gcc}-$alrb_cmtConfig" -c "$alrb_sw"
    if [ $? -ne 0 ]; then
	return 64
    fi

# python
    if [ "$alrb_python" != "" ]; then
	local alrb_tmp="python${alrb_python}-$alrb_cmtConfig"
    else
	local alrb_tmp="dynamic"
    fi
    alrb_fn_depend python "$alrb_tmp" -c "$alrb_sw"
    if [ $? -ne 0 ]; then
	return 64
    fi

# the packages ...

    local alrb_abort=0
    local alrb_listPackages=( `\echo $alrb_swVersion | \sed -e 's|,| |g'` )
    local alrb_listPackagesSetup=()
    for alrb_item in ${alrb_listPackages[@]}; do
	
# backward compatibility for paths
	alrb_result=`\echo $alrb_item | \grep -e "^external/" -e "^releases/"`
	if [ $? -ne 0 ]; then
	    alrb_item="external/$alrb_item"
	fi
	
	local alrb_fullPath="$ALRB_SFT_LCG/$alrb_item/$alrb_cmtConfig"
	if [ ! -d $alrb_fullPath ]; then
	    \echo "Error: $alrb_fullPath does not exist."  1>&2
	    return 64
	fi

	alrb_tmpAr=( `\echo $alrb_item | \sed -e 's|/| |g'` )
	alrb_package=`\echo ${alrb_tmpAr[@]:(-2):(1)}`

	alrb_sft_extra="$alrb_sft_extra,pkg=$alrb_item,"
	alrb_sft_setup="$alrb_sft_setup $alrb_package"    
    done
    alrb_sft_extra="$alrb_sft_extra,cmt=$alrb_cmtConfig,"
}


alrb_fn_sftShowVersions()
{

    local alrb_result
    alrb_result=`\echo $alrb_ListPackages | \grep sft`
    if [ $? -ne 0 ]; then
	return 0
    fi

    if [ "$ALRB_SFT_LCG" = "none" ]; then
	\echo "Error: cvmfs sft repo is missing" 1>&2
	return 64
    fi
    if [ ! -e $ALRB_SFT_LCGEXT_MAP ]; then
	\echo "Error: cvmfs sft repo mapfile is missing." 1>&2
	return 64
    fi

    local alrb_cmtGrep=""
    local alrb_printTxt=""
# default is to print only for existing cmtconfig values
    if [ "$alrb_cmtConfig" = "" ]; then
	if [ ! -z $CMTCONFIG ]; then
	    alrb_cmtGrep="$alrb_cmtGrep -e '$CMTCONFIG'" 
	    alrb_printTxt="$alrb_printTxt $CMTCONFIG"
	fi
	if [ ! -z $rootCmtConfig ]; then
	    alrb_cmtGrep="$alrb_cmtGrep -e '$rootCmtConfig'"
	    alrb_printTxt="$alrb_printTxt $rootCmtConfig"
	fi
    elif [ "$alrb_cmtConfig" != "showAll" ]; then 
	alrb_cmtGrep="$alrb_cmtGrep -e '$alrb_cmtConfig'"
	alrb_printTxt="$alrb_printTxt $alrb_cmtConfig"
    fi
    local alrb_myCmd
    if [[ "$alrb_cmtGrep" = "" ]] && [[ "$alrb_cmtConfig" != "showAll" ]]; then
	alrb_myCmd="\grep -e '\-opt' $ALRB_SFT_LCGEXT_MAP | \sed -e 's|$ALRB_SFT_LCG/\(.*\)/.*-opt.*| \1|g' | env LC_ALL=C \sort -u"
    elif [ "$alrb_cmtConfig" = "showAll" ]; then
	alrb_myCmd="\grep -e '\-opt' $ALRB_SFT_LCGEXT_MAP |\sed -e 's|$ALRB_SFT_LCG/\(.*\)/\(.*-opt.*\)| \1 : \2|g' | env LC_ALL=C \sort -u" 
    else
	alrb_myCmd="\grep $alrb_cmtGrep $ALRB_SFT_LCGEXT_MAP | \sed -e 's|$ALRB_SFT_LCG/\(.*\)/.*-opt.*| \1|g' | env LC_ALL=C \sort -u" 
    fi

    \echo " "
    if [ "$alrb_printTxt" != "" ]; then
	\echo " sft versions:( Available for $alrb_printTxt)"
    else
	\echo " sft versions:" 
    fi
    eval $alrb_myCmd
    \echo "Type lsetup \"sft <value>\" to use SFT (type --help for details)"
    return 0
}
