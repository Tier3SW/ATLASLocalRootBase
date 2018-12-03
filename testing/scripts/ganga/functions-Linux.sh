#!----------------------------------------------------------------------------
#!
#! functions-Linux.sh
#!
#! functions for testing the tools
#!
#! Usage:
#!     not directly
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

#!---------------------------------------------------------------------------- 
alrb_fn_gangaCheckRequirement()
#!---------------------------------------------------------------------------- 
{
    alrb_BatchQueue=""
    which bsub > /dev/null 2>&1
    if [ $? -eq 0 ]; then
	alrb_BatchQueue="--lsf"
    fi
    if [ "$alrb_BatchQueue" = "" ]; then
	which condor > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    alrb_BatchQueue="--condor"
	fi
    fi
    if [ "$alrb_BatchQueue" = "" ]; then
	\echo "This machine does not have lsf or condor.  Skipping test"
	alrb_setStatus="SKIP"
	return 64
    fi

    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_gangaTestRunJob()
#!---------------------------------------------------------------------------- 
{
    
    local alrb_retCode=0
    local alrb_runName="runGanga"

    local alrb_cmdGangaAcmSetup="acmSetup"
    local alrb_cmdGangaAcmSetupName="$alrb_relTestDir/ganga-setupAcm.out"

    local alrb_cmdGangaRun="ganga athena $alrb_BatchQueue --inPfnListFile './myFirstSample' --split=10 --outputlocation=\"$ALRB_tmpScratch/gangaTestJobs\" MyPackage/MyPackageAlgJobOptions.py"
    local alrb_cmdGangaRunName="$alrb_relTestDir/ganga-doRun.out"
    
    local alrb_runScript="$alrb_relTestDir/ganga-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/ganga-script-setup.sh
alrb_exitCode=0
\cd $alrb_acmReleaseDir/build

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGangaAcmSetup" $alrb_cmdGangaAcmSetupName $alrb_Verbose
if [ \$? -ne 0 ]; then
  exit 64
fi
\cd \$TestArea/run                                                            

\rm -f ./myFirstSample
\echo $ASG_TEST_FILE_MC > ./myFirstSample

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGangaRun" $alrb_cmdGangaRunName $alrb_Verbose
alrb_exitCode=\$?

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_gangaTestSetupEnv()
#!---------------------------------------------------------------------------- 
{
    
    alrb_fn_sourceTestFunctions acm
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_fn_acmTestSetupEnv
    if [ $? -ne 0 ]; then
	return 64
    fi
        
    \rm -f $alrb_relTestDir/ganga-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/ganga-script-setup.sh
source $alrb_relTestDir/acm-script-setup.sh
if [ \$? -ne 0 ]; then
  exit 64
fi
lsetup "ganga" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_gangaTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mganga test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup ganga -q > /dev/null 2>&1
	ganga --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_gangaTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ganga check requirement"
	alrb_fn_gangaCheckRequirement
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "acm build release"
	alrb_fn_acmTestBuildRelease
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ganga batch submit"
	alrb_fn_gangaTestRunJob
	alrb_fn_addSummary $? exit

    done

    return 0
}


