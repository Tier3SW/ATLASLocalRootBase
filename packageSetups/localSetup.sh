#!----------------------------------------------------------------------------
#!
#! localSetup.sh
#!
#! A simple script to setup anything with correct dependencies and checks
#!
#! Usage:
#!     source localSetup.sh --help
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

if [ -z "$ALRB_requestedVersions" ]; then
    export ALRB_requestedVersions=""
fi

alrb_lsWorkdir="${ALRB_tmpScratch}/localSetup"
\mkdir -p $alrb_lsWorkdir
alrb_rc=$?
if [ $alrb_rc -ne 0 ]; then
    unset alrb_lsWorkdir
    return $alrb_rc
fi

if [ ! -z $alrb_lsWorkarea ];  then
    alrb_lsHistory=( ${alrb_lsHistory[@]} $alrb_lsWorkarea )
else
    unset alrb_lsHistory
fi

alrb_lsWorkarea=`\mktemp -d $alrb_lsWorkdir/ls.XXXXXX`
touch ${alrb_lsWorkarea}/client.sh

for alrb_pass in `seq 1 2`; do
    let alrb_lastPass=2
    export ALRB_clientShell=$ALRB_SHELL
    alrb_gridType=`${ATLAS_LOCAL_ROOT_BASE}/utilities/isGridSetup.sh`
    export ALRB_gridType=$alrb_gridType
    if [ -z $alrb_lsWorkarea ]; then
	if [ ! -z $alrb_lsHistory ]; then
	    let alrb_tmpValN=${#alrb_lsHistory[@]}
	    if [ $alrb_tmpValN -gt 0 ]; then
		if [ "$ALRB_SHELL" = "zsh" ]; then
		    alrb_lsWorkarea=$alrb_lsHistory[-1]
		    alrb_lsHistory[-1]=()
		else
		    let alrb_tmpValN=$alrb_tmpValN-1
		    alrb_lsWorkarea=${alrb_lsHistory[$alrb_tmpValN]}
		    unset alrb_lsHistory[$alrb_tmpValN]
		fi
		if [ ${#alrb_lsHistory[@]} -le 0 ]; then
		    unset alrb_lsHistory
		fi
	    else
		\echo "Error: alrb_lsWorkarea undefined and no history" 1>&2
		return 64
	    fi
	    
	else
	    \echo "Error: alrb_lsWorkarea undefined and no history" 1>&2
	    return 64
	fi
    fi

    if [ -e $alrb_lsWorkarea/finishedPass ]; then
	continue
    fi
    if [ $alrb_pass -eq $alrb_lastPass ]; then
	touch ${alrb_lsWorkarea}/finishedPass
    fi
    if [ ! -z "$JAVA_HOME" ]; then
	if [ -e "$JAVA_HOME/bin/java" ]; then
	    alrb_whichJava="$JAVA_HOME/bin/java"
	    let alrb_rc=0
	else
	    alrb_whichJava=""
	    let alrb_rc=64
	fi
    else
	alrb_whichJava=`which java 2>&1`
	alrb_rc=$?
    fi
    if [ $alrb_rc -ne 0 ]; then
	alrb_whichJava=""
    fi
    \echo "alrb_whichJava=\"$alrb_whichJava\"" >> ${alrb_lsWorkarea}/client.sh

    alrb_preSetupEnv=`source $ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnv.sh`
    if [ $? -ne 0 ]; then
	alrb_preSetupEnv=""
    fi
    \echo "alrb_preSetupEnv=\"$alrb_preSetupEnv\"" >> ${alrb_lsWorkarea}/client.sh

    \rm -f $alrb_lsWorkarea/setupScript.sh
    ${ATLAS_LOCAL_ROOT_BASE}/utilities/validator.sh "$@" -w $alrb_lsWorkarea -p Pass${alrb_pass}
    alrb_rc=$?
    if [ $alrb_rc -ne 0 ]; then
	\rm -rf $alrb_lsWorkarea
	unset alrb_lsWorkdir alrb_lsWorkarea 
	return $alrb_rc
    fi
    if [ -e $alrb_lsWorkarea/preSetupScript.sh ]; then
	source $alrb_lsWorkarea/preSetupScript.sh
	if [ $? -ne 0 ]; then
	    \rm -rf $alrb_lsWorkarea
	    unset alrb_lsWorkdir alrb_lsWorkarea
	    return 64
	fi
	\rm -f $alrb_lsWorkarea/preSetupScript.sh
    fi
    if [ -e $alrb_lsWorkarea/setupScript.sh ]; then
	source $alrb_lsWorkarea/setupScript.sh
	if [ $? -ne 0 ]; then
	    \rm -rf $alrb_lsWorkarea
	    unset alrb_lsWorkdir alrb_lsWorkarea
	    return 64
	fi
    fi
done

if [ -e $alrb_lsWorkarea/postSetupScript.sh ]; then
    alrb_postSetupEnv=`source $ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnv.sh`
    if [ $? -ne 0 ]; then
	alrb_postSetupEnv=""
    fi
    if [ ! -z "$JAVA_HOME" ]; then
	if [ -e "$JAVA_HOME/bin/java" ]; then
	    alrb_whichJava="$JAVA_HOME/bin/java"
	else
	    alrb_whichJava=""
	fi
    else
	alrb_whichJava=`which java 2>&1`
	if [ $? -ne 0 ]; then
	    alrb_whichJava=""
	fi
    fi
    alrb_currentJavaVersion=""
    if [ "$alrb_whichJava" != "" ]; then
	alrb_tmpVal=`$alrb_whichJava -version 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_currentJavaVersion=`\echo $alrb_tmpVal | \grep -e "openjdk version" -e "java version" | \sed 's/.* version "\(.*\)".*/\1/g'`
	fi
    fi
    source $alrb_lsWorkarea/postSetupScript.sh
    if [ $? -ne 0 ]; then
	\rm -rf $alrb_lsWorkarea
	unset alrb_lsWorkdir alrb_lsWorkarea
	return 64
    fi
fi

export ALRB_requestedVersions

\rm -rf $alrb_lsWorkarea
unset alrb_lsWorkdir alrb_lsWorkarea alrb_item alrb_tool alrb_toolVersion alrb_postSetupEnv alrb_preSetupEnv alrb_gridType alrb_whichJava alrb_pass alrb_lastPass alrb_rc alrb_tmpVal alrb_currentJavaVersion alrb_tmpValN

return 0
