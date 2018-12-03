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
alrb_fn_acmTestRunJob()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="run"

    local alrb_cmdAcmRun="athena --filesInput=\$ASG_TEST_FILE_MC --evtMax=10 MyPackage/MyPackageAlgJobOptions.py"
    local alrb_cmdAcmRunName="$alrb_relTestDir/acm-doRun.out"

    local alrb_cmdAcmSetup="acmSetup"
    local alrb_cmdAcmSetupName="$alrb_relTestDir/acm-setupRun.out"

    local alrb_runScript="$alrb_relTestDir/acm-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/acm-script-setup.sh
alrb_exitCode=0
\cd $alrb_acmReleaseDir/build

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAcmSetup" $alrb_cmdAcmSetupName $alrb_Verbose
if [ \$? -ne 0 ]; then
  exit 64
fi
\cd \$TestArea/run                                                            

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAcmRun" $alrb_cmdAcmRunName $alrb_Verbose
alrb_exitCode=\$?

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_acmTestBuildRelease()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="buildRelease"

    local alrb_cmdAcmSetup="acmSetup $alrb_acmAthenaRel"
    local alrb_cmdAcmSetupName="$alrb_relTestDir/acm-setup.out"

    local alrb_cmdAcmNewSkel="acm new_skeleton MyPackage "
    local alrb_cmdAcmNewSkelName="$alrb_relTestDir/acm-newSkel.out"

    local alrb_cmdAcmCompile="acm compile "
    local alrb_cmdAcmCompileName="$alrb_relTestDir/acm-compile.out"

    local alrb_runScript="$alrb_relTestDir/acm-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/acm-script-setup.sh
alrb_exitCode=0
cd $alrb_acmReleaseDir 

if [ ! -e $alrb_acmReleaseDir/.alrb_compiled_done ]; then
  \mkdir -p source build
  cd build

  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAcmSetup" $alrb_cmdAcmSetupName $alrb_Verbose
  if [ \$? -ne 0 ]; then
    exit 64
  fi

  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAcmNewSkel" $alrb_cmdAcmNewSkelName $alrb_Verbose
  if [ \$? -ne 0 ]; then
    exit 64
  fi

   source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAcmCompile" $alrb_cmdAcmCompileName $alrb_Verbose 
  if [ \$? -ne 0 ]; then
    exit 64
  fi

  \mkdir -p \$TestArea/run

  touch $alrb_acmReleaseDir/.alrb_compiled_done

else
  \echo "Build already exists, skipping it."
fi

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_acmTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    alrb_acmReleaseDir="$alrb_workDir/acm/$alrb_thisShell/release"
    mkdir -p $alrb_acmReleaseDir

    \rm -f $alrb_relTestDir/acm-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/acm-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
alrb_acmReleaseDir=$alrb_acmReleaseDir
EOF

    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_acmTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1macm test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	\echo $ATLAS_LOCAL_ACM_VERSION
    )

    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_acmTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "acm build release"
	alrb_fn_acmTestBuildRelease
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "acm run job"
	alrb_fn_acmTestRunJob
	alrb_fn_addSummary $? exit

    done

    return 0
}


