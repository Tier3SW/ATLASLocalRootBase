#!----------------------------------------------------------------------------
#!
#! functions.sh
#!
#! General purpose functoins for rhe sw tools
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


alrb_fn_sourceFunctions() 
{
    local alrb_tool=$1
    local alrb_result
    local alrb_rc=0
    alrb_result=`type -t alrb_fn_${alrb_tool}Depend`
    alrb_rc=$?
    if [[ $alrb_rc -ne 0 ]] || [[ "$alrb_result" != "function" ]]; then
	if [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_tool}/functions-${ALRB_OSTYPE}.sh" ]; then
	    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_tool}/functions-${ALRB_OSTYPE}.sh 
	    alrb_rc=$?
	elif [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_tool}/functions.sh" ]; then
	    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_tool}/functions.sh
	    alrb_rc=$?
	else
	    \echo "Error: unable to find functions.sh for $alrb_tool" 1>&2
	    alrb_rc=64
	fi
    fi
    return $alrb_rc
}


alrb_fn_versionConvert() 
{
    local alrb_tool=$1
    local alrb_value=$2
    alrb_fn_sourceFunctions "$alrb_tool"
    if [ $? -ne 0 ]; then
	return 64
    fi
    alrb_fn_${alrb_tool}VersionConvert "$alrb_value"
    return $?
}


alrb_fn_depend() 
{

    local alrb_result

    local alrb_tool=$1

# this tool has been overridden if it is from the overridden client, skip it 
    if [ "$alrb_OverriddenDependencies" != "" ]; then
	alrb_result=`\echo $alrb_OverriddenDependencies | \grep -e ",${alrb_tool},"`
	if [ $? -eq 0 ]; then
	    alrb_result=`\echo $@ | \grep -e "${alrb_tool} .* -c ${alrb_PrimaryTool}[ ]*$" `
	    if [ $? -eq 0 ]; then
		return 0
	    fi
	fi
    fi

    shift
    local alrb_ToolOpts=$@
    alrb_fn_sourceFunctions "$alrb_tool"
    if [ $? -ne 0 ]; then
	return 64
    fi

    alrb_result=`type -t alrb_fn_${alrb_tool}FilterArgs`
    if [ $? -eq 0 ]; then
	alrb_ToolOpts=`alrb_fn_${alrb_tool}FilterArgs $alrb_ToolOpts`
    fi
    alrb_fn_${alrb_tool}Depend $alrb_ToolOpts
    return $?
}


alrb_fn_getSynonymInfo()
{
    if [ "$2" = "tool" ]; then
	local let alrb_pos=4
    elif [ $2 = "dir" ]; then
	local let alrb_pos=3
    elif [ $2 = "pass" ];then
	local let alrb_pos=2
    else
	\echo "Error: unspecified field for getSynonymInfo" 1>&2
	return 64
    fi

    local alrb_result
    alrb_result=`\grep -i ",$1," $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt 2>&1`
    if [ $? -eq 0 ]; then
	\echo $alrb_result | \cut -f $alrb_pos -d ","
	return 0
    else
	 \echo "Error: Synonyms did not return the $1 dir" 1>&2
	 return 64
    fi
}


alrb_fn_traceDependency() 
{
    local alrb_tool=$1
    alrb_fn_sourceFunctions "$alrb_tool"
    if [ $? -ne 0 ]; then
	return 64
    fi
    local alrb_oldifs="$IFS"
    IFS=$'\n'
    local alrb_tempAr=( `type alrb_fn_${alrb_tool}Depend | \grep alrb_fn_depend | \sed -e 's/.*alrb_fn_depend \(.*\)/\1/g'` )
    IFS="$alrb_oldifs"
    local alrb_item
    for alrb_item in "${alrb_tempAr[@]}"; do
	local alrb_dependOn=`\echo $alrb_item | \cut -f 1 -d " "`
	\eval alrb_dependOn=${alrb_dependOn}
	local alrb_leftover=`\echo $alrb_item | \cut -f 2 -d " "`
	alrb_dependency=$(\echo alrb_${alrb_dependOn}_dependency)
	\eval alrb_${alrb_dependOn}_dependency="${!alrb_dependency},$alrb_tool:$alrb_leftover,"
	alrb_fn_traceDependency "$alrb_dependOn"
    done
    
    return 0
}


alrb_fn_getPass1Dependency() 
{
    local alrb_tool=$1
    alrb_fn_sourceFunctions "$alrb_tool"
    if [ $? -ne 0 ]; then
	return 64
    fi
    local alrb_result
    alrb_result=`type -t alrb_fn_${alrb_tool}GetPass1Dependency`
    if [ $? -eq 0 ]; then
	alrb_fn_${alrb_tool}GetPass1Dependency
	return $?
    fi
    return 0
}


