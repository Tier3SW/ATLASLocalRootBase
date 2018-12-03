#!----------------------------------------------------------------------------
#!
#! setMeUp.sh
#!
#! check that you are ready to run a tutorial at a site
#!
#! Usage:
#!     setMeUp --help 
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ALRB_downloadServer="http://atlas-tier3-sw.web.cern.ch/atlas-Tier3-SW/repo/tutorial"

alrb_progname=setMeUp.sh

alrb_fn_setMeUpHelp()
{
    \cat <<EOF

Usage: setMeUp [options] <tutorial>

    Checks that the user is ready to use this machine for a tutorial.

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE.

    <tutorial> takes the form of <site>-MMMYY 
      eg triumf-sep14 for the tutorial at TRIUMF in Sept 2014

    Options (to override defaults) are:
     -h  --help                   Print this help message
     --quiet                      Print no output

EOF
}

alrb_shortopts="h"
alrb_longopts="help,quiet"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    return 64
fi
eval set -- "$alrb_opts"

alrb_quietVal="NO"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_setMeUpHelp
            return 0
            ;;
	--quiet)
	    alrb_quietVal="YES"
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

alrb_tutorialVersion="none"
if [ "$*" != "" ]; then
    alrb_tutorialVersion=`\echo $* | \cut -f 1 -d " "`
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

if [ "$alrb_tutorialVersion" = "none" ]; then
    \echo -e "Error: you need to specify the tutorial name.                           "'[\033[31mFAILED\033[0m]'
    return 64
fi

if [ "$ALRB_SHELL" = "bash" ]; then
    alrb_pipeStat='return ${PIPESTATUS[0]}'
elif [ "$ALRB_SHELL" = "zsh" ]; then
    alrb_pipeStat='return ${pipestatus[1]}'
fi

export ALRB_SMUDIR="$ALRB_SCRATCH/smu"
mkdir -p $ALRB_SMUDIR
if [ $? -ne 0 ]; then
    \echo -e "Error: cannot create the smu workdir.                                   "'[\033[31mFAILED\033[0m]'
    return 64    
