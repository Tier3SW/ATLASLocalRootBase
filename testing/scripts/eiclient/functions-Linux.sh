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
alrb_fn_eiclientCheckRequirements()
#!---------------------------------------------------------------------------- 
{

    local alrb_domain=`hostname -d`
    if [ "$alrb_domain" != "cern.ch" ]; then
	\echo "EI Client can only run on cern.ch domains at the moment."
	\echo " Skipping this test for non-cern domain"
	alrb_setStatus="SKIP"
	return 64
    fi

    return 0
}

#!---------------------------------------------------------------------------- 
alrb_fn_eiclientCatalog()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="catalog"

    local alrb_cmdEiclient="catalog -query \"id:EI15.1.data15_13TeV.physics_Main.merge.AOD.f594_m1435.00266904\""
    local alrb_cmdEiclientName="$alrb_relTestDir/eiclient-catalog.out"

    local alrb_runScript="$alrb_relTestDir/eiclient-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/eiclient-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEiclient" $alrb_cmdEiclientName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_eiclientEiCmd()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="ei"

    local alrb_cmdEiclient="el -e \"00267069 00000008169\""
    local alrb_cmdEiclientName="$alrb_relTestDir/eiclient-ei.out"

    local alrb_runScript="$alrb_relTestDir/eiclient-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/eiclient-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEiclient" $alrb_cmdEiclientName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_eiclientTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    \rm -f $alrb_relTestDir/eiclient-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/eiclient-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "eiclient" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_eiclientTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1meiclient test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup eiclient -q
	\echo $ATLAS_LOCAL_EICLIENT_VERSION
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_eiclientTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ei check requirements"
	alrb_fn_eiclientCheckRequirements
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ei command"
	alrb_fn_eiclientEiCmd
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "ei catalog"
	alrb_fn_eiclientCatalog
	alrb_fn_addSummary $? continue

    done

    return 0
}


