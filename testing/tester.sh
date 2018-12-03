#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! tester.sh
#!
#! Runs tests on any tool
#!
#! Usage:
#!     tester.sh --help
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=tester

#!----------------------------------------------------------------------------
alrb_fn_testerHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: $alrb_progname tool [tool ...] [globalOptions]

    where tool is any tool, or can be specified as "all"

    This is a testing application for the tools in ATLASLocalRootBase

    Options (to override defaults) are:
     -h --help              Print this help message
     -m --mode              Testing mode (user / test/ validate)
     -n --nodep             Skip dependency testing
     -o --override          Dir which contains overrides.  The file structure 
                             similat to \$ATLAS_LOCAL_ROOT_BASE/testing/config
     -s --shells            Comman separated list of shells to test 
                             (default: bash,zsh)
     -t --tarfile           save workdir as a specified tar file 
     -v --verbose           Verbose output
         
EOF

    local alrb_toolTestingConfigs="$ATLAS_LOCAL_ROOT_BASE/testing/config"
    while [ $# -gt 0 ]; do
	local alrb_tmpVal=""
	if [ -e "$alrb_toolTestingConfigs/$1/config-${ALRB_OSTYPE}.sh" ]; then
	    alrb_tmpVal="$alrb_toolTestingConfigs/$1/config-${ALRB_OSTYPE}.sh"
	elif [ -e "$alrb_toolTestingConfigs/$1/config.sh" ]; then
	    alrb_tmpVal="$alrb_toolTestingConfigs/$1/config.sh"
	fi
	if [ "$alrb_tmpVal" != "" ]; then
	    \echo "

$1 variables that can be set:"
	    \grep -e "^##" $alrb_tmpVal | \sed -e 's/^##/  /g'

	fi
	shift  
    done
}


