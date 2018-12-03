#! /bin/bash 
#!----------------------------------------------------------------------------
#! 
#! checkValidity.sh
#!
#! Check if cvmfs or ATLASLocalRootBase is too old
#!
#! Usage: 
#!     checkValidity.sh --help
#!     return a non-zero error code if it thinks it is too old
#!
#! History:
#!   24May13: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=checkValidity.sh

if [ -z $ATLAS_LOCAL_ROOT_BASE ]; then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

#!----------------------------------------------------------------------------
# configurations
alrb_nameAr=( "atlas" "condb" "nightlies" "alrb" "sft" )
alrb_validTimeAr=( "172800" "172800" "172800" "172800" "172800" )
alrb_errorCodeAr=( "2" "4" "8" "1" "16" ) 
alrb_tsFileAr=(
"$ALRB_cvmfs_repo/ATLASLocalRootBase/logDir/lastUpdate"
"$ALRB_cvmfs_CDB/logDir/lastUpdate"
"$ALRB_cvmfs_nightly_repo/sw/logs/lastUpdate"
"$ATLAS_LOCAL_ROOT_BASE/logDir/lastUpdate"
"$ALRB_cvmfs_sft_repo/lastUpdate"
)
alrb_warnMsgAr=(
"Warning: atlas $ALRB_cvmfs_repo may be stale"
"Warning: atlas-condb $ALRB_cvmfs_CDB may be stale"
"Warning: atlas-nightlies $ALRB_cvmfs_nightly_repo may be stale"
"Warning: local ATLASLocalRootBase has not been updated recently"
"Warning: SFT repo has not been updated recently"
)
alrb_checkAr=( "YES" "YES" "YES" "YES" "YES" )
alrb_exitCodeAr=( "NO" "NO" "NO" "NO" "NO" )

#!----------------------------------------------------------------------------

alrb_validNames=`\echo ${alrb_nameAr[@]} | \sed -e 's| |,|g'`
let alrb_idx=0
alrb_validNamesTimes=""
for alrb_item in "${alrb_nameAr[@]}"; do
    alrb_tmpVal="$alrb_item:${alrb_validTimeAr[$alrb_idx]}"
    if [ "$alrb_validNamesTimes" = "" ]; then
	alrb_validNamesTimes="$alrb_tmpVal"
    else
	alrb_validNamesTimes="$alrb_validNamesTimes,$alrb_tmpVal"
    fi
    let alrb_idx++
done

#!----------------------------------------------------------------------------
alrb_fn_checkValidityHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF
Usage: checkValidity.sh [options]

    Check the validity of ATLASLocalRootBase and cvmfs

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --quiet                  No messages; only indication is exit code
     --checkOnly=<string>     Comma delimited list to check; values are:
                               all,$alrb_validNames
                               default : all
     --exitCodeFor=<string>   Comma delimited list for which checks will 
                               return an exit code for failures; values are:
                               all,none,$alrb_validNames 
                               default : none
     --validTime=<string>    Interval for validity; value is comma delimited
                               pairs with time in seconds; eg:
                               $alrb_validNamesTimes                     
                               default: as shown above

Note that, by default, the exit code will be 0 unless requested by the 
 --exitCodeFor option.
exit codes:
0 : OK
other: check return code bits
 bit 1 : local (if exists) ATLASLocalRootBase stale
 bit 2 : atlas cvmfs repo stale
 bit 3 : atlas-condb cvmfs repo stale
 bit 4 : atlas-nightly cvmfs repo stale
 bit 5 : sft cvmfs repo stale

Not every site would have atlas-nightlies repo at the moment.  If this is 
 unavailable, a warning is only generated with the exit code if the option 
 --exitCodeFor=nightlies is specified.  This behaviour will change once
 all sites migrate to cvmfs 2.1.
 
EOF
}


