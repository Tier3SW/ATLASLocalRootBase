#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! validator.sh
#!
#! Checks the arguments, dependencies 
#!
#! Usage:
#!     validator.sh <args passed to localSetup>
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=lsetup


alrb_fn_glocalSetupHelp()
{
    \cat <<EOF

    Global options (to override defaults) are:
     -h --help              Print this help message
     -q --quiet             Print no output
     -s --skipConfirm       Skip all confirmation queries
     -f --force             Force setup of tools even if they were already 
                             setup (eg gcc, python and grid middleware)
EOF
}


alrb_fn_localSetupHelp()
{
    \cat <<EOF

Usage: $alrb_progname tool [tool ...] [globalOptions]

    This sets up the ATLAS environment for multiple software tools

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
EOF
alrb_fn_glocalSetupHelp
\cat <<EOF
     -a --asetupVersion     Version of asetup to use
     -r --rcsetupVersion    Version of rcSetup to use

    where tools to setup can be specified as sw name with options and version;
        "sw [local options] <version>"
     note that if tool options / arguents are specified, it should be quoted to
     group it as part of the tool and not of lsetup.  See examples:

    eg to setup athena <version> and panda 
       lsetup "asetup 17.2.8.7,slc5,here" panda

    eg to setup root <version> and panda 
       lsetup "root 6.02.05-x86_64-slc6-gcc48-opt" panda

    eg to setup fax and root  (instead of localSetupFAX --rootVersion=...)
       lsetup fax root
   
    eg to setup ASG releases and fax
       lsetup "rcSetup Base,1.0.1" fax

    eg lcgenv usage
       lsetup "lcgenv -p LCG_81e"

    sw can be one or more of the following:
EOF

    \echo -n "      "
    \echo $ALRB_availableTools
    \echo " "
\cat <<EOF
    To obtain more help, type 'lsetup -h <tool> [<tool> ...]'
EOF
}


alrb_fn_prioritizeTools()
{

    local alrb_InputAr=( "$@" )

    if [ ${#alrb_InputAr[@]} -le 1 ]; then
	alrb_SetupToolAr=( "${alrb_InputAr[@]}" )
	return 0
    fi

    local alrb_result
    local alrb_item
    local let alrb_idx=0
    local alrb_unknownAr=()
    local alrb_bufferAr=()
    for alrb_item in "${alrb_InputAr[@]}"; do
	local alrb_toolRequested=`\echo $alrb_item | \cut -f 1 -d " "`
	alrb_result=`\grep -n -i ",$alrb_toolRequested," $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt 2>&1`
	if [ $? -eq 0 ]; then
	    let alrb_idx=`\echo "$alrb_result" | \cut -f 1 -d ":"`
	    alrb_bufferAr[$alrb_idx]="${alrb_bufferAr[$alrb_idx]}|$alrb_item"
	else
	    alrb_unknownAr=(  ${alrb_unknownAr[@]} "$alrb_item" )
	fi
    done
    local alrb_OIFS=$IFS;
    IFS="|";    
    for alrb_item in "${alrb_bufferAr[@]}"; do
	local alrb_tmpAr=($alrb_item)
	for alrb_result in "${alrb_tmpAr[@]}"; do
	    if [ "$alrb_result" != "" ]; then
		alrb_SetupToolAr=( "${alrb_SetupToolAr[@]}" "$alrb_result" )
	    fi
	done
    done
    IFS=$alrb_OIFS

    alrb_SetupToolAr=( "${alrb_SetupToolAr[@]}" "${alrb_unknownAr[@]}" )

    return 0

}


alrb_shortopts="h,q,s,w:,f,p:,a:,r:" 
alrb_longopts="help,quiet,skipConfirm,force,asetupVersion,rcsetupVersion"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_Quiet="NO"
alrb_SkipConfirm="NO"
alrb_doHelp="NO"
alrb_lsWorkarea=""
alrb_Force="NO"
alrb_pass=""

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
	    alrb_doHelp="YES"
	    shift
            ;;
        -q|--quiet)
            alrb_Quiet="YES"
	    alrb_SkipConfirm="YES"
            shift 
            ;;
        -s|--skipConfirm)
            alrb_SkipConfirm="YES"
            shift 
            ;;
        -f|--force)
            alrb_Force="YES"
            shift 
            ;;
        -w)
            alrb_lsWorkarea="$2"
            shift 2
            ;;
        -a|--asetupVersion)
            export ALRB_asetupVersion="$2"
            shift 2
            ;;
        -r|--rcsetupVersion)
            export ALRB_rcsetupVersion="$2"
            shift 2
            ;;
        -p)
            alrb_pass="$2"
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