fi
cd $ALRB_SMUDIR
\rm -rf $ALRB_SMUDIR/*

touch $ALRB_SMUDIR/shared.sh
\echo "alrb_tutorialVersion=\"$alrb_tutorialVersion\"" >> $ALRB_SMUDIR/shared.sh

alrb_domain=`hostname -d`
if [ "$alrb_domain" = "" ]; then
    \echo -e "Error: domain name is missing in hostname                               "'[\033[31mFAILED\033[0m]'
    return 64    
fi
\echo "alrb_domain=\"$alrb_domain\"" >> $ALRB_SMUDIR/shared.sh

# fetch the tutorial cfg
alrb_downloadURLVal="${ALRB_downloadServer}/${alrb_tutorialVersion}/config.txt"
$ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadURLVal > $ALRB_SMUDIR/wget_tutorial.out 2>&1
if [ $? -ne 0 ]; then    
    \cat $ALRB_SMUDIR/wget_tutorial.out
    \echo "Could not fetch configuration for $alrb_tutorialVersion         "
    \echo -e " Please check if the name is correct.                                   "'[\033[31mFAILED\033[0m]'
    return 64
fi

$ATLAS_LOCAL_ROOT_BASE/tutorial/prelim.sh
\echo " "
\echo -n "Continue ? ([yes]no) : " 
read alrb_doContinue
case $alrb_doContinue in
    [yY][eE][sS] ) \echo "Continuing with check ...";;
    [nN][oO] ) \echo "Aborting now ..."; return;;
* ) \echo "Interpreting $alrb_doContinue to mean  yes. Continuing now ...";;
esac
\echo " "

alrb_testResult=""
alrb_testToDo=`\grep -e "^TEST:" $ALRB_SMUDIR/config.txt | \cut -f 2 -d ":"`
alrb_testToDo=",$alrb_testToDo,"

alrb_result=`\echo $alrb_testToDo | \grep -e ",os," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check if OS is ATLAS ready ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/os.sh | tee $ALRB_SMUDIR/os.log; eval $alrb_pipeStat
    )    
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,os=False"
	\echo " "
	\echo "Please do setupATLAS -> diagnostics -> supportInfo"
	\echo " and send the generated file to user support."
	\echo -e "
Check if OS is ATLAS ready ...                                          "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	alrb_testResult="$alrb_testResult,os=True"
	\echo -e "
Check if OS is ATLAS ready ...                                          "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

alrb_result=`\echo $alrb_testToDo | \grep -e ",grid," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check Grid proxy ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/grid.sh | tee $ALRB_SMUDIR/grid.log; eval $alrb_pipeStat
    )
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,grid=False"
	\echo " "
	\echo "  Please do setupATLAS -> diagnostics -> gridCert"
	\echo "   and send the output to user support"
	\echo -e "
Check Grid proxy ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	alrb_testResult="$alrb_testResult,grid=True"
	\echo -e "
Check Grid proxy ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

# this is the point at which prior errors should first be fixed ...  
alrb_result=`\echo $alrb_testResult | \grep -e "False" 2>&1`
if [ $? -eq 0 ]; then
    \echo " 
Errors were detected in the previous sections.  Although you can continue with
setMeUp, there may be failures from now on beause of the previous errors. 
You are strongly advised to first fix the previous errors before continuing. 
"
    \echo -n "Continue ? (yes[no]) : " 
    read alrb_doContinue
    case $alrb_doContinue in
	[yY][eE][sS] ) \echo "Continuing despite error ...";;
        [nN][oO] ) \echo "Aborting now ..."; source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.sh; return 64;;
	* ) \echo "Interpreting $alrb_doContinue to mean no. Aborting now ..."; source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.sh; return 64;;
    esac
fi

alrb_result=`\echo $alrb_testToDo | \grep -e ",env," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check environment ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/env.sh | tee $ALRB_SMUDIR/env.log; eval $alrb_pipeStat
    )
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,env=False"
	\echo -e "
Check environment ...                                                   "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	$ATLAS_LOCAL_ROOT_BASE/wrappers/gridMW/voms-proxy-info -exists > $ALRB_SMUDIR/rucioaccount.log 2>&1
	if [ $? -ne 0 ]; then
	    source $ALRB_SMUDIR/shared.sh
	    \echo "RUCIO_ACCOUNT was missing and is set to $alrb_nickname"
	    export RUCIO_ACCOUNT=$alrb_nickname
	fi
    else
	alrb_testResult="$alrb_testResult,env=True"
	\echo -e "
Check environment ...                                                   "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

alrb_result=`\echo $alrb_testToDo | \grep -e ",data," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check data files ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/inputFiles.sh | tee $ALRB_SMUDIR/inputFiles.log; eval $alrb_pipeStat
    )
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,data=False"
	\echo -e "
Check data files ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	alrb_testResult="$alrb_testResult,data=True"
	\echo -e "
Check data files ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

alrb_result=`\echo $alrb_testToDo | \grep -e ",ami," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check ami access ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/ami.sh | tee $ALRB_SMUDIR/amiAccess.log; eval $alrb_pipeStat
    )
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,ami=False"
	\echo -e "
Check ami access ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	alrb_testResult="$alrb_testResult,ami=True"
	\echo -e "
Check ami access ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

alrb_result=`\echo $alrb_testToDo | \grep -e ",panda," 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check panda submission ..."
    (
	source $ATLAS_LOCAL_ROOT_BASE/tutorial/panda.sh | tee $ALRB_SMUDIR/panda.log; eval $alrb_pipeStat
    )
    if [ $? -ne 0 ]; then    
	alrb_testResult="$alrb_testResult,panda=False"
	\echo -e "
Check panda submission ...                                              "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	alrb_testResult="$alrb_testResult,panda=True"
	\echo -e "
Check panda submission ...                                              "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi
fi

source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.sh

unset alrb_result alrb_doContinue alrb_domain alrb_downloadURLVal alrb_longopts alrb_progname set alrb_quietVal alrb_shortopts alrb_testResult alrb_testToDo alrb_tutorialVersion alrb_pipeStat alrb_opts


