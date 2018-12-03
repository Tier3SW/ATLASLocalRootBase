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
alrb_fn_rucioCheckID()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="id"

    local alrb_cmdWhoami="rucio whoami"
    local alrb_cmdWhoamiName="$alrb_relTestDir/rucio-whoami.out"

    local alrb_cmdVomsId="voms-proxy-info -identity"
    local alrb_identityFile="$alrb_relTestDir/rucio-identity.out"

    local alrb_cmdRucioId="rucio-admin account list-identities $RUCIO_ACCOUNT"
    local alrb_cmdRucioIdName="$alrb_relTestDir/rucio-list-identity.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"

    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdWhoami" $alrb_cmdWhoamiName $alrb_Verbose
alrb_retCode=\$?
if [ \$alrb_retCode -eq 0 ]; then 
    \grep -e " \${RUCIO_ACCOUNT}" $alrb_cmdWhoamiName > /dev/null 2>&1
    alrb_retCode=\$?
    if [ \$alrb_retCode -ne 0 ]; then
	\cat $alrb_cmdWhoamiName
	\echo "Error: rucio whoami does not have identity \$RUCIO_ACCOUNT"
    fi
fi

if [ \$alrb_retCode -eq 0 ]; then
    source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdVomsId" $alrb_identityFile $alrb_Verbose
    alrb_retCode=\$?
fi    

