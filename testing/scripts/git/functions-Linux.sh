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
alrb_fn_gitInit()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="init"

    local alrb_cmdGitInit="git init"
    local alrb_cmdGitInitName="$alrb_relTestDir/git-init.out"

    local alrb_cmdGitStatus="git status"
    local alrb_cmdGitStatusName="$alrb_relTestDir/git-status.out"

    local alrb_runScript="$alrb_relTestDir/git-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/git-script-setup.sh

\cd $alrb_relTestDir

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGitInit" $alrb_cmdGitInitName $alrb_Verbose
alrb_retCode=\$?

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGitStatus" $alrb_cmdGitStatusName $alrb_Verbose
  alrb_retCode=\$?
fi

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_gitTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    \rm -f $alrb_relTestDir/git-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/git-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "git" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_gitTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mgit test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup git -q
	git --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_gitTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "git init"
	alrb_fn_gitInit
	alrb_fn_addSummary $? exit

    done

    return 0
}


