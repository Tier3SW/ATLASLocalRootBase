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
alrb_fn_emiGfalLs()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="gfal-ls"

    local alrb_remoteFile=`\grep -e "^srm://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdEmi="gfal-ls -l \\\"$alrb_remoteFile\\\""
    local alrb_cmdEmiName="$alrb_relTestDir/emi-gfalls.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiGfalCat()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="gfal-cat"

    local alrb_remoteFile=`\grep -e "^srm://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdEmi="gfal-cat \\\"$alrb_remoteFile\\\""
    local alrb_cmdEmiName="$alrb_relTestDir/emi-gfalcat.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiGfalCopy()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="gfal-copy"

    local alrb_remoteFile=`\grep -e "^srm://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdEmi="gfal-copy \\\"$alrb_remoteFile\\\" \\\"file://$alrb_relTestDir/gfalCopiedFile\\\""
    local alrb_cmdEmiName="$alrb_relTestDir/emi-gfalcopy.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiInit()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="init"

# just copy the proxy as it was already created
    local alrb_cmdEmi="\cp $alrb_workDir/proxySaved/* /tmp/"
    local alrb_cmdEmiName="$alrb_relTestDir/emi-init.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiInfo()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="info"

    local alrb_cmdEmi="voms-proxy-info -all"
    local alrb_cmdEmiName="$alrb_relTestDir/emi-info.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiDestroy()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="destroy"

    local alrb_cmdEmi="voms-proxy-destroy"
    local alrb_cmdEmiName="$alrb_relTestDir/emi-destroy.out"

    local alrb_cmdEmiExist="! voms-proxy-info -e"
    local alrb_cmdEmiExistName="$alrb_relTestDir/emi-exist.out"

    local alrb_runScript="$alrb_relTestDir/emi-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/emi-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmi" $alrb_cmdEmiName $alrb_Verbose
alrb_retCode=\$?

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEmiExist" $alrb_cmdEmiExistName $alrb_Verbose
  alrb_retCode=\$?
fi

\cp $alrb_workDir/proxySaved/* /tmp/

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    alrb_fn_sourceTestFunctions rucio
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_fn_rucioTestSetupEnv
    if [ $? -ne 0 ]; then
	return 64
    fi

    alrb_emiUuidGen=`uuidgen`
    \mkdir -p $alrb_rucioUploadDir
    alrb_emiMyFile="myFile.${alrb_emiUuidGen}.txt"
    alrb_emiMyDir="$RUCIO_ACCOUNT-test-$alrb_emiUuidGen"
    \echo "Text file for testing emi" >> $alrb_rucioUploadDir/$alrb_emiMyFile

    \rm -f $alrb_relTestDir/emi-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/emi-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup emi -f $alrb_VerboseOpt
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_emiTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1memi test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup -f emi -q
	\echo $ATLAS_LOCAL_EMI_VERSION
    )

    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_emiTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi voms-proxy-init"
	alrb_fn_emiInit
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi voms-proxy-info"
	alrb_fn_emiInfo
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi voms-proxy-destroy"
	alrb_fn_emiDestroy
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio upload dataset"
	alrb_fn_rucioUploadDS
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get pfns"
	alrb_fn_rucioGetPfns
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi gfal-ls"
	alrb_fn_emiGfalLs
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi gfal-cat"
	alrb_fn_emiGfalCat
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "emi gfal-copy"
	alrb_fn_emiGfalCopy
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio erase dataset"
	alrb_fn_rucioEraseDS
	alrb_fn_addSummary $? continue

    done

    return 0
}