#!----------------------------------------------------------------------------
alrb_fn_checkRequirements()
#!----------------------------------------------------------------------------
{
    local alrb_retCode=0

    if [ -z $RUCIO_ACCOUNT ]; then
	\echo "Error: Need to define \$RUCIO_ACCOUNT"
	let alrb_retCode=1
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_initSummary() 
#!----------------------------------------------------------------------------
{
    
    if [ $# -ne 3 ]; then
	\echo "Error: incorrect number of args passed to init"
	return 64
    fi

    if [ "$alrb_ThisTool" != "$1" ]; then
	alrb_resultFile="$alrb_SummaryDir/summary_${1}.txt"
	let alrb_ThisStep=1
	alrb_SummaryAr=()
    elif [[ "$alrb_ThisTool" != "$1" ]] \
	|| [[ "$alrb_ThisShell" != "$2" ]] \
	|| [[ "$alrb_TestDescription" != "$3" ]]; then
	let alrb_ThisStep+=1
    fi

    alrb_ThisTool="$1"
    alrb_ThisShell="$2"
    alrb_TestDescription="$3"
    
    alrb_setStatus=""
    printf "\n\n\033[7m%3s\033[0m %-60s\n" "${alrb_ThisStep}:" "${alrb_TestDescription} (${alrb_ThisShell}) ..."
    
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_addSummary() 
#!----------------------------------------------------------------------------
{

    if [ $# -eq 2 ]; then
	local alrb_exitCode=$1
	local alrb_next=$2
    elif [ $# -eq 3 ]; then
	local alrb_exitCode=$1
	local alrb_next=$2
	local alrb_setStatus=$3
    else
	\echo "Error: incorrect number of args passed to add"
	return 64
    fi

    local alrb_status

    local alrb_color="32"
    if [ "$alrb_exitCode" -eq 0 ]; then
	alrb_status=" OK "
    else
	local alrb_color="31"
	alrb_status="FAILED"
    fi
    if [ "$alrb_setStatus" != "" ]; then
	alrb_status="$alrb_setStatus"
	local alrb_color="34"
    fi
    
    printf "%-67s [\033[%2sm%6s\033[0m]\n" "$alrb_TestDescription ($alrb_ThisShell)" $alrb_color "$alrb_status"
    
    alrb_SummaryAr=( "${alrb_SummaryAr[@]}" "$alrb_ThisStep:$alrb_ThisShell:$alrb_TestDescription:$alrb_status" ) 

    if [[ "$alrb_next" = "exit" ]] && [[ $alrb_exitCode -ne 0 ]]; then
	alrb_fn_printSummary
#	alrb_fn_cleanup	
	exit $alrb_exitCode
    fi
    
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_printSummaryAll() 
#!----------------------------------------------------------------------------
{

    local alrb_title="Summary of All Tests"
    printf "\n\n\033[34m\033[1m%*s\033[0m\n" $((${#alrb_title}+20)) "$alrb_title"

    \cat $alrb_SummaryDir/summary_*.txt
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_printSummary() 
#!----------------------------------------------------------------------------
{
    
    if [ "$alrb_resultFile" != "" ]; then
	\rm -f $alrb_resultFile
    fi
    
    if [ ${#alrb_SummaryAr[@]} -gt 0 ]; then
	printf "\n\n  %4s %-50s %10s\n" "Step" "Test Description for $alrb_ThisTool" "Result"
	printf "\n\n  %4s %-50s %10s\n" "Step" "Test Description for $alrb_ThisTool" "Result" > $alrb_resultFile
    fi
    local alrb_item
    for alrb_item in "${alrb_SummaryAr[@]}"; do
	
	local alrb_step=`\echo $alrb_item | \cut -d ":" -f 1`
	local alrb_shell=`\echo $alrb_item | \cut -d ":" -f 2`
	local alrb_descr=`\echo $alrb_item | \cut -d ":" -f 3`
	local alrb_result=`\echo $alrb_item | \cut -d ":" -f 4`
	printf "  %4s %-50s %10s\n" "$alrb_step" "$alrb_descr ($alrb_shell)" "$alrb_result"
	printf "  %4s %-50s %10s\n" "$alrb_step" "$alrb_descr ($alrb_shell)" "$alrb_result" >> $alrb_resultFile
    done
    if [ ${#alrb_SummaryAr[@]} -gt 0 ]; then
	\echo  " "
    fi
    
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_cleanup() 
#!----------------------------------------------------------------------------
{

    local let alrb_nLines=0
    if [ -e $alrb_workDir/skippedTools ]; then
	let alrb_nLines=`wc -l $alrb_workDir/skippedTools | cut -f 1 -d " "`
	if [ $alrb_nLines -ge 0 ]; then
	    local alrb_title="Tests Skipped"
	    printf "\n\n\033[34m\033[1m%*s\033[0m\n" $((${#alrb_title}+20)) "$alrb_title"
	    env LC=ALL \sort -u $alrb_workDir/skippedTools
	fi
    fi

    if [ -e $alrb_workDir/ignoredTools ]; then	
	let alrb_nLines=`wc -l $alrb_workDir/ignoredTools | cut -f 1 -d " "`
	if [ $alrb_nLines -ge 0 ]; then	    
	    local alrb_title="Tests Ignored"
	    printf "\n\n\033[34m\033[1m%*s\033[0m\n" $((${#alrb_title}+20)) "$alrb_title"
	    env LC=ALL \sort -u $alrb_workDir/ignoredTools
	fi
    fi

    if [ "$alrb_workDir" != "" ]; then
	if [ "$alrb_tarfile" != "" ]; then
	    local alrb_tmpVal=`\dirname $alrb_tarfile`
	    \mkdir -p $alrb_tmpVal
	    if [ -f $alrb_tarfile ]; then
		\rm -f $alrb_tarfile
	    fi
	    tar zcf $alrb_tarfile $alrb_workDir
	fi
	\rm -rf $alrb_workDir
    fi
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_createWorkdir()
#!----------------------------------------------------------------------------
{
    \mkdir -p ${ALRB_tmpScratch}/testing
    alrb_workDir=`\mktemp -d ${ALRB_tmpScratch}/testing/tester.XXXXXX`
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_SummaryDir="$alrb_workDir/summary"
    \mkdir -p $alrb_SummaryDir

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_runShellScript()
#!----------------------------------------------------------------------------
{
    local alrb_retCode=0

    local alrb_thisShell="$1"
    local alrb_runScript="$2"
    
    if [ "$alrb_thisShell" = "bash" ]; then
        env -i bash -l -c "source $alrb_runScript"  2>&1 
    elif [ "$alrb_thisShell" = "zsh" ]; then
        env -i zsh -l -c "source $alrb_runScript" 2>&1 
    else
	\echo "Error: unknown shell $alrb_thisShell"
	return 64
    fi
    alrb_retCode=$?

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_doToolSetupConfig()
#!----------------------------------------------------------------------------
{

    local alrb_tool=$1

    if [[ "$alrb_overrideDir" != "" ]] && [[ -e "$alrb_overrideDir/$alrb_tool/config-${ALRB_OSTYPE}.sh" ]]; then
	source $alrb_overrideDir/$alrb_tool/config-${ALRB_OSTYPE}.sh
    elif [[ "$alrb_overrideDir" != "" ]] && [[ -e "$alrb_overrideDir/$alrb_tool/config.sh" ]]; then
	source $alrb_overrideDir/$alrb_tool/config.sh
    elif [ -e "$alrb_toolTestingConfigs/$alrb_tool/config-${ALRB_OSTYPE}.sh" ]; then
	source $alrb_toolTestingConfigs/$alrb_tool/config-${ALRB_OSTYPE}.sh
    elif [ -e "$alrb_toolTestingConfigs/$alrb_tool/config.sh" ]; then
	source $alrb_toolTestingConfigs/$alrb_tool/config.sh
    else	
	return 1
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_doToolSetup()
#!----------------------------------------------------------------------------
{
    local alrb_tool=$1

    local alrb_toolTestingConfigs="$ATLAS_LOCAL_ROOT_BASE/testing/config"
    local alrb_toolTestingScripts="$ATLAS_LOCAL_ROOT_BASE/testing/scripts"

    source $ATLAS_LOCAL_ROOT_BASE/testing/config/masterCfg.sh

    if [ -e "$alrb_workDir/dep/$alrb_tool" ]; then
	local alrb_tmpAr=( `\cat $alrb_workDir/dep/$alrb_tool` )
	local alrb_item
	for alrb_item in ${alrb_tmpAr[@]}; do
	    alrb_fn_doToolSetupConfig $alrb_item
	done
    fi
    alrb_fn_doToolSetupConfig $alrb_tool
    if [ $? -ne 0 ]; then
	\echo $alrb_tool >> $alrb_workDir/skippedTools
	return 1
    fi

    if [ ${#alrb_shellListAr[@]} -gt 0 ]; then
	alrb_testShellAr=( ${alrb_shellListAr[@]} )
    fi
    
    if [ -e "$alrb_toolTestingScripts/$alrb_tool/functions-${ALRB_OSTYPE}.sh" ]; then
	source $alrb_toolTestingScripts/$alrb_tool/functions-${ALRB_OSTYPE}.sh
    elif [ -e "$alrb_toolTestingScripts/$alrb_tool/functions.sh" ]; then
	source $alrb_toolTestingScripts/$alrb_tool/functions.sh
    else
	return 1
    fi

# supplemental config files that may need to be setup and are not a dependency
    local alrb_item
    local alrb_tmpAr=( `typeset  -f alrb_fn_${alrb_tool}TestSetupEnv | \grep -e alrb_fn_sourceTestFunctions | \sed -e 's|.*alrb_fn_sourceTestFunctions||g' -e 's|;||g' -e 's| ||g'` )
    for alrb_item in ${alrb_tmpAr[@]}; do
	if [ "$alrb_item" != "" ]; then
	    alrb_fn_doToolSetupConfig $alrb_item
	fi
    done

    return 0
}

#!----------------------------------------------------------------------------
alrb_fn_doTest()
#!----------------------------------------------------------------------------
{
    local alrb_tool
    alrb_testToolAr=( `\echo ${alrb_testToolAr[@]} | \tr [:space:] '\n' | \awk '!a[$0]++'` )
    local alrb_result
    for alrb_tool in ${alrb_testToolAr[@]}; do
	alrb_result=`\grep -e "^$ALRB_OSTYPE:$alrb_tool[[:space:]]" $ATLAS_LOCAL_ROOT_BASE/testing/config/test-ignore.txt 2>&1`
	if [ $? -eq 0 ]; then
	    \echo "$alrb_result" >> $alrb_workDir/ignoredTools
	    continue
	fi
	(
	    alrb_fn_doToolSetup $alrb_tool
	    if [ $? -eq 0 ]; then
		\echo "$alrb_tool" >> $alrb_workDir/testedTools
		alrb_toolWorkdir="$alrb_workDir/$alrb_tool"
		\mkdir -p $alrb_toolWorkdir
		alrb_fn_saveEnvs $alrb_toolWorkdir
		alrb_fn_${alrb_tool}TestRun
		alrb_fn_printSummary
	    else
		continue
	    fi
	    if [ $? -ne 0 ]; then
		return 64
	    fi
	)
    done

    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_getDependencies() 
#!---------------------------------------------------------------------------- 
{

    local alrb_item
    local alrb_item2
    local alrb_result

    \mkdir -p $alrb_workDir/dep
    
    $ATLAS_LOCAL_ROOT_BASE/testing/config/dependencies-hidden.sh $alrb_workDir/dep

    local alrb_tmpAr=( `\echo $ALRB_availableTools` )
    for alrb_item in ${alrb_tmpAr[@]}; do
	(
	    alrb_fn_sourceFunctions $alrb_item
	    alrb_result=`type -t alrb_fn_${alrb_item}Depend`
	    if [ $? -eq 0 ]; then
		alrb_fn_traceDependency $alrb_item 
	    fi
	    for alrb_item2 in ${alrb_tmpAr[@]}; do
 		local alrb_toolDependency=$(\echo alrb_${alrb_item2}_dependency)
		if [ "${!alrb_toolDependency}" != "" ]; then
		    \echo "$alrb_item2" >> $alrb_workDir/dep/$alrb_item
		fi
	    done
	)
    done

    alrb_tmpAr=( `\echo $alrb_toolList | \sed -e 's/,/ /g'` ) 
    for alrb_item in ${alrb_tmpAr[@]}; do    
	alrb_result=`\echo $ALRB_availableTools | \grep -e $alrb_item 2>&1`
	if [ $? -ne 0 ]; then
	    \echo "Error: tool $alrb_item is unknown or unavailable for this platform"
	    return 64
	fi
	alrb_testToolAr=( ${alrb_testToolAr[@]} "$alrb_item" )

	if [ "$alrb_skipRunDependency" != "YES" ]; then
	    local alrb_tmpAr2=( `\grep -l $alrb_item $alrb_workDir/dep/* | \sed -e 's|'$alrb_workDir'/dep/||g'` )
	    for alrb_item2 in ${alrb_tmpAr2[@]}; do
		alrb_result=`\grep -e "^$ALRB_OSTYPE:$alrb_item:$alrb_item2" $ATLAS_LOCAL_ROOT_BASE/testing/config/dependencies-ignore.txt 2>&1`
		if [ $? -ne 0 ]; then
		    alrb_testToolAr=( ${alrb_testToolAr[@]} "$alrb_item2" )
		fi
	    done
	fi
    done

    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_saveEnvs()
#!---------------------------------------------------------------------------- 
{

    local alrb_envDir=$1
    alrb_envFile="$alrb_envDir/envs"
    local alrb_tmpVal='env | \grep 
 -e "USER="
 -e "DISPLAY="
 -e "HOME="
 -e "TMPDIR="
 -e "SITE_NAME="
 -e "PANDA_SITE_NAME="
 -e "SSH_AUTH_SOCK="
 -e "ATLAS_SITE_NAME="
 -e "X509_USER_PROXY="
 -e "RUCIO_ACCOUNT="
 -e "FRONTIER_SERVER="
 -e "ALRB_[[:alnum:]]*Version="
 -e "ALRB_menuFmtSkip="
 -e "ALRB_CONT_[[:alnum:]]*="
 -e "ALRB_testPath="
 -e "ALRB_test[[:alnum:]]*="
| \cut -f 1 -d "="
'
    
    local alrb_item
    for alrb_item in `eval $alrb_tmpVal`; do
	\echo export ${alrb_item}=\"${!alrb_item}\" >> $alrb_envFile.sh
    done

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_getProxy()
#!----------------------------------------------------------------------------
{
    local alrb_doProxy=""
    local alrb_result
    local alrb_item
    local alrb_needProxy=""

    alrb_result=`\echo $ALRB_availableTools | \grep -e "emi" 2>&1`
    if [ $? -ne 0 ]; then
	return 0
    fi

    if [ "$alrb_toolList" = ",all," ]; then
	alrb_needProxy="Y"
    elif [ "$alrb_toolList" = ",emi," ]; then
	alrb_needProxy="Y"
    else
	for alrb_item in ${alrb_testToolAr[@]}; do
	    if [ -e $alrb_workDir/dep/$alrb_item ]; then
		alrb_result=`\grep -e emi $alrb_workDir/dep/$alrb_item`	    
		if [ $? -eq 0 ]; then
		    alrb_needProxy="Y"
		    break
		fi
	    fi
	done
    fi

    if [ "$alrb_needProxy" != "Y" ]; then
	return 0
    fi

    export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
    source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
    lsetup emi -q

    voms-proxy-info -exists > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	alrb_doProxy="Y"
    else
	alrb_result=`voms-proxy-info --actimeleft 2>&1 | \grep -e "^[0-9]*$"`
	if [[ $? -ne 0 ]] || [[ "$alrb_result" = "" ]]; then
	    alrb_doProxy="Y"
	fi
    fi

    if [ "$alrb_doProxy" = "Y" ]; then
	\echo ""
	\echo "Getting a valid proxy since it will be needed ..."
	voms-proxy-init -valid 96:0 -voms atlas
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi

    \mkdir -p $alrb_workDir/proxySaved
    \cp $X509_USER_PROXY $alrb_workDir/proxySaved/

    voms-proxy-info -all > $alrb_workDir/proxyInfo.out 2>&1

    alrb_result=`\grep -e "nickname" $alrb_workDir/proxyInfo.out 2>&1`
    if [ $? -ne 0 ]; then
        \cat $alrb_workDir/proxyInfo.out
        \echo "Error: nickname is missing in proxy"
        return 64
    else
        local alrb_nickname=`\echo $alrb_result | \sed -e 's/.*=[\ ]*//g' | \cu\
t -f 1 -d " "`
    fi
    
    if [[ ! -z $RUCIO_ACCOUNT ]] && [[ "$RUCIO_ACCOUNT" != "$alrb_nickname" ]];\
 then
        \echo "Error: \$RUCIO_ACCOUNT ($RUCIO_ACCOUNT)  != voms nickname ($alrb\
_nickname) "
        return 64
    else
	export RUCIO_ACCOUNT=$alrb_nickname
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_sourceTestFunctions() 
#!----------------------------------------------------------------------------
{
    local alrb_tool=$1
    local alrb_result
    local alrb_rc=0
    alrb_result=`type -t alrb_fn_${alrb_tool}TestRun`
    alrb_rc=$?
    if [[ $alrb_rc -ne 0 ]] || [[ "$alrb_result" != "function" ]]; then
	alrb_fn_doToolSetup $alrb_tool
	alrb_rc=$?
    fi
    return $alrb_rc
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h,,s:,o:,v,m:,t:,n"
alrb_longopts="help,shells:,override:,verbose,mode:,tarfile:,nodep"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_toolList=""
alrb_shellListAr=()
alrb_overrideDir=""
let alrb_ThisStep=0
alrb_SummaryAr=()
alrb_workDir=""
alrb_ThisTool=""
alrb_ThisShell=""
alrb_TestDescription=""
alrb_SummaryAr=()
let alrb_ThisStep=0
alrb_resultFile=""
alrb_SummaryDir=""
alrb_Verbose=""
alrb_VerboseOpt="-q"
alrb_Mode=""
alrb_tarfile=""
alrb_skipRunDependency=""

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
	    alrb_fn_testerHelp $@
	    exit 0
            ;;
	-m|--mode)
	    alrb_Mode=$2
	    shift 2
	    ;;
	-n|--noDep)
	    alrb_skipRunDependency="YES"
	    shift
	    ;;
        -s|--shells)
            alrb_shellListAr=( `\echo ",$2," | \tr '[:upper:]' '[:lower:]' | \sed 's/,/ /g'` )
            shift 2
            ;;
        -o|--override)
            alrb_overrideDir="$2"
            shift 2
            ;;
        -v|--verbose)
            alrb_Verbose="YES"
	    alrb_VerboseOpt=""
            shift 
            ;;
	-t|--tarfile)
	    alrb_tarfile="$2"
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

if [ "$*" != "" ]; then
    alrb_toolList=`\echo ",$*," | \tr '[:upper:]' '[:lower:]'`
fi

if [ "$alrb_toolList" = "" ]; then
    \echo "You need to specify a tool (or all) to test"
    exit 64
fi

if [ "$alrb_Mode" = "" ]; then
    \echo "You need to specify a mode for testimg"
    \echo " -m user     : for users"
    \echo " -m test     : to use test versions"
    \echo " -m validate : to validate a machine" 
    exit 64
elif [[ "$alrb_Mode" != "user" ]] \
    && [[ "$alrb_Mode" != "test" ]] \
    && [[ "$alrb_Mode" != "validate" ]]; then
    \echo "Error: unknown mode option"
    \echo " needs to be user, test or validate"
    exit 64
fi

if [ "$alrb_Mode" = "user" ]; then
    alrb_shellListAr=( "$ALRB_SHELL" )
fi

alrb_fn_checkRequirements
if [ $? -ne 0 ]; then
    exit 64
fi

alrb_fn_createWorkdir
if [ $? -ne 0 ]; then
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/functions.sh

alrb_testToolAr=()
if [ "$alrb_toolList" = ",all," ]; then
    alrb_testToolAr=( `\echo $ALRB_availableTools` )
else
    alrb_fn_getDependencies
    if [ $? -ne 0 ]; then
	exit 64
    fi
fi

# destroy any existing proxy if emi is being explicitly tested
alrb_result=`\echo ${alrb_testToolAr[@]} | \grep -e "emi" 2>&1`
if [ $? -eq 0 ]; then
    \rm -f /tmp/x509up_u`id -u`
fi

(
    alrb_fn_getProxy
    if [ $? -ne 0 ]; then
	exit 64
    fi
)
if [ $? -ne 0 ]; then
    exit 64
fi

alrb_fn_doTest

if [ -e $alrb_workDir/testedTools ]; then
    let alrb_nTools=`wc -l $alrb_workDir/testedTools | \cut -f 1 -d " "`
    if [ $alrb_nTools -gt 1 ]; then
	alrb_fn_printSummaryAll
    fi
fi

alrb_fn_cleanup

exit 0

