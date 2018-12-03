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
alrb_fn_xrootdCopy()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="xrdcp"

    local alrb_rootRemoteFile=`\grep -e "^root://" $alrb_relTestDir/rucio-pfns.out` 
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_cmdReadXRootd="xrdcp $alrb_rootRemoteFile file://$alrb_relTestDir/downloadedXrdcpFile"
    local alrb_cmdReadXRootdName="$alrb_relTestDir/read-xrootd.out"

    local alrb_runScript="$alrb_relTestDir/xrootd-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/xrootd-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdReadXRootd" $alrb_cmdReadXRootdName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_xrootdXcacheStart()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="xcacheStart"

    local alrb_xcacheOpt=""
    if [ ! -z "$ALRB_xrootdVersion" ]; then
	alrb_xcacheOpt="$alrb_xcacheOpt -x $ALRB_xrootdVersion"
    fi

    local alrb_cmdStartXcache="xcache start -d $alrb_relTestDir/xcache $alrb_xcacheOpt"
    local alrb_cmdStartXcacheName="$alrb_relTestDir/xcache-start.out"

    local alrb_runScript="$alrb_relTestDir/xrootd-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/xrootd-script-setup.sh
lsetup xcache
if [ \$? -ne 0 ]; then
  exit 64
fi

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdStartXcache" $alrb_cmdStartXcacheName $alrb_Verbose
alrb_retCode=\$?

\rm -f $alrb_relTestDir/xcache-setup.sh
if [ \$alrb_retCode -eq 0 ]; then
  \echo "export \"ALRB_XCACHE_PROXY_REMOTE=\$ALRB_XCACHE_PROXY_REMOTE\"" >> $alrb_relTestDir/xcache-setup.sh
  \echo "export \"ALRB_XCACHE_PROXY=\$ALRB_XCACHE_PROXY\"" >> $alrb_relTestDir/xcache-setup.sh
fi

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_xrootdXcacheList()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="xcacheList"

    local alrb_cmdListXcache="xcache list -d $alrb_relTestDir/xcache"
    local alrb_cmdListXcacheName="$alrb_relTestDir/xcache-list.out"

    local alrb_cmdListXcacheDir="du -b $alrb_relTestDir/xcache"
    local alrb_cmdListXcacheDirName="$alrb_relTestDir/xcache-dirList.out"

    local alrb_runScript="$alrb_relTestDir/xrootd-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/xrootd-script-setup.sh
lsetup xcache
if [ \$? -ne 0 ]; then
  exit 64
fi

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdListXcacheDir" $alrb_cmdListXcacheDirName $alrb_Verbose

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdListXcache" $alrb_cmdListXcacheName $alrb_Verbose
alrb_retCode=\$?

exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_xrootdXcacheKill()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="xcacheKill"

    local alrb_cmdKillXcache="xcache kill -p all"
    local alrb_cmdKillXcacheName="$alrb_relTestDir/xcache-kill.out"

    local alrb_runScript="$alrb_relTestDir/xrootd-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/xrootd-script-setup.sh
lsetup xcache
if [ \$? -ne 0 ]; then
  exit 64
fi

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdKillXcache" $alrb_cmdKillXcacheName $alrb_Verbose
alrb_retCode=\$?
exit \$alrb_retCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_xrootdTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    alrb_fn_sourceTestFunctions root
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_fn_rootTestSetupEnv
    if [ $? -ne 0 ]; then
	return 64
    fi

    \rm -f $alrb_relTestDir/xrootd-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/xrootd-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "xrootd" "rucio -w" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_xrootdTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mxrootd test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup xrootd -q
	xrdcp --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_xrootdTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root generate file"
	alrb_fn_rootGenerateFile
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio upload dataset"
	alrb_fn_rucioUploadDS
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get pfns"
	alrb_fn_rucioGetPfns
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "xrootd xrdcp file"
	alrb_fn_xrootdCopy
	alrb_fn_addSummary $? continue	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "xrootd xcache start"
	alrb_fn_xrootdXcacheStart
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "root xcache test"
	alrb_fn_rootXcacheTest
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "xrootd xcache list"
	alrb_fn_xrootdXcacheList
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "xrootd xcache kill"
	alrb_fn_xrootdXcacheKill
	alrb_fn_addSummary $? continue

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio erase dataset"
	alrb_fn_rucioEraseDS
	alrb_fn_addSummary $? continue

    done

    return 0
}


