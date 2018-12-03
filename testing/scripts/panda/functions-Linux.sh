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
alrb_fn_pandaTestPathena()
#!---------------------------------------------------------------------------- 
{
    
    local alrb_retCode=0
    local alrb_runName="pathena"

    local alrb_cmdPandaAcmSetup="acmSetup"
    local alrb_cmdPandaAcmSetupName="$alrb_relTestDir/panda-setupAcm.out"

    local alrb_cmdPandaRun="pathena MyPackage/MyPackageAlgJobOptions.py --nEventsPerFile=50 --nFiles=1 --inDS=\\\"$ALRB_testPandaDataset\\\" --outDS=user.$RUCIO_ACCOUNT.test.`uuidgen`"
    local alrb_cmdPandaRunName="$alrb_relTestDir/panda-pathena.out"
    
    local alrb_runScript="$alrb_relTestDir/panda-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/panda-script-setup.sh
alrb_exitCode=0
\cd $alrb_acmReleaseDir/build

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdPandaAcmSetup" $alrb_cmdPandaAcmSetupName $alrb_Verbose
if [ \$? -ne 0 ]; then
  exit 64
fi
\cd \$TestArea/run                                                            

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdPandaRun" $alrb_cmdPandaRunName $alrb_Verbose
alrb_exitCode=\$?

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_pandaTestPrun()
#!---------------------------------------------------------------------------- 
{
    
    local alrb_retCode=0
    local alrb_runName="prun"

    \mkdir -p $alrb_relTestDir/prun
    local alrb_prunTestScript="$alrb_relTestDir/prun/myPunJob.sh"
    \cat  <<  EOF >> $alrb_prunTestScript
#! /bin/bash

\echo 'testJob.sh running...'
\echo "----------------------"
\echo "date is " \`date\`
\echo "hostname is " \`hostname -f\`
\echo "id is " \`id\`
\echo "uname is : "\`uname -a\` 
\echo "pwd is : " \`pwd\`
\echo "----------------------"
\echo "Voms proxy is : "
voms-proxy-info -all
\echo "----------------------"
\echo "Env is : "
env | sort
\echo "----------------------"
exit 0

EOF

    local alrb_cmdPandaRun="prun --exec=myPunJob.sh --outDS=user.$RUCIO_ACCOUNT.test.`uuidgen` --noBuild"
    local alrb_cmdPandaRunName="$alrb_relTestDir/panda-prun.out"
    
    local alrb_runScript="$alrb_relTestDir/panda-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/panda-script-setup.sh
alrb_exitCode=0
\cd $alrb_relTestDir/prun

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdPandaRun" $alrb_cmdPandaRunName $alrb_Verbose
alrb_exitCode=\$?

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_pandaTestSetupEnv()
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
        
    \rm -f $alrb_relTestDir/panda-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/panda-script-setup.sh
source $alrb_relTestDir/acm-script-setup.sh
if [ \$? -ne 0 ]; then
  exit 64
fi
lsetup "panda" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_pandaTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mpanda test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup panda -q
	prun --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_pandaTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "panda prun"
	alrb_fn_pandaTestPrun
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "acm build release"
	alrb_fn_acmTestBuildRelease
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "panda pathena"
	alrb_fn_pandaTestPathena
	alrb_fn_addSummary $? continue

    done

    return 0
}


