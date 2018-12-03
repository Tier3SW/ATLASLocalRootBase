#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for emi
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_emiHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"

    This sets up the ATLAS environment for emi

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
     -w --wrapper           Set up as wrapper to avoid polluting environment
                             works only for CLI 
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_emiVersionConvert()
{
# 3 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 1 -d "-" | \sed -e 's/\([0-9\.]*\).*/\1/g'`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 3
    return $?
}


alrb_fn_emiDepend()
{
    local alrb_sw="emi"
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
    if [ ! -z $ALRB_emiVersion ]; then
	local alrb_swVersion=$ALRB_emiVersion
    else
	local alrb_swVersion="dynamic"
    fi
    local alrb_wrapper="NO"

    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_emiHelp
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
# this is for backward compatibility
		alrb_Force="YES"
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
    
    alrb_result=`\echo $ALRB_testPath | \grep -e ",testEmi,"`
    local alrb_rc=$?
    if [ $alrb_rc -eq 0 ]; then
	local alrb_swVersion="testing-SL${ALRB_RHVER}"
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
	\echo "Error: emi version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi

    if [[ ! -z $ALRB_noGridMW ]] && [[ "$ALRB_noGridMW" = "YES" ]]; then
	alrb_emi_skip="ALRB_noGridMW set; will skip grid middleware setup"
	return 0
    elif [[ "$ALRB_gridType" != "none" ]] && [[ "$alrb_Force" != "YES" ]]; then
	if [ -z $ATLAS_LOCAL_EMI_VERSION ]; then
	    alrb_tmpVal="(from site rpms)"
	else
	    alrb_tmpVal="(from UI)"
	fi
	alrb_emi_skip="grid middleware already setup $alrb_tmpVal"
	return 0
    else
	alrb_emi_skip=""
    fi
 
    if [ -z $alrb_emi_wrapper ]; then
	alrb_emi_wrapper=$alrb_wrapper
    elif [ $alrb_emi_wrapper != "YES" ]; then
	alrb_wrapper="NO"
    fi
    if [ "$alrb_emi_extra" != "" ]; then
	alrb_emi_extra=`\echo $alrb_emi_extra | \sed -e 's/alrb_wrapper=YES//g'`
    fi
    if [ "$alrb_wrapper" = "YES" ]; then	
	alrb_emi_extra="$alrb_emi_extra,alrb_wrapper=$alrb_wrapper,"
	return 0
    fi

# dependencies ...
    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
    if [ $? -ne 0 ]; then
	return 64
    fi
    
# java
# we do not explcitly set this up so save and restore jave settings
    local alrb_tmpVal="$ATLAS_LOCAL_ROOT/emi/$alrb_setVer/localJavaPath.sh"
    if [ -e $alrb_tmpVal ]; then
	alrb_result=`\sed -e 's|.*java-\(.*\)-openjdk.*|\1|' $alrb_tmpVal`
	alrb_fn_verCheckerSave java 
	alrb_fn_depend java "$alrb_result" -c "$alrb_sw" > /dev/null 2>&1

	if [ $? -eq 0 ]; then
	    alrb_emi_extra="$alrb_emi_extra,$alrb_java_extra,"
	else
	    alrb_emi_extra="$alrb_emi_extra,sourceLocalJavaPath,"
	fi    
	alrb_fn_verCheckerRestore java
    fi

    return 0
}


