#!----------------------------------------------------------------------------
#!
#! versionChecker.sh
#!
#! Functions to check and sets limits for tool versions in localSetup
#!
#! Usage:
#!     alrb_fn_versionChecker --help
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fn_verCheckerHelp()
{
    \cat <<EOF

Usage: alrb_fn_versionChecker <tool> <client> <version> [options] 

    Depending on the options, for a given tool, this will
      - check if a given version is within limits
      - set the checked value as the new lower limit if it passes

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
     -h  --help                Print this help message
     -c  --check=<original>    Check version if they are within limits
                                original version value should also be specified
                                 (eg dynamic or user requested one)
     -l  --setLower            Set lower limit, may not be used with check
     -u  --setUpper            Set upper limit, may not be used with check
 
     
EOF

}


alrb_fn_versionChecker() 
{
    local alrb_progname=alrb_fn_versionChecker
    
    local alrb_shortopts="h,u,l,c:"
    local alrb_longopts="help,setUpper,setLower,check:"
    local alrb_result
    local alrb_opts
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
	\echo "'$alrb_progname --help' for more information" 1>&2
	return 1
    fi
    
    eval set -- "$alrb_opts"
    
    local alrb_tool=""
    local alrb_client=""
    local alrb_limit=""
    local alrb_setUpper="NO"
    local alrb_setLower="NO"
    local alrb_origVer=""

    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_verCheckerHelp
		return 0
		;;
            -u|--setUpper)
		local alrb_setUpper="YES"
		shift 
		;;
            -l|--setLower)
		local alrb_setLower="YES"
		shift 
		;;
            -c|--check)
		local alrb_origVer=$2
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
    
    if [ $# -ne 3 ]; then
	\echo "Error: incorrect arguments ..." 1>&2
	alrb_fn_verCheckerHelp 1>&2
	return 64
    fi
    
    local alrb_tool=$1
    local alrb_client=$2
    local alrb_limit=$3
    
    local alrb_tmpVal=$(\echo alrb_${alrb_tool}_anchored)
    if [ "${!alrb_tmpVal}" != "" ]; then
# this tool version has been anchored do go away quietly

# exception is if it is specified by a user explicitly
	if [[ "$alrb_origVer" = "dynamic" ]] || [[ "$alrb_client" != "validator" ]]; then
	    return 0
	fi
    fi

    local alrb_anchor="NO"
    local alrb_replace="NO"

    local alrb_tmpVal=`\echo $alrb_client | \cut -f 2 -d ":"`
    if [ "$alrb_tmpVal" != "$alrb_client" ]; then
	alrb_client=`\echo $alrb_client | \cut -f 1 -d ":"`
	if [ "$alrb_tmpVal" = "anchor" ]; then
	    local alrb_anchor="YES"
	elif [ "$alrb_tmpVal" = "override" ]; then
	    local alrb_anchor="YES"
	fi
    fi

    if [[ "$alrb_origVer" != "dynamic" ]] && [[ "$alrb_client" = "validator" ]]; then
	local alrb_anchor="YES"
    elif [ "$alrb_swVersion" != "dynamic" ]; then
	local alrb_replace="YES"
    fi
    
    local let alrb_numVer=`alrb_fn_versionConvert ${alrb_tool} $alrb_limit`

    if [[ "$alrb_setUpper" = "YES" ]] || [[ "$alrb_setLower" = "YES" ]]; then
	if [ "$alrb_origVer" != "" ]; then
	    \echo "Error: setupper and setLower options cannot be used with check" 1>&2
	    return 64
	fi
	if [ "$alrb_setUpper" = "YES" ]; then
	    local alrb_uNVer=$(\echo alrb_${alrb_tool}_uNVer)
	    if [[ "${!alrb_uNVer}" != "" ]] && [[ $alrb_numVer -gt ${!alrb_uNVer} ]]; then
		:
	    else
		\eval "alrb_${alrb_tool}_uLim=$alrb_limit"
		\eval "alrb_${alrb_tool}_uNVer=$alrb_numVer"
		\eval "alrb_${alrb_tool}_uCli=$alrb_client"	
	    fi
	fi
	if [ "$alrb_setLower" = "YES" ]; then
	    local alrb_lNVer=$(\echo alrb_${alrb_tool}_lNVer)
	    if [[ "${!alrb_lNVer}" != "" ]] && [[ $alrb_numVer -lt ${!alrb_lNVer} ]]; then
		:
	    else
		\eval "alrb_${alrb_tool}_lLim=$alrb_limit"
		\eval "alrb_${alrb_tool}_lNVer=$alrb_numVer"
		\eval "alrb_${alrb_tool}_lCli=$alrb_client"
	    fi
	fi
	return 0
    fi
    
    if [ "$alrb_origVer" != "" ]; then

	if [ "$alrb_anchor" != "YES" ]; then
	    local alrb_uNVer=$(\echo alrb_${alrb_tool}_uNVer)
	    if [ "${!alrb_uNVer}" != "" ]; then
		if [ $alrb_numVer -gt ${!alrb_uNVer} ]; then
		    local alrb_uCli=$(\echo alrb_${alrb_tool}_uCli)
		    local alrb_uLim=$(\echo alrb_${alrb_tool}_uLim)
		    \echo " Error: ${alrb_tool} $alrb_limit > ${!alrb_uLim} (needed by ${!alrb_uCli})" 1>&2
		    return 64
		fi
	    fi
	fi

	local alrb_lNVer=$(\echo alrb_${alrb_tool}_lNVer)
	if [ "${!alrb_lNVer}" != "" ]; then
	    if [ $alrb_numVer -lt ${!alrb_lNVer} ]; then
		local alrb_lCli=$(\echo alrb_${alrb_tool}_lCli)
		local alrb_lLim=$(\echo alrb_${alrb_tool}_lLim)
		\echo " Error: ${alrb_tool} $alrb_limit < ${!alrb_lLim} (needed by ${!alrb_lCli})" 1>&2
		return 64
	    fi
	fi

	if [[ "$alrb_replace" = "YES" ]] || [[ "$alrb_anchor" = "YES" ]] ; then
	    \eval "alrb_${alrb_tool}_lLim=$alrb_limit"
	    \eval "alrb_${alrb_tool}_lNVer=$alrb_numVer"
	    \eval "alrb_${alrb_tool}_lCli=$alrb_client"
	fi
	if [ "$alrb_anchor" = "YES" ] ; then
	    \eval "alrb_${alrb_tool}_uLim=$alrb_limit"
	    \eval "alrb_${alrb_tool}_uNVer=$alrb_numVer"
	    \eval "alrb_${alrb_tool}_uCli=$alrb_client"
	    \eval "alrb_${alrb_tool}_anchored=YES"
	fi

	if [ "$alrb_origVer" = "dynamic" ]; then
            alrb_tmpVal=$(\echo alrb_${alrb_tool}_setup)
            if [ "${!alrb_tmpVal}" = "" ]; then
		\eval "alrb_${alrb_tool}_setup=$alrb_limit"
            fi
        else
	    \eval "alrb_${alrb_tool}_setup=$alrb_limit"
	fi

	return 0 
    fi    
    
    return 0
}