if [ "$alrb_lsWorkarea" = "" ]; then
    \echo "Error: validator needs workarea passed to it." 1>&2
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/versionChecker.sh

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/parseVersionVar.sh

source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/functions.sh

source ${alrb_lsWorkarea}/client.sh

if [ "$*" = "" ]; then
    if [ "$alrb_doHelp" != "YES" ]; then
	\echo "Nothing to setup ... did you forget arguments ?" 1>&2
    fi
    alrb_fn_localSetupHelp
    touch ${alrb_lsWorkarea}/finishedPass
    exit 0
else
    
    if [ "$ALRB_clientShell" = "tcsh" ]; then
	alrb_setupScriptExt=".csh"
	alrb_set="set"
	alrb_afterCmd=' || exit $?'
    else
	alrb_setupScriptExt=".sh"
	alrb_set=""
	alrb_afterCmd=' || return $?'
    fi
    alrb_preSetupScript="${alrb_lsWorkarea}/preSetupScript${alrb_setupScriptExt}"
    alrb_setupScript="${alrb_lsWorkarea}/setupScript${alrb_setupScriptExt}"
    alrb_postSetupScript="${alrb_lsWorkarea}/postSetupScript${alrb_setupScriptExt}"
    
# if there is no asetup or rcsetup, only one pass is needed
    alrb_result=`\echo $@ | \grep -i -e "asetup" -e "rcsetup" 2>&1`
    if [ $? -ne 0 ]; then
	alrb_onePass="YES"
    else
	alrb_onePass="NO"
    fi
    