alrb_fn_doOverrides() 
{
    if [ ! -e "$ATLAS_LOCAL_ROOT_BASE/etc/dependencies.txt" ]; then
	return 0
    fi

    local alrb_tool=$1
    local alrb_version=$2
    local alrb_client="${3}:override"

    local alrb_tempAr=( `\grep -e "^$alrb_tool $alrb_version" $ATLAS_LOCAL_ROOT_BASE/etc/dependencies.txt | \cut -f 3 -d " "` ) 
    for alrb_item in "${alrb_tempAr[@]}"; do  
	local alrb_owTool=`\echo $alrb_item | \cut -f 1 -d ":"`
	local alrb_owToolVer=`\echo $alrb_item | \cut -f 2 -d ":"`
	alrb_fn_depend "$alrb_owTool" "$alrb_owToolVer" "-c $alrb_client"
	if [ $? -ne 0 ]; then
	    return 64
	fi
	alrb_OverriddenDependencies="$alrb_OverriddenDependencies,$alrb_owTool,"
    done
    return 0
}


alrb_fn_searchMapForVersion()
{
    local alrb_candidate=$1
    local alrb_toolDir=$2

    local alrb_result
    alrb_result=`\grep -e "|$alrb_candidate|" $alrb_toolDir/.alrb/mapfile.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_candRealVersion=`\echo $alrb_result | \cut -f 3 -d "|"`
	alrb_candVirtVersion=`\echo $alrb_result | \cut -f 4 -d "|"`	
	return 0
    fi
    
    return 64
}


alrb_fn_getToolSpecialVersion()
{
    local alrb_specialVersionTag=$1

    if [ "$ALRB_OSTYPE" = "Linux" ]; then
	alrb_fn_searchMapForVersion "$alrb_specialVersionTag-SL${ALRB_OSMAJORVER}" "$alrb_toolDir"
    elif [ "$ALRB_OSTYPE" = "MacOSX" ]; then
	alrb_fn_searchMapForVersion "$alrb_specialVersionTag-MacOS${ALRB_OSMAJORVER}" "$alrb_toolDir"
    fi
    if [ $? -ne 0 ]; then
	alrb_fn_searchMapForVersion "$alrb_specialVersionTag" "$alrb_toolDir"
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi		

    return 0

}


alrb_fn_getToolVersion()
{

    local alrb_tool=$1
    local alrb_candidate=$2
    local alrb_searchArgs=$3

    alrb_candRealVersion=""
    alrb_candVirtVersion=""
    
    local alrb_toolDir=`alrb_fn_getInstallDir "$alrb_tool"`
    if [ $? -ne 0 ]; then	
	return 64
    fi

    if [ "$alrb_candidate" != "" ]; then
	alrb_candidate=`\echo $alrb_candidate | \sed -e 's/^default/current/g'`
    fi

    local alrb_result

    if [[ "$alrb_candidate" = "" ]] || [[ "$alrb_candidate" = "dynamic" ]]; then
	alrb_fn_getToolSpecialVersion current
	if [ $? -ne 0 ]; then
	    alrb_fn_getToolSpecialVersion recommended
	    if [ $? -ne 0 ]; then
		\echo "Error: unable to setup default version value for $alrb_tool"
	    else
		\echo "Error: You need to specify a $alrb_tool version.  The current recommendation is
         lsetup \"$alrb_tool $alrb_candVirtVersion\" 
		  or 
         export ALRB_${alrb_tool}Version=$alrb_candVirtVersion
         lsetup root
       Please consult your analysis group if you need a specific version for
       your work.  To see what versions are available, type
         showVersions $alrb_tool"
	    fi
	    return 64
	fi		

    elif [ "$alrb_candidate" = "testing" ]; then

	alrb_fn_getToolSpecialVersion testing
	if [ $? -ne 0 ]; then
	    \echo "Error: unable to setup testing version value for $alrb_tool"
	    return 64
	fi		

    elif [ "$alrb_candidate" = "recommended" ]; then

	alrb_fn_getToolSpecialVersion recommended
	if [ $? -ne 0 ]; then
	    \echo "Error: unable to setup recommended version value for $alrb_tool"
	    return 64
	fi		

    else
	alrb_fn_searchMapForVersion "$alrb_candidate" "$alrb_toolDir"
	if [ $? -ne 0 ]; then
	    alrb_result=`\echo $alrb_candidate | \grep $alrb_tool 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_fn_parseVersionVar "$alrb_candidate" 
		local alrb_tmpAr=( `\echo $alrb_searchArgs | \sed -e 's/:/ /g'` )
		local alrb_item
		local alrb_cmd="\cat $alrb_toolDir/.alrb/mapfile.txt"
		for alrb_item in ${alrb_tmpAr[@]}; do
		    if [ "$alrb_item" = "alrb_firstVer" ]; then
			alrb_item=`\echo $alrb_firstVer | \cut -f 1 -d " "`
			alrb_cmd="$alrb_cmd | \grep -e \"$alrb_item\""
		    elif [ "$alrb_item" = "alrb_native" ]; then
			alrb_cmd="$alrb_cmd | \egrep -i -v \"gcc\" | \egrep -i -v \"python\""
		    else
			alrb_cmd="$alrb_cmd | \grep -e \"\$$alrb_item\""
		    fi
		done
		alrb_cmd="$alrb_cmd | env LC_ALL=C \sort -n | \tail -n 1"
		alrb_result=`eval $alrb_cmd`
		if [[ $? -ne 0 ]] || [[ "$alrb_result" = "" ]]; then
		    \echo "Error: unable to find match to $alrb_candidate"
		    return 64
		else
		    local alrb_tmpVal=`\echo $alrb_result | \cut -f 3 -d "|"`
		    alrb_fn_searchMapForVersion "$alrb_tmpVal" "$alrb_toolDir"
		fi
	    else
# try to guess !
		local alrb_cmd="\cat $alrb_toolDir/.alrb/mapfile.txt | \grep -e \"$alrb_candidate\""		
		if [ "$ALRB_OSTYPE" = "Linux" ]; then
		    alrb_cmd="$alrb_cmd | \grep -e slc$ALRB_OSMAJORVER -e sl$ALRB_OSMAJORVER -e centos$ALRB_OSMAJORVER"
		elif [ "$ALRB_OSTYPE" = "MacOSX" ]; then
		     alrb_cmd="$alrb_cmd | \grep -e mac10$ALRB_OSMAJORVER -e macos10$ALRB_OSMAJORVER -e macosx10$ALRB_OSMAJORVER"
		fi
		local alrb_tmpAr=( `eval $alrb_cmd` ) 
		if [ ${#alrb_tmpAr[@]} -gt 1 ]; then
		    local alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_preSetupEnv "arch:"`
		    alrb_cmd="$alrb_cmd | \grep -e \"$alrb_tmpVal\""
		    local alrb_tmpAr=( `eval $alrb_cmd` )
		fi
		if [ ${#alrb_tmpAr[@]} -ne 1 ]; then
		    \echo "Error: unable to find $alrb_candidate version for $alrb_tool"
		    return 64		
		else
		    local alrb_tmpVal=`\echo ${alrb_tmpAr[0]} | \cut -f 3 -d "|"`
		    alrb_fn_searchMapForVersion "$alrb_tmpVal" "$alrb_toolDir"
		    if [ $? -ne 0 ]; then
			return 64
		    fi
		fi
	    fi

	fi
    fi

    if [ "$ALRB_OSTYPE" = "Linux" ]; then
	alrb_result=`\echo $alrb_candVirtVersion | \sed -e 's|.*-*slc\([0-9]*\)-*.*|\1|g'  -e 's|.*-*centos\([0-9]*\)-*.*|\1|g'`
    elif [ "$ALRB_OSTYPE" = "MacOSX" ]; then
	alrb_result=`\echo $alrb_candVirtVersion | \sed -e 's|.*-macos10\([0-9]*\)-*.*|\1|g'`
    fi
    if [[ "$alrb_result" != "" ]] && [[ "$alrb_result" != "$alrb_candVirtVersion" ]]; then
	if [ $alrb_result -gt $ALRB_OSMAJORVER ]; then
	    \echo "Error: You are trying to setup version $alrb_candVirtVersion on $ALRB_OSTYPE $ALRB_OSMAJORVER"
	    \echo "       It was built for $ALRB_OSTYPE $alrb_result." 
	    alrb_candRealVersion=""
	    alrb_candVirtVersion=""
	    return 64
	fi
    fi

    return 0
}


alrb_fn_unrecognizedExtraArgs() 
{
    if [ $# -ne 0 ]; then
	\echo "Warning: Ignoring unrecognized args \"$*\"" 1>&2    
    fi
    return 0
}


alrb_fn_getInstallDir() 
{

    local alrb_tool=$1

    alrb_fn_sourceFunctions "$alrb_tool"
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_toolDir
    alrb_toolDir=`alrb_fn_getSynonymInfo "$alrb_tool" "dir"`
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_relativeDir
    alrb_relativeDir="$ATLAS_LOCAL_ROOT_ARCH/"    
    alrb_result=`type -t alrb_fn_${alrb_tool}GetRelativeDir`
    if [ $? -eq 0 ]; then
	alrb_relativeDir=`alrb_fn_${alrb_tool}GetRelativeDir`
    fi

    \echo "$ATLAS_LOCAL_ROOT_BASE/${alrb_relativeDir}$alrb_toolDir"

    return 0
}


alrb_fn_createReleaseMap() 
{

    local alrb_tool=$1

    alrb_fn_sourceFunctions "$alrb_tool" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_InstallDir
    alrb_InstallDir=`alrb_fn_getInstallDir "$alrb_tool"`
    if [ $? -ne 0 ]; then
	return 64
    fi

    if [ ! -d $alrb_InstallDir ]; then
# this may be normal - eg sft, lcgenv, java do not have installation dirs
	return 0
    fi

    if [ ! -d "$alrb_InstallDir/.alrb" ]; then
	\mkdir -p "$alrb_InstallDir/.alrb"
    fi

    local alrb_mapfile="$alrb_InstallDir/.alrb/mapfile.txt"
    local alrb_mapfileNew="$alrb_mapfile.new"
    \rm -f $alrb_mapfileNew
    touch $alrb_mapfileNew
    
    local alrb_installedFilesAr=( ".alrb/tag" "dummy.txt" "setup.sh" "bin" )
    local alrb_result
    alrb_result=`type -t alrb_fn_${alrb_tool}GetInstallDirAttributes`
    if [ $? -eq 0 ]; then
	alrb_installedFilesAr=( ${alrb_installedFilesAr[@]} `alrb_fn_${alrb_tool}GetInstallDirAttributes` )
    fi
    
    local alrb_installedVersionsAr=( `\find $alrb_InstallDir -maxdepth 1 -type d | \sed 's|.*/||g' | env LC_ALL=C \sort` )
    local alrb_symlinkAr=( `\find $alrb_InstallDir -maxdepth 1 -type l | \sed 's|.*/||g' | env LC_ALL=C \sort` )
    local alrb_installedVersion
    local alrb_installedFiles
    local alrb_symlink
    local alrb_virtDir
    for alrb_installedVersion in ${alrb_installedVersionsAr[@]}; do
	local alrb_tmpVal="$alrb_InstallDir/$alrb_installedVersion"
	for alrb_installedFiles in ${alrb_installedFilesAr[@]}; do
	    if [ -e $alrb_tmpVal/$alrb_installedFiles ]; then
		alrb_result=`type -t alrb_fn_${alrb_tool}GetVirtualDir`
		if [ $? -eq 0 ]; then
		    alrb_virtDir=`alrb_fn_${alrb_tool}GetVirtualDir $alrb_installedVersion`
		    if [ $? -ne 0 ]; then
			alrb_virtDir=$alrb_installedVersion
		    fi
		else
		    alrb_virtDir=$alrb_installedVersion
		fi
		alrb_result=`alrb_fn_versionConvert $alrb_tool $alrb_virtDir`
		if [ $? -ne 0 ]; then
		    alrb_result=""
		fi
		if [ -e "$alrb_tmpVal/.alrb/hide" ]; then
		    local alrb_listIt="$alrb_result|H|"
		else
		    
		    local alrb_listIt="$alrb_result|S|"
		fi
		local alrb_listIt="${alrb_listIt}${alrb_installedVersion}|$alrb_virtDir|"
		for alrb_symlink in ${alrb_symlinkAr[@]}; do
		    local alrb_realFile=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh --basename "$alrb_InstallDir/$alrb_symlink"`
		    if [ "$alrb_realFile" = "$alrb_installedVersion" ]; then
			alrb_listIt="${alrb_listIt}${alrb_symlink}|"
		    fi
		done
		\echo "$alrb_listIt" >> $alrb_mapfileNew
		break;
	    fi
	done
    done
    
    local alrb_updateIt="NO"
    if [[ -e $alrb_mapfileNew ]] && [[ -e $alrb_mapfile ]]; then
	alrb_result=`diff $alrb_mapfileNew $alrb_mapfile  2>&1`
	if [ $? -ne 0 ]; then
	    alrb_updateIt="YES"
	fi
    elif [ -e $alrb_mapfileNew ]; then
	alrb_updateIt="YES"
    fi 
    
    if [ "$alrb_updateIt" = "YES" ]; then
	\echo "Updating $alrb_mapfile .."
	if [ -e $alrb_mapfile ]; then
	    \cp $alrb_mapfile $alrb_mapfile.old
	fi
	\mv $alrb_mapfileNew $alrb_mapfile
    fi
    
    return 0
}


alrb_fn_installAction() 
{

    local alrb_returnCode=0

    if [[ "$alrb_InstallPlatform" != "$ATLAS_LOCAL_ROOT_ARCH" ]] && [[ "$alrb_InstallPlatform" != "any" ]]; then
	return 0
    fi

    alrb_fn_installCreateDefaultsAr
    if [ $? -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
	return 64
    fi

    alrb_fn_sourceFunctions "$alrb_Tool" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
	return 64
    fi

    local alrb_ToolDir
    alrb_ToolDir=`alrb_fn_getInstallDir "$alrb_Tool"`
    if [ $? -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
	return 64
    fi

    if [ ! -d $alrb_ToolDir ]; then
	\mkdir -p $alrb_ToolDir
	if [ $? -ne 0 ]; then
	    \echo "Error: ubable to create dir $alrb_ToolDir"
	    touch $ALRB_installTmpDir/toolInstallFailed
	    return 64
	fi	
    fi

    if [ ! -d "$alrb_ToolDir/.alrb" ]; then
	\mkdir -p "$alrb_ToolDir/.alrb"
	if [ $? -ne 0 ]; then
	    \echo "Error: ubable to create dir $alrb_ToolDir/.alrb"
	    touch $ALRB_installTmpDir/toolInstallFailed
	    return 64
	fi
    fi

    if [ "$alrb_InstallVersionVisible" = "" ]; then
	alrb_InstallVersionVisible=$alrb_InstallVersion
    fi
    local alrb_InstallDir="$alrb_ToolDir/$alrb_InstallVersionVisible"

    \echo "|$alrb_InstallVersionVisible|$alrb_InstallAction|" >> $ALRB_installTmpDir/$alrb_Tool-actions.txt

    if [[ "$alrb_installArchived" = "YES" ]] && [[ "$alrb_InstallAction" = "archive" ]]; then
	alrb_fn_doInstall
    elif [ "$alrb_InstallAction" = "install" ]; then
	alrb_fn_doInstall
    elif [ "$alrb_InstallAction" = "archive" ]; then
	alrb_fn_doArchive
    elif [ "$alrb_InstallAction" = "attic" ]; then
	alrb_fn_doAttic
    elif [ "$alrb_InstallAction" = "obsolete" ]; then
	alrb_fn_doObsolete
    elif [ "$alrb_InstallAction" = "remove" ]; then
	alrb_fn_doRemove
    else
	\echo "Error: Unknow install action for $alrb_Tool: $alrb_InstallAction"
	return 64
    fi
    alrb_returnCode=$?
    if [ $alrb_returnCode -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
    fi

    return $alrb_returnCode

}


alrb_fn_installFailure() 
{

    touch $ALRB_installTmpDir/toolInstallFailed    
    if [ "$alrb_InstallDir" != "" ]; then
	\rm -rf $alrb_InstallDir
    fi
    printf " %-70s \e[0;31m%6s\e[m\n" "$alrb_headerMsg" "FAILED"

    printf "      %-63s %6s\n" "$alrb_headerMsg" "FAILED" >> $ALRB_installTmpDir/toolInstallSummary

    return 64
}


alrb_fn_doInstall() 
{

    local let alrb_retCode=0

    local alrb_headerMsg="Install $alrb_Tool $alrb_InstallVersion"
    printf "\n \e[1;30m%-70s\e[m\n" "$alrb_headerMsg ..."

    local alrb_item
    local alrb_result
    if [ -e $alrb_ToolDir/.alrb/mapfile.txt ]; then
	alrb_result=`\grep -e "|$alrb_InstallVersionVisible|" $alrb_ToolDir/.alrb/mapfile.txt`
	if [ $? -eq 0 ]; then
	    local alrb_InstallDir="$alrb_ToolDir/`\echo $alrb_result | \cut -f 3 -d "|"`"
	    if [ -e $alrb_InstallDir/.alrb/tag ]; then
		local alrb_thisToolInstallTag=`\cat $alrb_InstallDir/.alrb/tag | \tail -n 1`
	    else
		local alrb_thisToolInstallTag=0
	    fi
	    if [ "$alrb_thisToolInstallTag" != "$alrb_ToolInstallTag" ]; then
		\echo "$alrb_InstallVersion will be reinstalled ..."
		\rm -rf $alrb_InstallDir
		local alrb_tmpAr=( `\echo $alrb_result | \cut -f 5- -d "|" | \sed -e 's/|/ /g'`)
		for alrb_item in "${alrb_tmpAr[@]}"; do
		    \rm -f $alrb_item
		done
	    else
		\echo "$alrb_InstallVersion exists, will skip."
		alrb_fn_installSetTags
		return 0
	    fi
	fi
    fi

    \rm -rf $alrb_InstallDir
    \mkdir -p $alrb_InstallDir
    if [ $? -ne 0 ]; then
	\echo "Error: could not create installation dir $alrb_InstallDir"
	alrb_fn_installFailure
	return 64
    fi

    cd $alrb_InstallDir

    alrb_result=`type -t alrb_fn_${alrb_Tool}DoInstall`
    if [ $? -eq 0 ]; then
	alrb_fn_${alrb_Tool}DoInstall 
    elif [ "$alrb_InstallPacmanDownload" != "" ]; then
	alrb_fn_pacmanInstall
    elif [ "$alrb_InstallTarballDownload" != "" ]; then
	alrb_fn_tarballInstall
    elif [ "$alrb_InstallWgetDownload" != "" ]; then
	alrb_fn_wgetInstall
    elif [ "$alrb_InstallLcgEnv" != "" ]; then
	alrb_fn_lcgenvInstall
    else
	\echo "Error: unspecified installation method for $alrb_Tool alrb_InstallVersionVisible"
	alrb_fn_installFailure
	return 64
    fi
    if [ $? -ne 0 ]; then
	alrb_fn_installFailure
	return 64
    fi

    if [ ! -e $alrb_InstallDir/.alrb/lcgenv ]; then
	alrb_result=`type -t alrb_fn_${alrb_Tool}PostInstall`
	if [ $? -eq 0 ]; then
	    alrb_fn_${alrb_Tool}PostInstall 
	    if [ $? -ne 0 ]; then
		alrb_fn_installFailure
		return 64
	    fi
	fi
    fi
        
    alrb_fn_installSetTags 
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi

    alrb_fn_relocateFileFix
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi

    for alrb_item in "${alrb_InstallPermissionAr[@]}"; do
	local alrb_file=`\echo $alrb_item | \cut -f 1 -d ":"`
	local alrb_filemode=`\echo $alrb_item | \cut -f 2 -d ":"`
	if [ -e $alrb_InstallDir/$alrb_file ]; then
	    chmod $alrb_filemode $alrb_InstallDir/$alrb_file
	else
	    \echo "Error: $alrb_InstallDir/$alrb_file misisng for chmod"
	    let alrb_retCode=64
	fi
    done

    cd $alrb_ToolDir
    for alrb_item in "${alrb_InstallAlternateNames[@]}"; do
	\rm -f $alrb_item
	ln -s $alrb_InstallVersionVisible $alrb_item
    done

    local alrb_relativePath=${alrb_InstallDir#$ATLAS_LOCAL_ROOT_BASE/}
    local alrb_timestamp=`date +%Y%b%d\ %H:%M`
    \echo -e "$alrb_timestamp\t$alrb_relativePath\t$alrb_InstallVersionVisible" >> $ATLAS_LOCAL_ROOT_BASE/logDir/installed

    printf " %-70s \e[0;32m%6s\n\e[m" "$alrb_headerMsg" "OK"

    printf "      %-63s %6s\n" "$alrb_headerMsg" "OK" >> $ALRB_installTmpDir/toolInstallSummary

    return $alrb_retCode
    
}


alrb_fn_doArchive() 
{

# do nothing for archiving 
    return 0
}


alrb_fn_doAttic() 
{

# do nothing for attic
    return 0
}


alrb_fn_doObsolete() 
{

    local alrb_headerMsg="Obsolete $alrb_Tool $alrb_InstallVersion"
    
    local alrb_item
    local alrb_result
    if [ -e $alrb_ToolDir/.alrb/mapfile.txt ]; then
	alrb_result=`\grep -e "|$alrb_InstallVersionVisible|" $alrb_ToolDir/.alrb/mapfile.txt`
	if [ $? -eq 0 ]; then	    
	    local alrb_InstallDir="$alrb_ToolDir/`\echo $alrb_result | \cut -f 3 -d "|"`"
	    if [ ! -e $alrb_InstallDir/.alrb/obsolete ]; then	    
		printf "\n \e[1;30m%-70s\e[m\n" "$alrb_headerMsg ..."
		alrb_fn_installSetTags 
	    
		local alrb_relativePath=${alrb_InstallDir#$ATLAS_LOCAL_ROOT_BASE/}
		local alrb_timestamp=`date +%Y%b%d\ %H:%M`
		\echo -e "$alrb_timestamp\t$alrb_relativePath\t$alrb_InstallVersionVisible (obsolete)" >> $ATLAS_LOCAL_ROOT_BASE/logDir/installed
		
		printf " %-70s \e[0;32m%6s\n\e[m" "$alrb_headerMsg" "OK"
		
		printf "      %-63s %6s\n" "$alrb_headerMsg" "OK" >> $ALRB_installTmpDir/toolInstallSummary
	    fi
	fi
    fi
    
    return 0    
}


alrb_fn_doRemove() 
{

    local alrb_headerMsg="Remove $alrb_Tool $alrb_InstallVersion"
    
    local alrb_item
    local alrb_result
    if [ -e $alrb_ToolDir/.alrb/mapfile.txt ]; then
	alrb_result=`\grep -e "|$alrb_InstallVersionVisible|" $alrb_ToolDir/.alrb/mapfile.txt`
	if [ $? -eq 0 ]; then
	    printf "\n \e[1;30m%-70s\e[m\n" "$alrb_headerMsg ..."
	    
	    local alrb_InstallDir="$alrb_ToolDir/`\echo $alrb_result | \cut -f 3 -d "|"`"

	    local alrb_tmpAr=( `\echo $alrb_result | \cut -f 5- -d "|" | \sed -e 's/|/ /g'`)
	    for alrb_item in "${alrb_tmpAr[@]}"; do
		\rm -f $alrb_item
	    done

	    alrb_result=`type -t alrb_fn_${alrb_Tool}PreRemove`
	    if [ $? -eq 0 ]; then
		alrb_fn_${alrb_Tool}PreRemove
	    fi	   	    
	    \rm -rf $alrb_InstallDir

	    local alrb_relativePath=${alrb_InstallDir#$ATLAS_LOCAL_ROOT_BASE/}
	    local alrb_timestamp=`date +%Y%b%d\ %H:%M`
	    \echo -e "$alrb_timestamp\t$alrb_relativePath\t$alrb_InstallVersionVisible (remove)" >> $ATLAS_LOCAL_ROOT_BASE/logDir/installed
	    
	    printf " %-70s \e[0;32m%6s\n\e[m" "$alrb_headerMsg" "OK"
	    
	    printf "      %-63s %6s\n" "$alrb_headerMsg" "OK" >> $ALRB_installTmpDir/toolInstallSummary
	fi
    fi
    
    return 0    
}


alrb_fn_installSetTags() 
{

    cd $alrb_InstallDir
    \mkdir -p $alrb_InstallDir/.alrb
    if [ ! -e $alrb_InstallDir/.alrb/tag ]; then
	\echo $alrb_ToolInstallTag >> $alrb_InstallDir/.alrb/tag
    fi
    if [[ "$alrb_InstallAction" = "obsolete" ]] && [[ ! -e $alrb_InstallDir/.alrb/obsolete ]]; then
	touch $alrb_InstallDir/.alrb/obsolete
    else
	\rm -f $alrb_InstallDir/.alrb/obsolete
    fi

    return 0
}


alrb_fn_pacmanInstall() 
{

    cd $alrb_InstallDir
    if [ ! -e $ATLAS_LOCAL_ROOT_BASE/${ATLAS_LOCAL_ROOT_ARCH}/Pacman/current/setup.sh ]; then
	\echo "Error: could not find pacman"
	return 64
    else
	source $ATLAS_LOCAL_ROOT_BASE/${ATLAS_LOCAL_ROOT_ARCH}/Pacman/current/setup.sh
	if [ $? -ne 0 ]; then
	    \echo "Error: Failed to setup pacman"
	    return 64
	fi
    fi

    yes | pacman $alrb_InstallPacmanOptions -get "$alrb_InstallPacmanMirror:$alrb_InstallPacmanDownload"
    if [ $? -ne 0 ]; then
	\echo "Error: pacman could not install $alrb_InstallPacmanDownload"
	return 64
    fi
    
    return 0
}


alrb_fn_tarballInstall() 
{
    
    cd $alrb_InstallDir
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_InstallTarballDownload
    if [ $? -ne 0 ]; then
	\echo "Error: unable to download $alrb_InstallTarballDownload"
	return 64
    fi
    
    local alrb_filename=`\echo $alrb_InstallTarballDownload | rev | \cut -f 1 -d "/" | rev`
    if [[ "$alrb_filename" =~ .*.tgz$ ]] || [[ "$alrb_filename" =~ .*.tar.gz$ ]]; then
	tar zxf $alrb_filename $alrb_InstallTarballOptions
    elif [[ "$alrb_filename" =~ ".tar" ]];then
	tar xf $alrb_filename $alrb_InstallTarballOptions
    else
	\echo "Error: do not know how to unpack $alrb_filename"
	return 64
    fi
    if [ $? -ne 0 ]; then
	\echo "Error: unable to expand the file $alrb_filename"
	return 64
    else
	\rm -f $alrb_filename
    fi
    
    return 0
}


alrb_fn_wgetInstall() 
{
    
    cd $alrb_InstallDir
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_InstallWgetDownload
    if [ $? -ne 0 ]; then
	\echo "Error: unable to fetch file $alrb_InstallWgetDownload"
	return 64
    fi
    
    return 0
}


alrb_fn_lcgenvInstall()
{
    
    cd $alrb_InstallDir

    \cat << EOF >> setup.sh 
if [ "\$alrb_Quiet" = "NO" ]; then
  \echo "  ROOT is from lcgenv $alrb_InstallLcgEnv"
fi
lsetup "lcgenv $alrb_InstallLcgEnv" -q
return \$?
EOF

    \cat << EOF >> setup.csh 
if ( "\$alrb_Quiet" == "NO" ) then
  \echo "  ROOT is from lcgenv $alrb_InstallLcgEnv"
endif
lsetup "lcgenv $alrb_InstallLcgEnv" -q
exit \$?
EOF
    
    mkdir -p .alrb
    touch .alrb/lcgenv

    return 0
}


alrb_fn_relocateFileFix() 
{
    
    cd $alrb_InstallDir
    local alrb_toFix
    for alrb_toFix in ${alrb_InstallRelocateFilesAr[@]}; do
	if [ -e $alrb_toFix ]; then
	    \rm -f $alrb_toFix.relocate
	    \sed -e 's|'$ATLAS_LOCAL_ROOT_BASE'|\$ATLAS_LOCAL_ROOT_BASE|g' $alrb_toFix > $alrb_toFix.relocate
	fi
    done
    
    return 0
}


alrb_fn_installCreateDefaultsAr() 
{
    
    alrb_SetDefaultsAr=(
	"$alrb_InstallDefault:current"
	"$alrb_InstallTesting:testing"
	"$alrb_InstallDefaultSL5:current-SL5"
	"$alrb_InstallDefaultSL6:current-SL6"
	"$alrb_InstallDefaultSL7:current-SL7"
	"$alrb_InstallDefaultMacOS11:current-MacOS11"
	"$alrb_InstallDefaultMacOS12:current-MacOS12"
	"$alrb_InstallTestingSL5:testing-SL5"
	"$alrb_InstallTestingSL6:testing-SL6"
	"$alrb_InstallTestingSL7:testing-SL7"
	"$alrb_InstallTestingMacOS11:testing-MacOS11"
	"$alrb_InstallTestingMacOS12:testing-MacOS12"
	"$alrb_InstallRecommended:recommended"
	"$alrb_InstallRecommendedSL6:recommended-SL6"
	"$alrb_InstallRecommendedSL7:recommended-SL7"
    )

    return 0
}
    

alrb_fn_installSetDefaults() 
{

    local alrb_tool=$1
    local alrb_toolDir=`alrb_fn_getInstallDir "$alrb_tool"`
    if [ $? -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
	return 64
    fi
    cd $alrb_toolDir
        
    local alrb_item
    for alrb_item in ${alrb_SetDefaultsAr[@]}; do
	local alrb_version=`\echo $alrb_item | \cut -f 1 -d ":"`
	local alrb_link=`\echo $alrb_item | \cut -f 2 -d ":"`
	if [ "$alrb_version" != "" ]; then
	    if [ -d $alrb_version ]; then
		\rm -f $alrb_link
		ln -s $alrb_version $alrb_link
	    else
		if [[ "$alrb_link" =~ "SL" ]] && [[ "$ALRB_OSTYPE" != "Linux" ]]; then
		    continue
		elif  [[ "$alrb_link" =~ "MacOS" ]] && [[ "$ALRB_OSTYPE" != "MacOSX" ]]; then
		    continue
		else
		    \echo "Error: version $alrb_version not found for $alrb_link"
		    touch $ALRB_installTmpDir/toolInstallFailed
		fi
	    fi	    
	else
	    \rm -f $alrb_link
	fi
    done
	
    return 0
}


alrb_fn_cleanToolDir() 
{

    local alrb_tool=$1
    local alrb_toolDir=`alrb_fn_getInstallDir "$alrb_tool"`
    if [ $? -ne 0 ]; then
	touch $ALRB_installTmpDir/toolInstallFailed
	return 64
    fi
    cd $alrb_toolDir

    local alrb_result
    if [ -e .alrb/mapfile.txt ]; then
	local alrb_item
	local alrb_contentAr=( `\find . -maxdepth 1  | rev | \cut -f 1 -d "/" | rev | \egrep -v "^\."` )
	for alrb_item in ${alrb_contentAr[@]}; do
	    local alrb_installDir=`\grep  -e "|$alrb_item|" .alrb/mapfile.txt | \cut -f 3 -d "|"`
	    if [ "$alrb_installDir" != "" ]; then
		alrb_result=`\grep -e "|$alrb_installDir|" $ALRB_installTmpDir/$alrb_tool-actions.txt 2>&1`
		if [ $? -ne 0 ]; then
		    \echo "$alrb_toolDir/$alrb_item" >> $ALRB_installTmpDir/installDirCleanup.txt		    
		fi
	    else
		\echo "$alrb_toolDir/$alrb_item" >> $ALRB_installTmpDir/installDirCleanup.txt		    
	    fi
	done
    else
	\echo "Error: mapfile not found for $alrb_tool"
	return 64
    fi

    return 0
}


alrb_fn_useNativeVersion() 
{
    local alrb_standard=$1
    local alrb_checkString=$2

    local alrb_result
    if [[ "$ALRB_OSTYPE" = "Linux" ]] && [[ "$alrb_standard" = "CPP14" ]]; then
# c++14 standard is unavailable for =< RHEL7 native compilers or gcc =< 5
	if [ "$ALRB_OSMAJORVER" -le 7 ]; then
	    alrb_result=`\echo $alrb_checkString | \grep -e "gcc[6-9]"`
	    if [ $? -eq 0 ]; then
		return 1
	    fi
	fi
    fi

    return 0
}