alrb_fn_verCheckerSave()
{
    local alrb_tool=$1
    local alrb_tmpVal

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lLim)
    \eval "alrb_${alrb_tool}_lLimSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lNVer)
    \eval "alrb_${alrb_tool}_lNVerSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lCli)
    \eval "alrb_${alrb_tool}_lCliSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uLim)
    \eval "alrb_${alrb_tool}_uLimSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uNVer)
    \eval "alrb_${alrb_tool}_uNVerSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uCli)
    \eval "alrb_${alrb_tool}_uCliSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_setup)
    \eval "alrb_${alrb_tool}_setupSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_extra)
    \eval "alrb_${alrb_tool}_extraSaved=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_anchored)
    \eval "alrb_${alrb_tool}_anchoredSaved=${!alrb_tmpVal}"

    return 0
}


alrb_fn_verCheckerRestore()
{
    local alrb_tool=$1
    local alrb_tmpVal

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lLimSaved)
    \eval "alrb_${alrb_tool}_lLim=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lNVerSaved)
    \eval "alrb_${alrb_tool}_lNVer=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_lCliSaved)
    \eval "alrb_${alrb_tool}_lCli=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uLimSaved)
    \eval "alrb_${alrb_tool}_uLim=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uNVerSaved)
    \eval "alrb_${alrb_tool}_uNVer=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_uCliSaved)
    \eval "alrb_${alrb_tool}_uCli=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_setupSaved)
    \eval "alrb_${alrb_tool}_setup=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_extraSaved)
    \eval "alrb_${alrb_tool}_extra=${!alrb_tmpVal}"

    alrb_tmpVal=$(\echo alrb_${alrb_tool}_anchoredSaved)
    \eval "alrb_${alrb_tool}_anchored=${!alrb_tmpVal}"

    return 0
}