alrb_fn_emiGetPass1Dependency()
{
    local alrb_result
    local alrb_item    
    local alrb_opt=""

    if [[ "$alrb_emi_setup" = "" ]] && [[ "$alrb_emi_dependency" != "" ]]; then    
	local alrb_tmpAr=( `\echo $alrb_emi_dependency | \sed -e 's/,\+/ /g'` )

        for alrb_item in "${alrb_tmpAr[@]}"; do
            local alrb_whoDepends=`\echo $alrb_item | \cut -d ":" -f 1`
	    local alrb_emi_callerArg=`\echo $alrb_item | \cut -d ":" -f 2`

	    alrb_result=`\echo $alrb_emi_callerArg | \grep -w -e "-w" -e "--wrapper" 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_opt="-w"
	    else
		local alrb_toolRequestedArgs=$(\echo alrb_${alrb_whoDepends}_request)
		if [ "${!alrb_toolRequestedArgs}" != "" ]; then
		    alrb_result=`\echo ${!alrb_toolRequestedArgs} | \grep -w -e "-w" -e "--wrapper" 2>&1`
		    if [ $? -eq 0 ]; then
			alrb_opt="-w"
		    else
			alrb_opt="dynamic"
			break
		    fi
		fi
	    fi
	done

	alrb_fn_depend emi "$alrb_opt" -c validator
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi

    return 0
}


alrb_fn_emiPostInstall()
{

    local alrb_result

    \echo " fixing relocated tarball ..."
    local alrb_tmpPath=` \echo $alrb_InstallDir | \sed -e 's|'$ATLAS_LOCAL_ROOT_BASE/'||g'`
    local alrb_myCmd="\sed -e 's|fixMe_EMI_TARBALL_BASE|\$ATLAS_LOCAL_ROOT_BASE/$alrb_tmpPath|g'"
    local alrb_fileList=( "setup.sh" "setup.csh" )
    local alrb_theFile
    for alrb_theFile in ${alrb_fileList[@]}; do
	eval $alrb_myCmd $alrb_theFile > $alrb_theFile.new
	if [ $? -eq 0 ]; then
	    \mv -f $alrb_theFile.new $alrb_theFile
	else
	    \echo "Failed to parse $alrb_theFile "
	    return 64
	fi
    done

    if [ "$alrb_noCronJobs" != "YES" ]; then

# for crls
	alrb_result=`crontab -l | \grep -e '\$ATLAS_LOCAL_ROOT_BASE/utilities/fetchCRL-emi.sh'`
	if [ $? -ne 0 ]; then
	    \echo " creating CRL cron ..."
	    crontab -l > $ALRB_installTmpDir/savedcron
	    \cp $ALRB_installTmpDir/savedcron $ALRB_installTmpDir/newcron
	    local alrb_hr=$[ ( $RANDOM % 24 ) ]
	    local alrb_min=$[ ( $RANDOM % 60 ) ]
	    local alrb_hrs=$alrb_hr","$[ (`expr $alrb_hr + 6` % 24) ]","$[ (`expr $alrb_hr + 12` % 24) ]","$[ (`expr $alrb_hr + 18` % 24) ]
	    \echo "$alrb_min $alrb_hrs * * * export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE; \$ATLAS_LOCAL_ROOT_BASE/utilities/fetchCRL-emi.sh 2>&1" >> $ALRB_installTmpDir/newcron
	    crontab $ALRB_installTmpDir/newcron
	else
	    \echo " CRL cron exists"
	fi
	
# for ca
	alrb_result=`crontab -l | \grep -e '\$ATLAS_LOCAL_ROOT_BASE/utilities/fetchCA-emi.sh'`
	if [ $? -ne 0 ]; then
	    \echo " creating CA cron ..."
	    crontab -l > $ALRB_installTmpDir/savedcron
	    \cp $ALRB_installTmpDir/savedcron $ALRB_installTmpDir/newcron
	    alrb_hr=$[ ( $RANDOM % 24 ) ]
	    alrb_min=$[ ( $RANDOM % 60 ) ]
	    \echo "$alrb_min $alrb_hr * * * export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE; \$ATLAS_LOCAL_ROOT_BASE/utilities/fetchCA-emi.sh 2>&1" >> $ALRB_installTmpDir/newcron
	    crontab $ALRB_installTmpDir/newcron
	else
	    	\echo " CA cron exists"
	fi       

    fi

# need to do this here so that we can run fetchCA / fetchCRL
    cd $alrb_ToolDir
    local alrb_item
    for alrb_item in ${alrb_SetDefaultsAr[@]}; do
	local alrb_version=`\echo $alrb_item | \cut -f 1 -d ":"`
	local alrb_link=`\echo $alrb_item | \cut -f 2 -d ":"`
	if [ "$alrb_version" != "" ]; then
	    if [ -d $alrb_version ]; then
		\rm -f $alrb_link
		ln -s $alrb_version $alrb_link
	    fi    
	fi
    done    
    alrb_fn_createReleaseMap emi

    \echo " running fetchCA ..."
    $ATLAS_LOCAL_ROOT_BASE/utilities/fetchCA-emi.sh 2>&1
    \echo " running fetchCRL ..."
    $ATLAS_LOCAL_ROOT_BASE/utilities/fetchCRL-emi.sh 2>&1
    
    return 0
}


alrb_fn_emiPreRemove()
{

    \echo " Removing crontab entry"
    crontab -l > ${ALRB_installTmpDir}/savedcron
    eval "crontab -l | \sed -e 's|\(^[^#].*$alrb_InstallDir\).*||g'" > ${ALRB_installTmpDir}/newcron
    if [ $? -eq 0 ]; then
	crontab ${ALRB_installTmpDir}/newcron
    fi

    return 0
}