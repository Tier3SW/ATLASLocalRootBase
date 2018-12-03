#!----------------------------------------------------------------------------
#!
#! functions-Linux.sh
#!
#! functions for testing the tools
#!
#! Usage:
#!     not directy
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


#!---------------------------------------------------------------------------- 
alrb_fn_asetupTestRun()
#!---------------------------------------------------------------------------- 
{
    
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell
    local alrb_thisRelease
    local alrb_tmpVal
    local let alrb_maxRelArSize=0

    local alrb_testAsetupVersionAr=()
    local alrb_testASetupCScriptAr=()

    alrb_testAsetupVersionAr[0]="$ALRB_asetupVersion"
    alrb_testASetupCScriptAr[0]="$ALRB_testASetupCScript"
    alrb_testASetupCMakeScriptAr[0]="$ALRB_testASetupCMakeScript"

    if [ "$alrb_Mode" = "test" ]; then
	local let alrb_maxRelArSize=1
	alrb_testAsetupVersionAr[1]="$ALRB_testAsetupVersionNew"
	alrb_testASetupCScriptAr[1]="$ALRB_testASetupCScriptNew"
	alrb_testASetupCMakeScriptAr[1]="$ALRB_testASetupCMakeScriptNew"
	\echo -e "
\e[1masetup test\e[0m 
comparisons of:"

    else
    \echo -e "
\e[1masetup test\e[0m 
"
    fi

    (
	for ((alrb_tmpVal=0; alrb_tmpVal<=$alrb_maxRelArSize;alrb_tmpVal++)); do
	    export ALRB_asetupVersion="${alrb_testAsetupVersionAr[$alrb_tmpVal]}"
	    export AtlasSetupSite="${alrb_testASetupCScriptAr[$alrb_tmpVal]}"
	    export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	    export ALRB_tmpAtlasSetupSiteCMake="${alrb_testASetupCMakeScriptAr[$alrb_tmpVal]}"
	    (
		source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
		if [ ! -z $AtlasSetupSiteCMake ]; then
		    export AtlasSetupSiteCMake=$ALRB_tmpAtlasSetupSiteCMake
		fi
		\echo " "
		\echo "asetup version : " `asetup --version`
		\echo "AtlasSetupSite : $AtlasSetupSite"
		\echo "AtlasSetupSiteCMake: $AtlasSetupSiteCMake"
	    )
	done
    )

    for alrb_thisRelease in `\echo $ALRB_testAsetupReleaseList | \sed -e 's|;| |g'`; do
	for alrb_thisShell in ${alrb_testShellAr[@]}; do
	    local alrb_addStatus=""
	    local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisRelease/$alrb_thisShell"
	    \mkdir -p $alrb_relTestDir
	    alrb_fn_initSummary $alrb_tool $alrb_thisShell $alrb_thisRelease

	    for ((alrb_tmpVal=0; alrb_tmpVal<=$alrb_maxRelArSize;alrb_tmpVal++)); do
		\cat << EOF >> $alrb_relTestDir/printEnv.${alrb_tmpVal}.sh
env | env LC=ALL \sort > $alrb_relTestDir/env.${alrb_tmpVal}.original
\cat $alrb_relTestDir/env.${alrb_tmpVal}.original | \sed -e 's|'\$ATLAS_LOCAL_ASETUP_VERSION'|REPLACED|g' | \egrep -v ASETUP_PPID | \egrep -v AtlasSetupSite | \egrep -v AtlasSetupVersion | \egrep -v ALRB_asetupVersion > $alrb_relTestDir/env.$alrb_tmpVal 
alias | env LC=ALL \sort > $alrb_relTestDir/alias.${alrb_tmpVal}.original
\cat $alrb_relTestDir/alias.${alrb_tmpVal}.original | \sed -e 's|'\$ATLAS_LOCAL_ASETUP_VERSION'|REPLACED|g' > $alrb_relTestDir/alias.${alrb_tmpVal}
EOF
		
		local alrb_runScript=$alrb_relTestDir/asetup-script-${alrb_tmpVal}
		local alrb_asetupOutput=$alrb_relTestDir/asetup-${alrb_tmpVal}.txt
		\rm -f $alrb_runScript
		\cat << EOF >> $alrb_runScript
source $alrb_envFile.sh
export ALRB_asetupVersion="${alrb_testAsetupVersionAr[$alrb_tmpVal]}"
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
export AtlasSetupSite="${alrb_testASetupCScriptAr[$alrb_tmpVal]}"
if [ ! -z \$AtlasSetupSiteCMake ]; then
  export AtlasSetupSiteCMake="${alrb_testASetupCMakeScriptAr[$alrb_tmpVal]}"
fi
source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "asetup --version; env | \grep -e AtlasSetupSite; asetup $alrb_thisRelease"  $alrb_asetupOutput $alrb_Verbose
if [ \$? -ne 0 ]; then
  exit 64
fi
source $alrb_relTestDir/printEnv.${alrb_tmpVal}.sh
EOF
		alrb_fn_runShellScript $alrb_thisShell $alrb_runScript 
		alrb_retCode=$?
		if [ $alrb_retCode -ne 0 ]; then
		    break
		fi	       
	    done
	    
	    if [ $alrb_retCode -ne 0 ]; then
		continue
	    elif [ $alrb_maxRelArSize -eq 1 ]; then		
		diff -w $alrb_relTestDir/alias.0 $alrb_relTestDir/alias.1 > $alrb_relTestDir/alias.diff
		if [ $? -ne 0 ]; then
		    local alrb_aliasDiff="YES"
		else
		    local alrb_aliasDiff="NO"
		fi
		local alrb_tmpAr=( `diff -w $alrb_relTestDir/env.0 $alrb_relTestDir/env.1 | \grep -e "=" | \sed -e 's|^[\<\>] \(.*\)=.*|\1|g' | env LC=ALL  \sort -u `)
		if [[ ${#alrb_tmpAr} -gt 0 ]] || [[ "$alrb_aliasDiff" = "YES" ]] ; then
		    \cat $alrb_relTestDir/asetup-*.txt
		    if [ "$alrb_aliasDiff" = "YES" ]; then
			\echo "
Alias differences:
"
			\cat $alrb_relTestDir/alias.diff
		    fi
		fi
		for alrb_thisEnv in ${alrb_tmpAr[@]}; do		    
		    \echo "
Differences seen for $alrb_thisEnv:"
		    alrb_addStatus="READ"		    
		    \grep -e "^$alrb_thisEnv=" $alrb_relTestDir/env.0.original | \cut -f 2- -d "=" | tr ':' '\n' > $alrb_relTestDir/env.0.$alrb_thisEnv 
		    \grep -e "^$alrb_thisEnv=" $alrb_relTestDir/env.1.original | \cut -f 2- -d "=" | tr ':' '\n' > $alrb_relTestDir/env.1.$alrb_thisEnv
		    diff -b $alrb_relTestDir/env.0.$alrb_thisEnv $alrb_relTestDir/env.1.$alrb_thisEnv 
		done
	    fi

	    alrb_fn_addSummary $alrb_retCode continue $alrb_addStatus
	done
    done

    return 0
}


