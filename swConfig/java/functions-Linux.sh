#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for java
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_javaHelp()
{
    \cat <<EOF

This is an internal java setup and not for user access.
EOF
}


alrb_fn_javaVersionConvert()
{
# 3 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 1 -d "_"`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 3
    return $?
}


alrb_fn_javaDepend()
{
    local alrb_sw="java"
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
    local alrb_swVersion="none"
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_javaHelp
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
    
    local let alrb_swVersionN=`alrb_fn_javaVersionConvert "$alrb_swVersion"`    
    if [ "$alrb_whichJava" != "" ]; then
	local alrb_tmpVal=`$alrb_whichJava -version 2>&1`
	local alrb_currentJavaVersion=`\echo $alrb_tmpVal | \grep -e "openjdk version" -e "java version" | \sed 's/.* version "\(.*\)".*/\1/g'`
	local let alrb_currentJavaVersionN=`alrb_fn_javaVersionConvert "$alrb_currentJavaVersion"`
	local alrb_currentJavaOpenJDK="NO"
	local alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_whichJava`
	alrb_tmpVal=`\echo $alrb_tmpVal | \grep -i openjdk 2>&1`
	if [ $? -ne 0 ]; then
	    local alrb_currentJavaOpenJDK="NO"
	else
	    local alrb_currentJavaOpenJDK="YES"
	fi
    else
	local let alrb_currentJavaVersionN=0
	local alrb_currentJavaOpenJDK="NO"
    fi
    
    if [[ $alrb_swVersionN -le $alrb_currentJavaVersionN ]] && [[ "$alrb_currentJavaOpenJDK" = "YES" ]] && [[ $alrb_Force != "YES" ]]; then
	alrb_java_skip="Java OpeJDK $alrb_currentJavaVersion already available"
	return 0
    else
	alrb_java_skip=""
    fi

    if [ -d "/usr/lib/jvm" ]; then
	local alrb_tmpAr=( `\find  /usr/lib/jvm/ -maxdepth 1 -mindepth 1 -type d  | \grep openjdk` )
    else
	local alrb_tmpAr=()
    fi
    local let alrb_candN=0
    local alrb_cand=""
    local alrb_item
    for alrb_item in ${alrb_tmpAr[@]}; do
	if [ ! -e "$alrb_item/jre/bin/java" ]; then
	    continue
	fi
	local alrb_itemVer=`\echo $alrb_item | \cut -f 2 -d "-"`
	local let alrb_itemN=`alrb_fn_javaVersionConvert "$alrb_itemVer"`
	if [ $alrb_itemN -lt $alrb_swVersionN ]; then
	    continue
	elif [ $alrb_candN -lt $alrb_itemN ]; then
	    let alrb_candN=$alrb_itemN
	    alrb_cand=$alrb_item
	    alrb_candVer=$alrb_itemVer
	fi
    done
    if [ "$alrb_cand" != "" ]; then
	alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_itemVer" -c "$alrb_swVersion"
	if [ $? -ne 0 ]; then
	    return 64
	else
	    alrb_java_extra="$alrb_java_extra,alrb_javaHome=${alrb_cand}/jre,"
	fi
	return 0
    else
	\echo "Error: cannot find suitable java version $alrb_swVersion.  Please define \$JAVA_HOME" 1>&2
	return 64
    fi
  
    return 0
}
