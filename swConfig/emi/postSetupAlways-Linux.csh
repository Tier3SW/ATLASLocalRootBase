#!----------------------------------------------------------------------------
#!
#!  postSetupAlways.csh
#!
#!    functions for setting up emi
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if ( $?ALRB_noGridMW ) then
    if ( "$ALRB_noGridMW" == "YES" ) then
	exit 0
    endif
endif

# check java versions again in case they were reset by athena
if ( $?EMI_TARBALL_BASE ) then
    if ( ( ! $?EMI_OVERRIDE_JAVA_HOME ) && ( -e "${EMI_TARBALL_BASE}/localJavaPath.csh" )  && ( "alrb_currentJavaVersion" != "" )) then
	set alrb_tmpVal=`\sed -e 's|.*java-\(.*\)-openjdk.*|\1|' ${EMI_TARBALL_BASE}/localJavaPath.csh`
	set alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh java $alrb_tmpVal`
	set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh java $alrb_currentJavaVersion`
	set alrb_tmpVal=`eval $alrb_whichJava -version |& \grep -i openjdk`
	if (($? != 0 ) || ( $alrb_result < $alrb_resultEmi )) then
	    source ${EMI_TARBALL_BASE}/localJavaPath.csh
        endif
    endif
endif

if ( "$alrb_Quiet" == "NO" ) then
    if ( "$alrb_postSetupEnv" != "" ) then
# check gcc version
	if ( $?EMI_MINBUILDVER_GCC ) then
	    set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_postSetupEnv gcc:ver | \sed -e 's/\.//g'`
	    set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh gcc gcc${alrb_tmpVal} `
	    set alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh gcc $EMI_MINBUILDVER_GCC`
	    if ( $alrb_result < $alrb_resultEmi ) then
		\echo " emi:" 
		\echo "   Warning: current gcc version (gcc${alrb_tmpVal}) is older than  needed for emi ($EMI_MINBUILDVER_GCC)"
            endif
	endif
# check python version
	if ( $?EMI_MINBUILDVER_PYTHON ) then
	    set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_postSetupEnv python:ver`
	    set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $alrb_tmpVal `
	    set alrb_resultEmi=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $EMI_MINBUILDVER_PYTHON`
	    if ( $alrb_result < $alrb_resultEmi ) then
		\echo " emi:" 
		\echo "   Warning: current python version ($alrb_tmpVal) is older than needed for emi ($EMI_MINBUILDVER_PYTHON)"
	    endif
	endif
    endif
    
    \echo " emi:" 
    set alrb_minTime=3600
    voms-proxy-info -exists >& /dev/null
    if ( $? != 0 ) then
	\echo '   No valid proxy present.  Type "voms-proxy-init -voms atlas"'
	set alrb_tmpVal=`which grid-cert-info`
	if ( $? == 0 ) then
	    set alrb_tmpVal=`grid-cert-info -all | \grep -e "Non Repudiation"`
	    if ( $? == 0 ) then
		\echo "   Your certificate has a nonRepudiation key."
		\echo "     Please report this to DAST for any site access issues"
		\echo "     A temporary workaround is: voms-proxy-init -voms atlas -old"
	    endif
        endif
     else 
	set alrb_result=`voms-proxy-info --actimeleft | \tail -n 1`
	if ( $? == 0 ) then
	    set alrb_result=`\echo $alrb_result | \grep -e "^[0-9]*"'$'`
	    if ( $alrb_result < $alrb_minTime ) then
		\printf '   Your proxy has %dh:%dm:%ds remaining\n' `expr $alrb_result / 3600` `expr $alrb_result % 3600 / 60`  `expr $alrb_result % 60`
		\echo '     Renew by typing "voms-proxy-init -voms atlas"'
	    else
		\printf '   Your proxy has %dh:%dm:%ds remaining\n' `expr $alrb_result / 3600` `expr $alrb_result % 3600 / 60`  `expr $alrb_result % 60`
	    endif
        else
	    \echo '   Not valid or corrupted  proxy present.  Type "voms-proxy-init -voms atlas"'	    
	endif

# temporary issue with RFC3820 + nonRepudiation
	set alrb_result=`voms-proxy-info -type | \grep RFC`
	if ( $? == 0 ) then
	    set alrb_result=`voms-proxy-info -text | \grep nonRepudiation`
	    if ( $? == 0 ) then
		\echo "   Read this on when and how to setup your proxy ..."
		\echo "     http://cern.ch/go/66jM"
		\echo "   Your RFC proxy has a nonRepudiation key."
		\echo "     Please report this to DAST for any site access issues"
		\echo "     A temporary workaround is: voms-proxy-init -voms atlas -old"
	    endif
	endif

    endif
endif

unset alrb_result alrb_minTime alrb_tmpVal alrb_resultEmi

source $ATLAS_LOCAL_ROOT_BASE/swConfig/emi/pythonFix-Linux.csh
