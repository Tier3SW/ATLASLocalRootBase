#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functionsfor root
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------


alrb_fn_rootHelp()
{
    \cat <<EOF

Usage: lsetup [global options] "${alrb_sw} [options] <version>"

    This sets up the ATLAS environment for root

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    

    Options (to override defaults) are:
EOF
    alrb_fn_glocalSetupHelp
    ${ATLAS_LOCAL_ROOT_BASE}/swConfig/showVersions.sh $alrb_sw

}


alrb_fn_rootVersionConvert()
{
# 3 significant figures 
    local alrb_tmpVal=`\echo $1 | \cut -f 1 -d "-" | \sed -e 's/\([0-9\.]*\).*/\1/g'`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 3
    return $?
}


alrb_fn_rootDepend()
{
    local alrb_sw="root"
    local alrb_progname="alrb_fn_${alrb_sw}Depend"

    local alrb_swDir
    alrb_swDir=`alrb_fn_getSynonymInfo "$alrb_sw" dir`
    if [ $? -ne 0 ]; then
	return 64
    fi
    
    local alrb_shortopts="h,q,s,f,c:,d:,x:"
    local alrb_longopts="help,${alrb_sw}Version:,quiet,skipConfirm,force,xrdVer:,davixVer:"
    local alrb_opts
    local alrb_result
    alrb_result=`getopt -T >/dev/null 2>&1`
    if [ $? -eq 4 ] ; then # New longopts getopt.
	alrb_opts=$(getopt -o $alrb_shortopts --long $alrb_longopts -n "$alrb_progname" -- "$@")
	local alrb_returnVal=$?
    else # use wrapper
	alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_getopt.py $alrb_shortopts $alrb_longopts $*`
	local alrb_returnVal=$?
    fi
    
# do we have an error here ?
    if [ $alrb_returnVal -ne 0 ]; then
	\echo $alrb_opts 1>&2
	\echo "'lsetup \"$alrb_sw --help\"' for more information" 1>&2
	return 1
    fi
    
    eval set -- "$alrb_opts"
    
    local alrb_caller="unknown"
    if [ ! -z $ALRB_rootVersion ]; then
	local alrb_swVersion=$ALRB_rootVersion
    else
	local alrb_swVersion="dynamic"
    fi
    local alrb_rootXrdVer="rootconfig"
    local alrb_rootDavixVer="dynamic"
    
    while [ $# -gt 0 ]; do
	: debug: $1
	case $1 in
            -h|--help)
		alrb_fn_rootHelp
		return 0
		;;
            --${alrb_sw}Version)
                local alrb_swVersion=$2
		shift 2
		;;
            -c|--caller)
		local alrb_caller=$2
		shift 2
		;;
	    -q|--quiet)	    
# backward compatibility
	        alrb_Quiet="YES"
		shift
		;;
	    -s|--skipConfirm)	    
		shift
		;;
	    -f|--force)    
		shift
		;;
            -x|--xrdVer)
	        \echo "Warning: --xrdVer is depreciated.  Use lsetup instead."
		local alrb_rootXrdVer=$2
		shift 2
		;;
	    -d|--davixVer)
	        \echo "Warning: --davixVer is depreciated.  Use lsetup instead."
		local alrb_rootDavixVer=$2
		shift 2
		;;	
            --)
		shift
		break
		;;
            *)
		\echo "Internal Error: option processing error: $1" 1>&2
		return 1
		;;
	esac
    done
    
    if [ $# -ge 1 ]; then
	local alrb_swVersion=$1
	shift
	alrb_fn_unrecognizedExtraArgs "$@"
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi
    
    if [ "$alrb_swVersion" = "" ]; then
	\echo "Error: ${alrb_sw} version not specified" 1>&2
	return 64
    fi

    local alrb_candRealVersion=""
    local alrb_candVirtVersion=""
    alrb_fn_getToolVersion "$alrb_sw" "$alrb_swVersion" "alrb_slc:alrb_arch:alrb_firstVer"
    if [ $? -ne 0 ]; then
	return 64
    fi
    local alrb_setVer="$alrb_candVirtVersion"
    local alrb_rootRealVersion="$alrb_candRealVersion"
    local alrb_rootVirtVersion="$alrb_candVirtVersion"
    
    if [ "$alrb_setVer" != "" ]; then
	alrb_fn_versionChecker "$alrb_sw" "$alrb_caller" "$alrb_setVer" -c "$alrb_swVersion"
	if [ $? -ne 0 ]; then
	    return 64
	else
	    alrb_fn_parseVersionVar "$alrb_rootVirtVersion"
	    alrb_root_extra="$alrb_root_extra,rVer=$alrb_rootRealVersion,cmt=${alrb_arch}-${alrb_slc}-${alrb_gcc}-opt,"
	    
# dependencies
	    alrb_fn_doOverrides "$alrb_sw" "$alrb_setVer" "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi

# nothing else to do if redirecting to lcgenv
	    if [ -e $ATLAS_LOCAL_ROOT/root/$alrb_rootRealVersion/.alrb/lcgenv ]; then
		return 0
	    fi
	    
# gcc
	    local alrb_gccRoot=$alrb_rootVirtVersion
	    local alrb_gccRootClient="$alrb_sw"
	    if [ -e $ATLAS_LOCAL_ROOT/root/$alrb_rootRealVersion/rpmRequired.txt ]; then
		alrb_result=`\grep -e gcc_ $ATLAS_LOCAL_ROOT/root/$alrb_rootRealVersion/rpmRequired.txt | \cut -f 2 -d "_" | \sed -e 's/\.//g'`
		if [ "$alrb_result" != "" ]; then
		    alrb_gccRoot=`\echo $alrb_rootVirtVersion | \sed -e 's/-gcc\([0-9]\{2,3\}\)-/-gcc'$alrb_result'-/g'`
		    local alrb_gccRootClient="${alrb_sw}:anchor"
		fi
	    fi

	    alrb_fn_depend gcc "$alrb_gccRoot" -c "$alrb_gccRootClient"
	    if [ $? -ne 0 ]; then
		return 64
	    fi
	    
# python
	    local alrb_tmpVal=`${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/bin/root-config --python-version`
	    alrb_fn_depend python "python${alrb_tmpVal}-$alrb_rootVirtVersion" -c "$alrb_sw"
	    if [ $? -ne 0 ]; then
		return 64
	    fi
	    
# gccxml
	    local alrb_tmpVal=`${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/bin/root-config --config | \grep "with-gccxml" | \sed -e 's|.*gccxml/\([^/]*\)/.*|\1|g'`
	    local alrb_tmpVal=`\echo $alrb_tmpVal | \sed -e 's/ //g' `
	    if [ "$alrb_tmpVal" != "" ]; then
		alrb_fn_depend gccxml "gccxml${alrb_tmpVal}-$alrb_rootVirtVersion" -c "$alrb_sw"
		if [ $? -ne 0 ]; then
		    return 64
		fi
	    fi
	    
# gsl
	    if [ -e ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt ]; then
		local alrb_tmpVal=`\grep -i gsl ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt  | \cut -f 2 -d "_"`
		if [ "$alrb_tmpVal" != "" ]; then
		alrb_fn_depend gsl "gsl${alrb_tmpVal}-$alrb_rootVirtVersion"  -c "$alrb_sw"
		    if [ $? -ne 0 ]; then
			return 64
		    fi
		fi
	    fi
	    
# fftw
	    if [ -e ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt ]; then
		local alrb_tmpVal=`\grep -i fftw ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt  | \cut -f 2 -d "_"`
		if [ "$alrb_tmpVal" != "" ]; then
		    alrb_fn_depend fftw "fftw${alrb_tmpVal}-$alrb_rootVirtVersion" -c "$alrb_sw"
		    if [ $? -ne 0 ]; then
			return 64
		    fi
		fi
	    fi
	    
# tbb
	    if [ -e ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt ]; then
		local alrb_tmpVal=`\grep -i tbb ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt  | \cut -f 2-3 -d "_"`
		if [ "$alrb_tmpVal" != "" ]; then
		    alrb_fn_depend tbb "tbb${alrb_tmpVal}-$alrb_rootVirtVersion" -c "$alrb_sw"
		    if [ $? -ne 0 ]; then
			return 64
		    fi
		fi
	    fi	    

# xrootd
# root 5.32 and newer has xrootd in external package	    
	    local alrb_rootXrdMinVer=""
# non-cmake root versions
	    if [ "$alrb_rootXrdMinVer" = "" ]; then
		local alrb_tmpVal=`${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/bin/root-config --config | \grep -e "with-xrootd"`	
		if [ $? -eq 0 ]; then
		    alrb_rootXrdMinVer=`\echo $alrb_tmpVal | \sed -e 's/.*xrootd\/\([0-9\.]*\).*\/.*/\1/g'`    
		fi
	    fi
# from rpm required file
	    if [[ "$alrb_rootXrdMinVer" = "" ]] && [[ -e "${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt" ]]; then
		local alrb_tmpVal=`\grep -i xrootd  ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt | \cut -f 2 -d "_"`
		if  [ "$alrb_tmpVal" != "" ]; then
		    alrb_rootXrdMinVer=$alrb_tmpVal
		fi
	    fi
# fall back cmake file (old artifact)
	    if [[ "$alrb_rootXrdMinVer" = "" ]] && [[ -e "${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/cmake/modules/SearchInstalledSoftware.cmake" ]]; then
		local alrb_tmpVal
		alrb_tmpVal=`\grep -e "set(xrootd_version " ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/cmake/modules/SearchInstalledSoftware.cmake | \sed -e 's/.*xrootd_version //g' -e 's/)//g'`
		if [ $? -eq 0 ]; then
		    alrb_rootXrdMinVer=$alrb_tmpVal
		fi
	    fi
	    if [[ "$alrb_rootXrdMinVer" != "" ]] && [[ -e ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/bin/setxrd.sh ]]; then
		alrb_fn_versionChecker xrootd "$alrb_sw" "$alrb_rootXrdMinVer" -c "$alrb_rootXrdMinVer"
		if [[ "$alrb_rootXrdVer" = "rootconfig" ]] || [[ "$alrb_rootXrdVer" = "dynamic" ]]; then
		    local alrb_rootXrdVer=xrootd${alrb_rootXrdMinVer}-${alrb_rootVirtVersion} 
		fi
		alrb_fn_depend xrootd "$alrb_rootXrdVer" -c "$alrb_sw"
		if [ $? -ne 0 ]; then
		    return 64
		fi
	    fi
	    alrb_root_extra="$alrb_root_extra,xrdMin=$alrb_rootXrdMinVer,"
	    
# davix
# always use the latest davix unless overwritten
# exception is if native version is incompatible
	    if [ -e "${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt" ]; then
		local alrb_tmpVal=`\grep -i davix  ${ATLAS_LOCAL_ROOT}/root/${alrb_rootRealVersion}/rpmRequired.txt | \cut -f 2 -d "_"`
		if  [ "$alrb_tmpVal" != "" ]; then
		    alrb_fn_useNativeVersion "CPP14" "$alrb_setVer"
		    if [ $? -ne 0 ]; then
			alrb_fn_depend davix davix${alrb_tmpVal}-${alrb_setVer} -c "$alrb_sw"
		    else
			alrb_fn_depend davix "$alrb_rootDavixVer" -c "$alrb_sw"
		    fi
		    if [ $? -ne 0 ]; then
			return 64
		    fi	    
		fi	
	    fi
	    
	    return 0
	fi
    else
	\echo "Error: root version undetermined or unavailable $alrb_swVersion" 1>&2
	return 64
    fi
    
}
    

alrb_fn_rootGetVirtualDir()
{
    local alrb_version=$1

    # fix old style names (only for 64-bit OS since 32-bit is obsolete)
    alrb_version=`\echo $alrb_version | \sed -e 's|5.28.00g-slc5-gcc4.3-i686$|5.28.00g-i686-slc5-gcc43-opt|g'`
    alrb_version=`\echo $alrb_version | \sed -e 's|5.28.00g-slc5-gcc4.3$|5.28.00g-x86_64-slc5-gcc43-opt|g'`
    alrb_version=`\echo $alrb_version | \sed -e 's|-gcc4\.\([0-9]\)$|-gcc4\1-opt|g'`

    \echo $alrb_version

    return 0
}

alrb_fn_rootPostInstall()
{

    local alrb_result

    \mv $alrb_InstallDir $alrb_InstallDir.tmp
    cd $alrb_InstallDir.tmp
    \mkdir -p $alrb_InstallDir
    alrb_result=`\find . -name root-config | \head -n 1 | \sed 's|/bin/root-con\
fig||g'`
    \mv $alrb_result/*  $alrb_InstallDir/
    cd $alrb_InstallDir
    \rm -rf $alrb_InstallDir.tmp

# fix gccxml 
    if [ -e "$alrb_InstallDir/lib/python/genreflex/gccxmlpath.py" ]; then
	alrb_result=`\grep -e "^gccxmlpath" $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py | \grep -e "GCCXML_EXECUTABLE-NOTFOUND" 2>&1` 
	if [ $? -eq 0 ]; then
	    \echo " Fixing bad gccxml path ..."
	    \sed -e 's|GCCXML_EXECUTABLE-NOTFOUND||g' $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py > $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py.new
	    if [ $? -eq 0 ]; then
		\mv $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py.original
		\mv $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py.new $alrb_InstallDir/lib/python/genreflex/gccxmlpath.py
	    fi
	fi
    fi    
    
    return 0
}