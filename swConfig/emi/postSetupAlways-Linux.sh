#!----------------------------------------------------------------------------
#!
#!  postSetupAlways.sh
#!
#!    functions for setting up emi
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if [[ ! -z $ALRB_noGridMW ]] && [[ "$ALRB_noGridMW" = "YES" ]]; then
    return 0
fi

# check java versions again in case they were reset by athena
if [ ! -z $EMI_TARBALL_BASE ]; then
    if [[ -z $EMI_OVERRIDE_JAVA_HOME ]] && [[ -e "${EMI_TARBALL_BASE}/localJavaPath.sh" ]] && [[ "alrb_currentJavaVersion" != "" ]]; then
	alrb_tmpVal=`\sed -e 's|.*java-\(.*\)-openjdk.*|\1|' ${EMI_TARBALL_BASE}/localJavaPath.sh`
	alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh java $alrb_tmpVal`
	alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh java $alrb_currentJavaVersion`
	alrb_tmpVal=`eval $alrb_whichJava -version 2>&1 | \grep -i openjdk`
	if [[ $? -ne 0 ]] || [[ $alrb_result -lt $alrb_resultEmi ]]; then
	    source ${EMI_TARBALL_BASE}/localJavaPath.sh
	fi
    fi
fi

if [ "$alrb_Quiet" = "NO" ]; then
    if [ "$alrb_postSetupEnv" != "" ]; then
# check gcc version
	if [ ! -z $EMI_MINBUILDVER_GCC ]; then
	    alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_postSetupEnv gcc:ver | \sed -e 's/\.//g'`
	    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh gcc gcc${alrb_tmpVal} `
	    alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh gcc $EMI_MINBUILDVER_GCC`
	    if [ $alrb_result -lt $alrb_resultEmi ]; then
		\echo " emi:" 
		\echo "   Warning: current gcc version (gcc${alrb_tmpVal}) is older than  needed for emi ($EMI_MINBUILDVER_GCC)"
	    fi
	fi
# check python version
	if [ ! -z $EMI_MINBUILDVER_PYTHON ]; then
	    alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_postSetupEnv python:ver`
	    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $alrb_tmpVal `
	    alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $EMI_MINBUILDVER_PYTHON`
	    if [ $alrb_result -lt $alrb_resultEmi ]; then
		\echo " emi:" 
		\echo "   Warning: current python version ($alrb_tmpVal) is older than needed for emi ($EMI_MINBUILDVER_PYTHON)"
	    fi
	fi
    fi
    
    \echo " emi:" 
    let alrb_minTime=3600
    voms-proxy-info -exists > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	\echo "   No valid proxy present.  Type \"voms-proxy-init -voms atlas\""
	alrb_tmpVal=`which grid-cert-info 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_tmpVal=`grid-cert-info -all 2>&1 | \grep -e "Non Repudiation"`
	    if [ $? -eq 0 ]; then
		\echo "   Your certificate has a nonRepudiation key."
		\echo "     Please report this to DAST for any site access issues"
		\echo "     A temporary workaround is: voms-proxy-init -voms atlas -old"		
	    fi
	fi
    else
	alrb_result=`voms-proxy-info --actimeleft 2>&1 | \tail -n 1 | \grep -e "^[0-9]*$"`
	if [[ $? -eq 0 ]] && [[ "$alrb_result" != "" ]]; then
	    if [ $alrb_result -lt $alrb_minTime ]; then
		\printf '   Your proxy has %dh:%dm:%ds remaining\n' `expr $alrb_result / 3600` `expr $alrb_result % 3600 / 60`  `expr $alrb_result % 60`
		\echo "     Renew by typing \"voms-proxy-init -voms atlas\""
	    else
		\printf '   Your proxy has %dh:%dm:%ds remaining\n' `expr $alrb_result / 3600` `expr $alrb_result % 3600 / 60`  `expr $alrb_result % 60`
	    fi
	else
	    \echo "   Not valid or corrupted proxy present.  Type \"voms-proxy-init -voms atlas\""	    
	fi

# temporary issue with RFC3820 + nonRepudiation
	alrb_result=`voms-proxy-info -type | \grep RFC 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_result=`voms-proxy-info -text | \grep nonRepudiation 2>&1`
	    if [ $? -eq 0 ]; then
		\echo "   Read this on when and how to setup your proxy ..."
		\echo "     http://cern.ch/go/66jM"
		\echo "   Your RFC proxy has a nonRepudiation key."
		\echo "     Please report this to DAST with any site access issues"
		\echo "     A temporary workaround is: voms-proxy-init -voms atlas -old"
	    fi
	fi

    fi
fi

unset alrb_result alrb_minTime alrb_tmpVal alrb_resultEmi

source $ATLAS_LOCAL_ROOT_BASE/swConfig/emi/pythonFix-Linux.sh 
