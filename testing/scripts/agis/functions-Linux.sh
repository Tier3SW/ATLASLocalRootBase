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
alrb_fn_agisList()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="list"

    local alrb_cmdListAgis="agis-list-panda-resources -c CA"
    local alrb_cmdListAgisName="$alrb_relTestDir/agis-list.out"

    local alrb_runScript="$alrb_relTestDir/agis-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/agis-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdListAgis" $alrb_cmdListAgisName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_agisTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    \rm -f $alrb_relTestDir/agis-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/agis-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "agis" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_agisTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1magis test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup agis -q
	\echo $ATLAS_LOCAL_AGIS_VERSION
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_agisTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ami list"
	alrb_fn_agisList
	alrb_fn_addSummary $? exit

    done

    return 0
}


