#!----------------------------------------------------------------------------
#!
#! setMeUp.csh
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

setenv  ALRB_downloadServer "http://atlas-tier3-sw.web.cern.ch/atlas-Tier3-SW/repo/tutorial"

set alrb_progname=setMeUp.csh

alias alrb_fn_setMeUpHelp '\\echo "\\
Usage: setMeUp [options] <tutorial> \\
\\
    Checks that the user is ready to use this machine for a tutorial. \\
\\
    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first \\
\\
    <tutorial> takes the form of <site>-MMMYY\\
      eg triumf-sep14 for the tutorial at TRIUMF in Sept 2014 \\
\\
    Options (to override defaults) are: \\
     -h  --help                   Print this help message \\
     --quiet                      Print no output \\
"'

set alrb_shortopts="h"
set alrb_longopts="help,quiet"
set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh tcsh $alrb_shortopts $alrb_longopts $alrb_progname $*:q`
if ( $? != 0 ) then
    exit 64
else
    source $alrb_tmpVal    
    if ( $?alrb_tempDir) then
	\rm -rf $alrb_tempDir
	unset alrb_tempDir alrb_tmpVal
    endif
endif

set alrb_quietVal="NO"

while ( $#alrb_opts > 0 )
    switch ($alrb_opts[1])
        case -h:
        case --help:
            alrb_fn_setMeUpHelp
            unalias alrb_fn_setMeUpHelp
            exit 0
            breaksw
	case --quiet:
	    set alrb_quietVal="YES"
	    shift alrb_opts
	    breaksw
        case --:
            shift alrb_opts
            break
        default:
            \echo "Internal Error: option processing error: $1"
            unalias alrb_fn_setMeUpHelp
            exit 1
            breaksw
    endsw
end

set alrb_tutorialVersion="none"
if ( $#alrb_opts != 0 ) then
    set alrb_tutorialVersion=$alrb_opts[1]
endif

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.csh

if ( "$alrb_tutorialVersion" == "none" ) then
    \echo -e "Error: you need to specify the tutorial name.                           "'[\033[31mFAILED\033[0m]'
    exit 64
endif

setenv ALRB_SMUDIR "$ALRB_SCRATCH/smu"
mkdir -p $ALRB_SMUDIR
if ( $? != 0 ) then
    \echo -e "Error: cannot create the smu workdir.                                "'[\033[31mFAILED\033[0m]'
    exit 64
endif
cd $ALRB_SMUDIR
\rm -rf $ALRB_SMUDIR/*

touch $ALRB_SMUDIR/shared.csh
touch $ALRB_SMUDIR/shared.sh
\echo 'set alrb_tutorialVersion="'$alrb_tutorialVersion'"' >> $ALRB_SMUDIR/shared.csh
\echo 'alrb_tutorialVersion="'$alrb_tutorialVersion'"' >> $ALRB_SMUDIR/shared.sh

set alrb_domain=`hostname -d`
if ( "$alrb_domain" == "" ) then
    \echo -e "Error: domain name is missing in hostname                               "'[\033[31mFAILED\033[0m]'
    exit 64    
endif
\echo 'set alrb_domain="'$alrb_domain'"' >> $ALRB_SMUDIR/shared.csh
\echo 'alrb_domain="'$alrb_domain'"' >> $ALRB_SMUDIR/shared.sh

# fetch the tutorial cfg
set alrb_downloadURLVal="${ALRB_downloadServer}/${alrb_tutorialVersion}/config.txt"
$ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadURLVal >&  $ALRB_SMUDIR/wget_tutorial.out
if ( $? != 0 ) then
    \cat $ALRB_SMUDIR/wget_tutorial.out
    \echo "Could not fetch configuration for $alrb_tutorialVersion         "
    \echo -e " Please check if the name is correct.                                   "'[\033[31mFAILED\033[0m]'
    exit 64
endif

$ATLAS_LOCAL_ROOT_BASE/tutorial/prelim.sh
\echo " "
\echo -n "Continue ? ([yes]no) : "
set alrb_doContinue=$<
switch ($alrb_doContinue)
case [Yy][Ee][Ss]:
    \echo "Continuing with check ..."
    breaksw
case [Nn][Oo]:
    \echo "Aborting now ..."
    unalias alrb_fn_setMeUpHelp
    exit 0
    breaksw
default:
    \echo "Interpreting $alrb_doContinue to mean yes. Continuing now ..."
    breaksw
endsw
\echo " "

set alrb_testResult=""
set alrb_testToDo=`\grep -e "^TEST:" $ALRB_SMUDIR/config.txt | \cut -f 2 -d ":"`
set alrb_testToDo=",$alrb_testToDo,"

set alrb_result=`\echo $alrb_testToDo | \grep -e ",os,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check if OS is ATLAS ready ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/os.csh | tee $ALRB_SMUDIR/os.log 
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,os=False"
	\echo " "
	\echo "Please do setupATLAS -> diagnostics -> supportInfo"
	\echo " and send the generated file to user support."
	\echo -e "\
Check if OS is ATLAS ready ...                                          "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,os=True"
	\echo -e "\
Check if OS is ATLAS ready ...                                          "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif

set alrb_result=`\echo $alrb_testToDo | \grep -e ",grid,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check Grid proxy ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/grid.csh | tee $ALRB_SMUDIR/grid.og
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,grid=False"
	\echo "  Please do setupATLAS -> diagnostics -> gridCert"
	\echo "   and send the output to user support"      
	\echo -e "\
Check Grid proxy ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,grid=True"
	\echo -e "\
Check Grid proxy ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif

# this is the point at which prior errors should first be fixed ...
set alrb_result=`\echo $alrb_testResult | \grep -e "False"`
if ( $? == 0 ) then
    \echo "\
Errors were detected in the previous sections.  Although you can continue with\
setMeUp, there may be failures from now on beause of the previous errors.\
You are strongly advised to first fix the previous errors before continuing.\
"
    \echo -n "Continue ? (yes[no]) : "
    set alrb_doContinue=$<
    switch ($alrb_doContinue)
    case [Yy][Ee][Ss]:
        \echo "Continuing despite error  ..."
        breaksw
     case [Nn][Oo]:
	 \echo "Aborting now ..."
	 source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.csh
	 unalias alrb_fn_setMeUpHelp
	 exit 64
	 breaksw
     default:
         \echo "Interpreting $alrb_doContinue to mean no. Aborting now ..."
	 source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.csh
	 unalias alrb_fn_setMeUpHelp
	 exit 64
	 breaksw
     endsw
endif

set alrb_result=`\echo $alrb_testToDo | \grep -e ",env,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check environment ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/env.csh | tee $ALRB_SMUDIR/env.log
    if ( $? != 0 ) then    	
	set alrb_testResult="$alrb_testResult,env=False"
	\echo -e "\
Check environment ...                                                   "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	$ATLAS_LOCAL_ROOT_BASE/wrappers//gridMW/voms-proxy-info -exists >& $ALRB_SMUDIR/rucioaccount.log
	if ( $? != 0 ) then
	    source $ALRB_SMUDIR/shared.csh
	    \echo "RUCIO_ACCOUNT was missing and is set to $alrb_nickname"
	    setenv RUCIO_ACCOUNT $alrb_nickname
	endif
    else
	set alrb_testResult="$alrb_testResult,env=True"
	\echo -e "\
Check environment ...                                                   "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif

set alrb_result=`\echo $alrb_testToDo | \grep -e ",data,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check data files ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/inputFiles.csh | tee $ALRB_SMUDIR/inputFiles.log
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,data=False"
	\echo -e "\
Check data files ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,data=True"
	\echo -e "\
Check data files ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif


set alrb_result=`\echo $alrb_testToDo | \grep -e ",ami,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check ami access ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/ami.csh | tee $ALRB_SMUDIR/amiAccess.log
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,ami=False"
	\echo -e "\
Check ami access ...                                                    "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,ami=True"
	\echo -e "\
Check ami access ...                                                    "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif


set alrb_result=`\echo $alrb_testToDo | \grep -e ",panda,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check panda ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/panda.csh | tee $ALRB_SMUDIR/panda.log
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,panda=False"
	\echo -e "\
Check panda ...                                                         "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,panda=True"
	\echo -e "\
Check panda ...                                                         "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif


set alrb_result=`\echo $alrb_testToDo | \grep -e ",fax,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check fax ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/fax.csh | tee $ALRB_SMUDIR/fax.log
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,fax=False"
	\echo -e "\
Check FAX ...                                                           "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,fax=True"
	\echo -e "\
Check FAX ...                                                           "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif

set alrb_result=`\echo $alrb_testToDo | \grep -e ",asg,"`
if ( $? == 0 ) then
    \echo " "
    \echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    \echo "Check asg ..."
    source $ATLAS_LOCAL_ROOT_BASE/tutorial/asg.csh | tee $ALRB_SMUDIR/asg.log
    if ( $? != 0 ) then    
	set alrb_testResult="$alrb_testResult,asg=False"
	\echo -e "\
Check ASG ...                                                           "'[\033[31mFAILED\033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    else
	set alrb_testResult="$alrb_testResult,asg=True"
	\echo -e "\
Check ASG ...                                                           "'[\033[32m  OK  \033[0m]'
	\echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    endif
endif


source $ATLAS_LOCAL_ROOT_BASE/tutorial/wrapUp.csh

# cleanup
unalias alrb_fn_setMeUpHelp

unset alrb_result alrb_doContinue alrb_domain alrb_downloadURLVal alrb_longopts  alrb_progname set alrb_quietVal alrb_shortopts alrb_testResult alrb_testToDo  alrb_tutorialVersion alrb_opts