#!----------------------------------------------------------------------------
alrb_fn_doCheckValid()
#!----------------------------------------------------------------------------
{    
    let alrb_retCode=0
    alrb_tmpVal=""

    if [ ! -e $alrb_tsFile ]; then
	alrb_warnMsg="$alrb_warnMsg; $alrb_tsFile does not exist"
    else
	alrb_tmpVal=`\tail -n 1 $alrb_tsFile | \cut -f 3 -d "|" | \sed 's/ //g'`
    fi

    if [ "$alrb_tmpVal" = "" ]; then
	let alrb_retCode=$alrb_errCode
    else
	let alrb_lastUpdate=$alrb_tmpVal
	let alrb_delta=`expr $alrb_timenow - $alrb_lastUpdate`
	if [ $alrb_delta -gt $alrb_validTime ]; then
	    let alrb_retCode=$alrb_errCode
	fi
    fi
    if [[ $alrb_retCode -ne 0 ]] && [[ "$alrb_quietVal" = "NO" ]]; then
	\echo $alrb_warnMsg
	if [ -e $alrb_tsFile ]; then
	    \tail -n 1 $alrb_tsFile
	fi
    fi
    return $alrb_retCode
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h,v" 
alrb_longopts="help,quiet,validTime:,checkOnly:,exitCodeFor:"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_quietVal="NO"
alrb_validTimeVal=""
alrb_checkOnlyVal=",all,"
alrb_exitCodeForVal=",none,"
while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_checkValidityHelp
            exit 0
            ;;
        --quiet)
	    alrb_quietVal="YES"
	    shift
            ;;
        --checkOnly)
	    alrb_checkOnlyVal=",$2,"	    
	    shift 2
            ;;
        --exitCodeFor)
	    alrb_exitCodeForVal=",$2,"
	    shift 2
            ;;
        --validTime)
	    alrb_validTimeVal=",$2,"
	    shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

# verify input option checkOnly
if [ "$alrb_checkOnlyVal" != "" ]; then
    alrb_tmpVal=$alrb_checkOnlyVal
    let alrb_idx=0
    for alrb_item in "${alrb_nameAr[@]}"; do
	if [ "$alrb_tmpVal" = ",all," ]; then
	    alrb_checkAr[$alrb_idx]="YES"
	else    
	    alrb_checkAr[$alrb_idx]="NO"
	    alrb_result=`\echo $alrb_checkOnlyVal | \grep ",$alrb_item," >/dev/null 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_checkAr[$alrb_idx]="YES"
		alrb_myCmd="\echo $alrb_tmpVal | \sed 's/$alrb_item//g'"
		alrb_tmpVal=`eval $alrb_myCmd`
	    fi
	fi
	let alrb_idx++
    done
    alrb_tmpVal=`\echo $alrb_tmpVal | \sed -e 's/all//g' -e 's/none//g' -e 's/[ ,]*//g'`
    if [ "$alrb_tmpVal" != "" ]; then
	\echo "Error: checkOnly unknown values $alrb_tmpVal"
	exit 64
    fi
fi

# verify input option exitCodeFor
if [ "$alrb_exitCodeForVal" != "" ]; then
    alrb_tmpVal=$alrb_exitCodeForVal
    let alrb_idx=0
    for alrb_item in "${alrb_nameAr[@]}"; do
	if [ "$alrb_tmpVal" = ",all," ]; then
	    alrb_exitCodeAr[$alrb_idx]="YES"
	elif [ "$alrb_tmpVal" = ",none," ]; then
	    alrb_exitCodeAr[$alrb_idx]="NO"
	else
	    alrb_exitCodeAr[$alrb_idx]="NO"
	    alrb_result=`\echo $alrb_exitCodeForVal | \grep ",$alrb_item," >/dev/null 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_exitCodeAr[$alrb_idx]="YES"
		alrb_myCmd="\echo $alrb_tmpVal | \sed 's/$alrb_item//g'"
		alrb_tmpVal=`eval $alrb_myCmd`
	    fi
	fi
	let alrb_idx++
    done
    alrb_tmpVal=`\echo $alrb_tmpVal | \sed -e 's/all//g' -e 's/none//g' -e 's/[ ,]*//g'`
    if [ "$alrb_tmpVal" != "" ]; then
	\echo "Error: exitCodeFor unknown values $alrb_tmpVal"
	exit 64
    fi
