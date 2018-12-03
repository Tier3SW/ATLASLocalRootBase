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
alrb_fn_davixLsTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="ls"

    local alrb_cmdDavix="davix-ls -P grid ${alrb_davixUrl}$alrb_davixMyDir"
    local alrb_cmdDavixName="$alrb_relTestDir/davix-ls.out"

    local alrb_runScript="$alrb_relTestDir/davix-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/davix-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavix" $alrb_cmdDavixName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixMkdirTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="mkdir"

    local alrb_cmdDavix="davix-mkdir -P grid ${alrb_davixUrl}${alrb_davixMyDir}"
    local alrb_cmdDavixName="$alrb_relTestDir/davix-mkdir.out"

    local alrb_runScript="$alrb_relTestDir/davix-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/davix-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavix" $alrb_cmdDavixName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixPutTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="put"

    local alrb_cmdDavix="davix-put -P grid $alrb_rucioUploadDir/$alrb_davixMyFile ${alrb_davixUrl}${alrb_davixMyDir}/$alrb_davixMyFile"
    local alrb_cmdDavixName="$alrb_relTestDir/davix-put.out"

    local alrb_runScript="$alrb_relTestDir/davix-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/davix-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavix" $alrb_cmdDavixName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixGetTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="get"

    local alrb_cmdDavix="davix-get -P grid ${alrb_davixUrl}${alrb_davixMyDir}/$alrb_davixMyFile $alrb_relTestDir/davix-downloadedFile"
    local alrb_cmdDavixName="$alrb_relTestDir/davix-get.out"

    local alrb_cmdDavixCat="\cat $alrb_relTestDir/davix-downloadedFile"
    local alrb_cmdDavixCatName="$alrb_relTestDir/davix-cat.out"

    local alrb_runScript="$alrb_relTestDir/davix-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/davix-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavix" $alrb_cmdDavixName $alrb_Verbose
alrb_retCode=\$?

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavixCat" $alrb_cmdDavixCatName $alrb_Verbose
fi

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}




#!---------------------------------------------------------------------------- 
alrb_fn_davixRmTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="rm"

    local alrb_cmdDavix="davix-rm -P grid ${alrb_davixUrl}${alrb_davixMyDir}"
    local alrb_cmdDavixName="$alrb_relTestDir/davix-rm.out"

    local alrb_runScript="$alrb_relTestDir/davix-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/davix-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdDavix" $alrb_cmdDavixName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixGetUrl()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    
    local alrb_rootRemoteFile=`\grep -e "^davs://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_davixUrl=`\echo $alrb_rootRemoteFile | \sed -e 's|/rucio.*|/|'`
    \rm -f $alrb_relTestDir/davixUrl.sh
    \echo "alrb_davixUrl=\"$alrb_davixUrl\"" >> $alrb_relTestDir/davixUrl.sh
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixTestSetupEnv()
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

    alrb_davixUuidGen=`uuidgen`
    \mkdir -p $alrb_rucioUploadDir
    alrb_davixMyFile="myFile.${alrb_davixUuidGen}.txt"
    alrb_davixMyDir="$RUCIO_ACCOUNT-test-$alrb_davixUuidGen"
    \echo "Text file for testing davix" >> $alrb_rucioUploadDir/$alrb_davixMyFile

    \rm -f $alrb_relTestDir/davix-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/davix-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "davix" "rucio -w" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
alrb_davixMyFile=$alrb_davixMyFile
alrb_davixMyDir=$alrb_davixMyDir
source $alrb_relTestDir/davixUrl.sh
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_davixTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mdavix test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup davix -q
	davix-get --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_davixTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio upload dataset"
	alrb_fn_rucioUploadDS
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get pfns"
	alrb_fn_rucioGetPfns
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix get url"
	alrb_fn_davixGetUrl
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix-mkdir test"
	alrb_fn_davixMkdirTest
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix-put test"
	alrb_fn_davixPutTest
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix-ls test"
	alrb_fn_davixLsTest
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix-get test"
	alrb_fn_davixGetTest
	alrb_fn_addSummary $? continue	
	
	alrb_fn_initSummary $alrb_tool $alrb_thisShell "davix-rm test"
	alrb_fn_davixRmTest
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio erase dataset"
	alrb_fn_rucioEraseDS
	alrb_fn_addSummary $? continue

    done

    return 0
}


