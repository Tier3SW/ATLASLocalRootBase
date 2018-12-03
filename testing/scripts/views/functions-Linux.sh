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
alrb_fn_viewsSetup()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="setup"

    local alrb_cmdViews="lsetup \\\"views ml/1.0 x86_64-slc6-gcc62-opt\\\""
    local alrb_cmdViewsName="$alrb_relTestDir/views-setup.out"

    local alrb_runScript="$alrb_relTestDir/views-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/views-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdViews" $alrb_cmdViewsName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_viewsTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    \rm -f $alrb_relTestDir/views-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/views-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_viewsTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mviews test\e[0m"
    if [ "$ALRB_viewsVersion" != "" ]; then
	\echo "ALRB_viewsVersion"
	\echo " "
    fi
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_viewsTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "views setup"
	alrb_fn_viewsSetup
	alrb_fn_addSummary $? exit

    done

    return 0
}