fi

# verify input option validTime
if [ "$alrb_validTimeVal" != "" ]; then
    alrb_tmpVal=$alrb_validTimeVal
    let alrb_idx=0
    for alrb_item in "${alrb_nameAr[@]}"; do
	alrb_myCmd="\echo $alrb_validTimeVal | \sed -e 's/.*,\($alrb_item:.[0-9]*\),.*/\1/g'"
	alrb_result=`eval $alrb_myCmd`
	if [[ "$alrb_result" != "$alrb_validTimeVal" ]] && [[ "$alrb_result" != "" ]]; then
	    alrb_newTime=`\echo $alrb_result | \cut -f 2 -d ":"`
	    alrb_validTimeAr[$alrb_idx]=$alrb_newTime
	    alrb_myCmd="\echo $alrb_tmpVal | \sed 's/$alrb_result//g'"
	    alrb_tmpVal=`eval $alrb_myCmd`
	fi
	let alrb_idx++
    done
    alrb_tmpVal=`\echo $alrb_tmpVal | \sed 's/[ ,]*//g'`
    if [ "$alrb_tmpVal" != "" ]; then
	\echo "Error: validTime unknown values $alrb_tmpVal"
	exit 64
    fi
fi


let alrb_timenow=`date +%s`
let alrb_exitCode=0

let alrb_idx=0
for alrb_item in "${alrb_nameAr[@]}"; do
    if [ "$alrb_item" = "alrb" ]; then
	# skip since there is no local alrb installation
	if [ "$ATLAS_LOCAL_ROOT_BASE" = "$ALRB_cvmfs_repo/ATLASLocalRootBase" ]; then
	    let alrb_idx++    
	    continue
	fi
    elif [ "$alrb_item" = "nightlies" ]; then
	# skip if nightlies are not mounted and exit code not requested
	if [[ "$ALRB_cvmfs_nightly_repo" = "" ]] || [[ ! -d $ALRB_cvmfs_nightly_repo ]]; then
	    if [ "${alrb_exitCodeAr[$alrb_idx]}" != "YES" ]; then
		let alrb_idx++    
		continue
	    fi
	fi
    elif [ "$alrb_item" = "atlas" ]; then
	# skip if eg cvmfs is not available on purpose
	if [ "$ALRB_cvmfs_repo" = "/none" ]; then
	    if [ "${alrb_exitCodeAr[$alrb_idx]}" != "YES" ]; then
		let alrb_idx++    
		continue
	    fi
	fi
    elif [ "$alrb_item" = "condb" ]; then
	# skip if eg cvmfs is not available on purpose
	if [ "$ALRB_cvmfs_condb_repo" = "/none" ]; then
	    if [ "${alrb_exitCodeAr[$alrb_idx]}" != "YES" ]; then
		let alrb_idx++    
		continue
	    fi
	fi
    elif [ "$alrb_item" = "sft" ]; then
	# skip if eg cvmfs is not available on purpose
	if [ "$ALRB_cvmfs_sft_repo" = "/none" ]; then
	    if [ "${alrb_exitCodeAr[$alrb_idx]}" != "YES" ]; then
		let alrb_idx++    
		continue
	    fi
	fi
	
    fi

    alrb_tsFile=${alrb_tsFileAr[$alrb_idx]}
    let alrb_errCode=${alrb_errorCodeAr[$alrb_idx]}
    let alrb_validTime=${alrb_validTimeAr[$alrb_idx]}
    alrb_warnMsg=${alrb_warnMsgAr[$alrb_idx]}

    if [ "${alrb_checkAr[$alrb_idx]}" = "YES" ]; then
	alrb_fn_doCheckValid
	alrb_rc=$?
	if [ "${alrb_exitCodeAr[$alrb_idx]}" = "YES" ]; then
	    alrb_exitCode=$((alrb_exitCode | alrb_rc ))
	fi
    fi
    let alrb_idx++    
done


exit $alrb_exitCode