# if help, then it is for all for consistency
    alrb_result=`\echo $@ | \grep -w -e "-h" -e "--help" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_doHelp="YES"
	alrb_onePass="YES"
    fi

    alrb_toolsForNextPass=""
    alrb_SetupToolAr=()
    alrb_fn_prioritizeTools "$@"

    alrb_requested=""    
    alrb_addHelp=()
    for alrb_item in "${alrb_SetupToolAr[@]}"; do
	alrb_toolRequested=`\echo $alrb_item | \cut -f 1 -d " "`
	alrb_toolRequestedArgs=`\echo $alrb_item | \cut -f 2- -d " "`
	alrb_result=`\grep -i ",$alrb_toolRequested," $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt 2>&1`
	alrb_rc=$?
	if [ $alrb_rc -eq 0 ]; then
	    alrb_tmpVal=",`\echo $alrb_result | \cut -f 4- -d ","`"
	    alrb_tmpVal=`\echo $alrb_tmpVal | \grep -i ",$alrb_toolRequested,"`
	    alrb_rc=$?
	fi
	if [ $alrb_rc -eq 0 ]; then
	    \eval alrb_${alrb_toolRequested}_request="\"$alrb_toolRequestedArgs\""
	    alrb_requested="$alrb_requested $alrb_toolRequested"
	    alrb_tool=`\echo $alrb_result | \cut -f 4 -d ","`
	    alrb_toolPass=`\echo $alrb_result | \cut -f 2 -d ","`
	    if [ "$alrb_doHelp" = "YES" ]; then
		alrb_leftover=" -h"
	    else
		alrb_leftover=`\echo $alrb_item | \cut -f 2- -d " "`
		if [ "$alrb_leftover" = "$alrb_toolRequested" ]; then
		    alrb_leftover=""
		fi
		if [ $alrb_onePass = "NO" ]; then
		    if [ "$alrb_pass" = "Pass1" ]; then
			alrb_fn_traceDependency "$alrb_tool"
		    fi
		    if [ "$alrb_toolPass" != "$alrb_pass" ]; then
			alrb_toolsForNextPass="${alrb_toolsForNextPass[@]} $alrb_tool"
			continue
		    fi
		fi
	    fi
	    alrb_result=`\echo $ALRB_availableTools | \grep -i "[^ ]*${alrb_tool}[ $]*" 2>&1`
	    if [ $? -ne 0 ]; then
		\echo "Error: tool unavailable for this platform: $alrb_tool" 1>&2
		exit 64
	    fi	
	    alrb_CandToolArg="$alrb_leftover"
	    alrb_OverriddenDependencies=""
	    alrb_PrimaryTool="$alrb_tool"
	    alrb_fn_depend "$alrb_tool" "$alrb_leftover" -c validator
	    if [ $? -ne 0 ]; then
		exit 64
	    fi
	    unset alrb_OverriddenDependencies
	    unset alrb_PrimaryTool
	    unset alrb_CandToolArg
	else
	    \echo "Error: unknown tool: $alrb_toolRequested" 1>&2
	    \echo " If it is a version or option for a tool, you need to put it in double quotes." 1>&2
	    exit 64
	fi
    done    

    if [ "$alrb_doHelp" = "YES" ]; then
	for alrb_item in "${alrb_addHelp[@]}"; do
	    eval $alrb_item
	done
	touch ${alrb_lsWorkarea}/finishedPass
	exit 0	
    fi

    if [ "$alrb_toolsForNextPass" = "" ]; then
	touch ${alrb_lsWorkarea}/finishedPass
    fi
    
    if [[ $alrb_onePass = "NO" ]] && [[ $alrb_pass = "Pass1" ]]; then
# look for dependencies that are required to do on first pass
	alrb_tmpAr=( `\grep -e "Pass1" $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt | \cut -f 4 -d ","`)
	for alrb_item in "${alrb_tmpAr[@]}"; do
	    alrb_toolRequested=$(\echo alrb_${alrb_item}_setup)
	    alrb_toolDependency=$(\echo alrb_${alrb_item}_dependency)
	    if [[ "${!alrb_toolRequested}" = "" ]] && [[ "${!alrb_toolDependency}" != "" ]]; then
		alrb_fn_getPass1Dependency "$alrb_item"
		if [ $? -ne 0 ]; then
		    exit $?
		fi
	    fi
	done
    fi
fi

if [ $alrb_onePass = "YES" ]; then
    touch ${alrb_lsWorkarea}/finishedPass
fi

alrb_RequestedVersions=""
alrb_SetupToolAr=( `\grep -i -e '^,[A-Z]*' $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt | \cut -f 4 -d ","  |  \tr '[:upper:]' '[:lower:]'` )
if [ "$alrb_pass" = "Pass1" ]; then
#    \echo "$alrb_set alrb_Requested=\"$alrb_requested\"" >> $alrb_preSetupScript
    \echo "$alrb_set alrb_Quiet=$alrb_Quiet" >> $alrb_preSetupScript
    \echo "$alrb_set alrb_Force=$alrb_Force" >> $alrb_preSetupScript
    \echo "$alrb_set alrb_SkipConfirm=$alrb_SkipConfirm" >> $alrb_preSetupScript
    if [ "$alrb_Quiet" != "YES" ]; then
	\echo "\echo '************************************************************************'" >> $alrb_preSetupScript
	\echo "\echo \"Requested: $alrb_requested ... \" " >> $alrb_preSetupScript
    fi

    \echo "$alrb_set alrb_Quiet=$alrb_Quiet" >> $alrb_postSetupScript
    \echo "$alrb_set alrb_Force=$alrb_Force" >> $alrb_postSetupScript
    \echo "$alrb_set alrb_SkipConfirm=$alrb_SkipConfirm" >> $alrb_postSetupScript

fi

\echo "$alrb_set alrb_Quiet=$alrb_Quiet" >> $alrb_setupScript
\echo "$alrb_set alrb_Force=$alrb_Force" >> $alrb_setupScript
\echo "$alrb_set alrb_SkipConfirm=$alrb_SkipConfirm" >> $alrb_setupScript

for alrb_item in ${alrb_SetupToolAr[@]}; do
    alrb_done=$(\echo alrb_${alrb_item}_done)
    if [ "${!alrb_done}" = "YES" ]; then
	continue
    fi
    alrb_toolVersion=$(\echo alrb_${alrb_item}_setup)
    alrb_skip=$(\echo alrb_${alrb_item}_skip)
    if [ "${!alrb_toolVersion}" != "" ]; then	
	alrb_done=$(\echo alrb_${alrb_item}_done)
	if [ "${!alrb_done}" = "YES" ]; then
	    continue
	fi
	\echo "alrb_${alrb_item}_done=YES" >> ${alrb_lsWorkarea}/client.sh
	alrb_tool_extra=$(\echo alrb_${alrb_item}_extra)
	if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/setup-${ALRB_OSTYPE}${alrb_setupScriptExt} ]; then
	    alrb_toolSetup="setup-${ALRB_OSTYPE}${alrb_setupScriptExt}"
	else
	    alrb_toolSetup="setup${alrb_setupScriptExt}"
	fi
	if [ "$alrb_Quiet" != "YES" ]; then
	    \echo "\printf ' Setting up \e[4m$alrb_item ${!alrb_toolVersion}\e[0m ... \n'" >> $alrb_setupScript
	fi

	alrb_RequestedVersions="${alrb_item}:${!alrb_toolVersion} $alrb_RequestedVersions"

	if [ "${!alrb_skip}" = "" ]; then
	    \echo "source \$ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/$alrb_toolSetup \"${!alrb_toolVersion}\" \"${!alrb_tool_extra}\" $alrb_afterCmd " >> $alrb_setupScript
	    if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/postSetup-${ALRB_OSTYPE}${alrb_setupScriptExt} ]; then
		alrb_toolSetup="postSetup-${ALRB_OSTYPE}${alrb_setupScriptExt}"
	    elif [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/postSetup${alrb_setupScriptExt} ]; then
		alrb_toolSetup="postSetup${alrb_setupScriptExt}"
	    else
		alrb_toolSetup=""
	    fi
	    if [  "$alrb_toolSetup" != "" ]; then
		\echo "source \$ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/$alrb_toolSetup \"${!alrb_toolVersion}\" \"${!alrb_tool_extra}\" $alrb_afterCmd " >> $alrb_postSetupScript
	    fi
	else
	    if [ "$alrb_Quiet" != "YES" ]; then
		\echo "\echo \"  Skipping: ${!alrb_skip}\" " >> $alrb_setupScript
	    fi
	fi

# always run these post setups
	if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/postSetupAlways-${ALRB_OSTYPE}${alrb_setupScriptExt} ]; then
	    alrb_toolSetup="postSetupAlways-${ALRB_OSTYPE}${alrb_setupScriptExt}"
	elif [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/postSetupAlways${alrb_setupScriptExt} ]; then
	    alrb_toolSetup="postSetupAlways${alrb_setupScriptExt}"
	else
	    alrb_toolSetup=""
	fi
	if [  "$alrb_toolSetup" != "" ]; then
	    \echo "source \$ATLAS_LOCAL_ROOT_BASE/swConfig/$alrb_item/$alrb_toolSetup ${!alrb_toolVersion}" "${!alrb_tool_extra} $alrb_afterCmd " >> $alrb_postSetupScript
	fi

    fi
done

\echo "$alrb_set ALRB_requestedVersions=\"$alrb_RequestedVersions \$ALRB_requestedVersions\"" >> $alrb_postSetupScript

if [ -e ${alrb_lsWorkarea}/finishedPass ]; then
    if [ "$alrb_Quiet" != "YES" ]; then
	if [ -e $alrb_postSetupScript ];  then
	    \mv $alrb_postSetupScript ${alrb_postSetupScript}.save
	    \echo "\echo '>>>>>>>>>>>>>>>>>>>>>>>>> Information for user <<<<<<<<<<<<<<<<<<<<<<<<<'" >> $alrb_postSetupScript
	    \cat ${alrb_postSetupScript}.save >> ${alrb_postSetupScript}
	fi
	\echo "\echo '************************************************************************'" >> $alrb_postSetupScript
    fi
    \echo "unset alrb_Quiet alrb_SkipConfirm alrb_Force" >> $alrb_postSetupScript
fi

exit 0