if [ \$alrb_retCode -eq 0 ]; then
    alrb_identity=\`\cat $alrb_identityFile\`
    source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh  "$alrb_cmdRucioId" $alrb_cmdRucioIdName $alrb_Verbose
    alrb_retCode=\$?
fi
if [ \$alrb_retCode -eq 0 ]; then
    \grep -e "\$alrb_identity" $alrb_cmdRucioIdName > /dev/null 2>&1
    alrb_retCode=\$?  
    if [ \$alrb_retCode -ne 0 ]; then
	\echo "Error: unable to find identity \$alrb_identity in rucio-admin:"
	\cat $alrb_cmdRucioIdName
    fi
fi

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?
    
    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioListRse()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="listRse"

    local alrb_cmdListRse="rucio list-rses"
    local alrb_cmdListRseName="$alrb_relTestDir/rucio-list-rses.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdListRse" $alrb_cmdListRseName $alrb_Verbose
alrb_retCode=\$?

if [ \$alrb_retCode -ne 0 ]; then 
  \grep -e "$alrb_rseName" $alrb_cmdListRseName > /dev/null 2>&1
  alrb_retCode=\$? 
  if [ \$alrb_retCode -ne 0 ]; then
      \cat $alrb_cmdListRseName
      \echo "Error: $alrb_rseName not found in rucio list-rses"
  fi
fi

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?
    
    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioPrepareUploadFiles()
#!---------------------------------------------------------------------------- 
{
    \mkdir -p $alrb_rucioUploadDir
    local alrb_uploadFileAr=( `\find $alrb_rucioUploadDir -mindepth 1 -maxdepth 1 -type f | \awk -F/ '{print $NF}' | \sed -e 's|^|'$alrb_rucioScope':|g'` )
    if [ ${#alrb_uploadFileAr[@]} -eq 0 ]; then
	\echo $alrb_rucioUuidGen > $alrb_rucioUploadDir/myFile.${alrb_rucioUuidGen}.log
	alrb_uploadFileAr=( "$alrb_rucioScope:myFile.${alrb_rucioUuidGen}.log" )
    fi
    alrb_rucioDiDs="\"${alrb_uploadFileAr[@]}\""

    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioUploadDS()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="upload"

    if [ "$alrb_rucioDiDs" = "" ]; then
	alrb_fn_rucioPrepareUploadFiles
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi

    alrb_cmdUploadFile="rucio upload --scope $alrb_rucioScope --rse $alrb_rseName $alrb_rucioUploadDir"
    alrb_cmdUploadFileName="$alrb_relTestDir/rucio-upload.out"

    alrb_cmdAddataset="rucio add-dataset $alrb_rucioMyDataset"
    alrb_cmdAddatasetName="$alrb_relTestDir/rucio-add-dataset.out"

    alrb_cmdAttachDS="rucio attach $alrb_rucioMyDataset $alrb_rucioDiDs"
    alrb_cmdAttachDSName="$alrb_relTestDir/rucio-attadh.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdUploadFile" $alrb_cmdUploadFileName $alrb_Verbose
alrb_retCode=\$? 

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAddataset" $alrb_cmdAddatasetName $alrb_Verbose
  alrb_retCode=\$?
fi

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdAttachDS" $alrb_cmdAttachDSName $alrb_Verbose
  alrb_retCode=\$?
fi

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript 
    alrb_retCode=$?
    
    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioListDS()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="list"

    local alrb_cmdListDS="rucio list-files $alrb_rucioMyDataset"
    local alrb_cmdListDSName="$alrb_relTestDir/rucio-list-files.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdListDS" $alrb_cmdListDSName $alrb_Verbose
alrb_retCode=\$? 

if [ \$alrb_retCode -eq 0 ]; then 
  \grep -e "$alrb_rucioMyFile" $alrb_cmdListDSName > /dev/null 2>&1
  alrb_retCode=\$? 
  if [ \$alrb_retCode -ne 0 ]; then
    \cat $alrb_cmdListDSName 
    \echo "Error: $alrb_rucioMyFile is not in file listing"
  fi
fi

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript 
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioGetDS()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="get"

    local alrb_cmdGetDS="rucio get $alrb_rucioMyDataset --dir $alrb_relTestDir"
    local alrb_cmdGetDSName="$alrb_relTestDir/rucio-get.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \rm -f $alrb_runScript 
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGetDS" $alrb_cmdGetDSName $alrb_Verbose
alrb_retCode=\$? 

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript 
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioGetPfns()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="pfns"

    local alrb_cmdGetDS="rucio list-file-replicas $alrb_rucioDiDs --protocols root,davs,srm --pfns --domain wan"
    local alrb_cmdGetDSName="$alrb_relTestDir/rucio-pfns.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \rm -f $alrb_runScript 
    \cat <<EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdGetDS" $alrb_cmdGetDSName $alrb_Verbose
alrb_retCode=\$? 

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript 
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioEraseDS()
#!---------------------------------------------------------------------------- 
{

    local alrb_retCode=0
    local alrb_runName="erase"

    local alrb_cmdEraseFile="rucio erase $alrb_rucioDiDs"
    local alrb_cmdEraseFileName="$alrb_relTestDir/rucio-erase-file.out"

    local alrb_cmdEraseDS="rucio erase $alrb_rucioMyDataset"
    local alrb_cmdEraseDSName="$alrb_relTestDir/rucio-erase-dataset.out"

    local alrb_runScript="$alrb_relTestDir/rucio-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat << EOF >> $alrb_runScript
source $alrb_relTestDir/rucio-script-setup.sh

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEraseFile" $alrb_cmdEraseFileName $alrb_Verbose
alrb_retCode=\$?

if [ \$alrb_retCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdEraseDS" $alrb_cmdEraseDSName $alrb_Verbose
  alrb_retCode=\$?
fi

exit \$alrb_retCode

EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode
}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    (
	if [ ! -e $alrb_workDir/rseToUse.sh ]; then
	    alrb_fn_rucioCheckRse
	    exit $?
	fi
	exit 0
    )
    if [ $? -ne 0 ]; then
	return 64
    fi

    source $alrb_workDir/rseToUse.sh
    alrb_rucioUuidGen=`uuidgen`
    alrb_rucioScope="user.${RUCIO_ACCOUNT}"
    alrb_rucioMyDataset="${alrb_rucioScope}:user.${RUCIO_ACCOUNT}.dataset.${alrb_rucioUuidGen}"
    alrb_rucioUploadDir=$alrb_relTestDir/rucioUpload
    alrb_rucioDiDs=""

    \rm -f $alrb_relTestDir/rucio-script-setup.sh 
    \cat << EOF >> $alrb_relTestDir/rucio-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup rucio $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
source $alrb_workDir/rseToUse.sh
alrb_rucioUuidGen=$alrb_rucioUuidGen
alrb_rucioScope=$alrb_rucioScope
alrb_rucioMyDataset=$alrb_rucioMyDataset
alrb_rucioUploadDir=$alrb_rucioUploadDir
alrb_rucioDiDs="$alrb_rucioDiDs"
EOF

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_rucioCheckRse()
#!----------------------------------------------------------------------------
{

    local let alrb_retCode=0
    local alrb_result
    local alrb_toolWorkdir="$alrb_workDir/rucio"

    \echo "
Getting appropriate Rucio RSE to use for testing ...
"

    mkdir -p $alrb_toolWorkdir
    source $alrb_envFile.sh
    export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
    source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
    lsetup agis $alrb_VerboseOpt
    if [ $? -ne 0 ]; then
	return 64
    fi
    
    local let alrb_retCode=64
    local alrb_rseName
    local alrb_result
    for alrb_rseName in `\echo $ALRB_testRucioRseList | \sed -e 's|\;| |g'`; do
	\echo "
Checking $alrb_rseName ..."
	\rm -f $alrb_toolWorkdir/ddmendpt.out
	
	local alrb_cmd="agis-list-ddmendpoints -d $alrb_rseName"
	eval $alrb_cmd > $alrb_toolWorkdir/ddmendpt.out 2>&1
	if [[ $? -ne 0 ]] || [[ `\grep -e "NO matches found" $alrb_toolWorkdir/ddmendpt.out` ]];  then
	    \echo $alrb_cmd
	    \cat $alrb_toolWorkdir/ddmendpt.out
	    continue
	fi
	alrb_result=`\egrep -v "^#" $alrb_toolWorkdir/ddmendpt.out | \tr -s " "`
	local alrb_tier=`\echo "$alrb_result" | \cut -f 7 -d " "`
	if [ "$alrb_tier" = "3" ]; then
	    \echo "Warning: Site for $alrb_rseName is a Tier3 and may not be completely accessible"
	    continue
	fi
	local alrb_siteName=`\echo "$alrb_result" | \cut -f 4 -d " "`
	\rm -f $alrb_toolWorkdir/downtime.out
	local alrb_cmd="agis-list-downtimes -s $alrb_siteName"
	eval $alrb_cmd > $alrb_toolWorkdir/downtime.out 2>&1 
	alrb_result=`\grep -e "NO matches found" $alrb_toolWorkdir/downtime.out`
	if [ $? -ne 0 ]; then 
	    \echo " "
	    \echo "Found possible information for services that could affect $alrb_rseName:"
	    \echo $alrb_cmd
	    \cat $alrb_toolWorkdir/downtime.out
	    \echo " "
	    \echo "These are not definitive and you should read the above description to be sure."
	    continue
	else
	    let alrb_retCode=0
	    \echo "alrb_rseName=$alrb_rseName" > $alrb_workDir/rseToUse.sh
	    break
	fi
	
    done

    return $alrb_retCode

}


#!---------------------------------------------------------------------------- 
alrb_fn_rucioTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0

    \echo -e "
\e[1mrucio test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup rucio -q
	rucio --version
    )

    local alrb_thisShell
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_rucioTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio checkID"
	alrb_fn_rucioCheckID
	alrb_fn_addSummary $? exit

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio list rse"
	alrb_fn_rucioListRse
	alrb_fn_addSummary $? exit	

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio upload dataset"
	alrb_fn_rucioUploadDS
	alrb_fn_addSummary $? exit	
	
	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio list dataset"
	alrb_fn_rucioListDS
	alrb_fn_addSummary $? continue
	
	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get pfns"
	alrb_fn_rucioGetPfns
	alrb_fn_addSummary $? continue
	
	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio get dataset"
	alrb_fn_rucioGetDS
	alrb_fn_addSummary $? continue
	
	alrb_fn_initSummary $alrb_tool $alrb_thisShell "rucio erase dataset"
	alrb_fn_rucioEraseDS
	alrb_fn_addSummary $? continue

    done

    return 0
}


