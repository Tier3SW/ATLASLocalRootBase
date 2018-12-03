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
alrb_fn_rootGenerateFile()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_runName="generate"

    local alrb_cmdGenerate="root -b -q '$ATLAS_LOCAL_ROOT_BASE/testing/scripts/root/create_file.C'"
    local alrb_cmdGenerateName="$alrb_relTestDir/generate.out"

    local alrb_runScript="$alrb_relTestDir/root-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/root-script-setup.sh
export ALRB_TESTING_FILENAME=$alrb_rootMyFile
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGenerate" $alrb_cmdGenerateName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?
    
    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rootReadFile()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="read"

    local alrb_cmdRead="root -b '$ATLAS_LOCAL_ROOT_BASE/testing/scripts/root/read_file.C'"
    local alrb_cmdReadName="$alrb_relTestDir/read.out"

    local alrb_runScript="$alrb_relTestDir/root-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/root-script-setup.sh
export ALRB_TESTING_FILENAME=$alrb_rootMyFile
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdRead" $alrb_cmdReadName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?
    
    return $alrb_retCode

}


#!---------------------------------------------------------------------------- 
alrb_fn_rootRemoteXrootdAccess()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="remoteXrootd"

    local alrb_rootRemoteFile=`\grep -e "^root://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdReadXRootd="root -b '$ATLAS_LOCAL_ROOT_BASE/testing/scripts/root/read_file.C'"
    local alrb_cmdReadXRootdName="$alrb_relTestDir/read-xrootd.out"

    local alrb_runScript="$alrb_relTestDir/root-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/root-script-setup.sh

export ALRB_TESTING_FILENAME="$alrb_rootRemoteFile"
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdReadXRootd" $alrb_cmdReadXRootdName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rootRemoteDavixAccess()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="remoteDavix"

    local alrb_rootRemoteFile=`\grep -e "^davs://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdReadXRootd="root -b '$ATLAS_LOCAL_ROOT_BASE/testing/scripts/root/read_file.C'"
    local alrb_cmdReadXRootdName="$alrb_relTestDir/read-davix.out"

    local alrb_runScript="$alrb_relTestDir/root-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/root-script-setup.sh

export ALRB_TESTING_FILENAME="$alrb_rootRemoteFile"
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdReadXRootd" $alrb_cmdReadXRootdName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rootXcacheTest()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="xcacheTest"

    if [ -e $alrb_relTestDir/xcache-setup.sh ]; then
	source $alrb_relTestDir/xcache-setup.sh
    else
	\echo "Error : unable to find xcache-setup in dir"
	return 64
    fi

    local alrb_rootRemoteFile=`\grep -e "^root://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdReadXRootdXcache="root -b '$ATLAS_LOCAL_ROOT_BASE/testing/scripts/root/read_file.C'"
    local alrb_cmdReadXRootdXcacheName="$alrb_relTestDir/read-xrootd-xcache.out"

    local alrb_runScript="$alrb_relTestDir/root-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/root-script-setup.sh

export ALRB_TESTING_FILENAME="${ALRB_XCACHE_PROXY}$alrb_rootRemoteFile"
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdReadXRootdXcache" $alrb_cmdReadXRootdXcacheName $alrb_Verbose
alrb_retCode=\$?
exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rootTestSetupEnv()
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

    alrb_rootUuidGen=`uuidgen`
    \mkdir -p $alrb_rucioUploadDir
    alrb_rootMyFile="$alrb_rucioUploadDir/myFile.${alrb_rootUuidGen}.root"
    \rm -f $alrb_relTestDir/root-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/root-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "root" $alrb_VerboseOpt "rucio -w"
if [ \$? -ne 0 ]; then
  exit 64
fi
alrb_rootUuidGen=$alrb_rootUuidGen
alrb_rootMyFile=$alrb_rootMyFile
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_rootTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mroot test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup root -q
	$ROOTSYS/bin/root-config --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_rootTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root generate file"
	alrb_fn_rootGenerateFile
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root read file"
	alrb_fn_rootReadFile
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio upload dataset"
	alrb_fn_rucioUploadDS
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get pfns"
	alrb_fn_rucioGetPfns
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root xrootd access file"
	alrb_fn_rootRemoteXrootdAccess
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root davix access file"
	alrb_fn_rootRemoteDavixAccess
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio erase dataset"
	alrb_fn_rucioEraseDS
	alrb_fn_addSummary $? continue

    done

    return 0
}


