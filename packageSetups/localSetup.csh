#!----------------------------------------------------------------------------
#!
#! localSetup.csh
#!
#! A simple script to setup anything with correct dependencies and checks
#!
#! Usage:
#!     source localSetup.csh --help
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.csh

if ( ! $?ALRB_requestedVersions ) then
    setenv ALRB_requestedVersions ""
endif

set alrb_lsWorkdir="${ALRB_tmpScratch}/localSetup"
\mkdir -p $alrb_lsWorkdir
set alrb_rc=$?
if ( $alrb_rc != 0 ) then
    unset alrb_lsWorkdir
    exit $alrb_rc
endif

if ( $?alrb_lsWorkarea ) then
    if ( $?alrb_lsHistory ) then
	set alrb_lsHistory=( $alrb_lsWorkarea:q $alrb_lsWorkarea )
    else
	set alrb_lsHistory=( $alrb_lsWorkarea ) 
    endif
else
    unset alrb_lsHistory
endif

set alrb_lsWorkarea=`\mktemp -d $alrb_lsWorkdir/ls.XXXXXX`
touch ${alrb_lsWorkarea}/client.sh

foreach alrb_pass ( 1 2 ) 
    set alrb_lastPass=2
    setenv ALRB_clientShell $ALRB_SHELL
    set alrb_gridType=`${ATLAS_LOCAL_ROOT_BASE}/utilities/isGridSetup.sh`
    setenv ALRB_gridType $alrb_gridType

    if ( ! $?alrb_lsWorkarea ) then
	if ( $?alrb_lsHistory ) then
	    set alrb_tmpValN=$#alrb_lsHistory
	    if ( $alrb_tmpValN > 0 ) then
		set alrb_lsWorkarea=$alrb_lsHistory[$alrb_tmpValN]
		@ alrb_tmpValN = $alrb_tmpValN - 1
		if ( $alrb_tmpValN > 0 ) then
		    set alrb_lsHistory=( $alrb_lsHistory[-$alrb_tmpValN]:q  )
		else
		    unset alrb_lsHistory
		endif
	    else
	        unset alrb_lsHistory
		\echo "Error: alrb_lsWorkarea undefined and no history" > /dev/stderr
		exit 64
	    endif
	else
	    \echo "Error: alrb_lsWorkarea undefined and no history" > /dev/stderr
	    exit 64
	endif
    endif

    if ( -e $alrb_lsWorkarea/finishedPass ) then
	continue
    endif
    if ( $alrb_pass == $alrb_lastPass ) then
	touch ${alrb_lsWorkarea}/finishedPass
    endif
    if ( $?JAVA_HOME ) then
	if ( -e "$JAVA_HOME/bin/java" ) then
	    set alrb_whichJava="$JAVA_HOME/bin/java"
	    set alrb_rc=0
	else
	    set alrb_whichJava=""
	    set alrb_rc=64
	endif
    else
	set alrb_whichJava=`which java`
	set alrb_rc=$?
    endif
    if ( $alrb_rc != 0 ) then
	set alrb_whichJava=""
    endif
    \echo "alrb_whichJava="'"'$alrb_whichJava'"' >> ${alrb_lsWorkarea}/client.sh

    set alrb_preSetupEnv=`source $ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnv.csh`
    if ( $? != 0 ) then
	set alrb_preSetupEnv=""
    endif
    \echo "alrb_preSetupEnv="'"'"$alrb_preSetupEnv"'"' >> ${alrb_lsWorkarea}/client.sh

    \rm -f $alrb_lsWorkarea/setupScript.csh
    ${ATLAS_LOCAL_ROOT_BASE}/utilities/validator.sh $*:q -w $alrb_lsWorkarea -p Pass${alrb_pass}
    set alrb_rc=$?
    if ( $alrb_rc != 0 ) then
	\rm -rf $alrb_lsWorkarea
	unset alrb_lsWorkdir alrb_lsWorkarea 
	exit $alrb_rc
    endif
    if ( -e $alrb_lsWorkarea/preSetupScript.csh ) then
	source $alrb_lsWorkarea/preSetupScript.csh 
	if ( $? != 0 ) then
	    \rm -rf $alrb_lsWorkarea
	    unset alrb_lsWorkdir alrb_lsWorkarea
	    exit 64
	endif
	\rm -f $alrb_lsWorkarea/preSetupScript.csh
    endif
    if ( -e $alrb_lsWorkarea/setupScript.csh ) then
	source $alrb_lsWorkarea/setupScript.csh
	if ( $? != 0 ) then
	    \rm -rf $alrb_lsWorkarea
	    unset alrb_lsWorkdir alrb_lsWorkarea
	    exit 64
	endif
    endif
end

if ( -e $alrb_lsWorkarea/postSetupScript.csh ) then
    set alrb_postSetupEnv=`source $ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnv.csh`
    if ( $? != 0 ) then
	set alrb_postSetupEnv=""
    endif
    if ( $?JAVA_HOME ) then
	if ( -e "$JAVA_HOME/bin/java" ) then
	    set alrb_whichJava="$JAVA_HOME/bin/java"
	else
	    set alrb_whichJava=""
	endif
    else
	set alrb_whichJava=`which java`
	if ( $? != 0 ) then
	    set alrb_whichJava=""
	endif
    endif
    set alrb_currentJavaVersion=""
    if ( "$alrb_whichJava" != "" ) then
	set alrb_tmpVal=`$alrb_whichJava -version |& \cat`
	if ( $? == 0 ) then
	    set alrb_currentJavaVersion=`\echo $alrb_tmpVal | \grep -e "openjdk version" -e "java version" | \sed 's/.* version "\(.*\)".*/\1/g'`
	endif
    endif
    source $alrb_lsWorkarea/postSetupScript.csh 
    if ( $? != 0 ) then
	\rm -rf $alrb_lsWorkarea
	unset alrb_lsWorkdir alrb_lsWorkarea
	exit 64
    endif
endif

setenv ALRB_requestedVersions "$ALRB_requestedVersions"

\rm -rf $alrb_lsWorkarea
unset alrb_lsWorkdir alrb_lsWorkarea alrb_item alrb_tool alrb_toolVersion alrb_postSetupEnv alrb_preSetupEnv alrb_gridType alrb_whichJava alrb_pass alrb_lastPass alrb_rc alrb_tmpVal alrb_currentJavaVersion alrb_tmpValN

exit 0
