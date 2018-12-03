#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! createLcgArea.sh
#!
#! Creates a lcgarea dir structure for asetup
#!
#! Usage: 
#!      createLcgArea.sh --help
#!
#! History:
#!   21Mar12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=createLcgArea.sh


#!----------------------------------------------------------------------------
alrb_fn_createLcgAreaHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage:  createLcgArea.sh [options]

    This application will create a .lcgarea dir for asetup

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --force                  Recreate the file / dir

EOF
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------
 
alrb_shortopts="h" 
alrb_longopts="help,force"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_recreate="NO";

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_createLcgAreaHelp
            exit 0
            ;;
	--force)
	    alrb_recreate="YES"
	    shift
	    break
	    ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

if [ -z $ATLAS_LOCAL_ROOT_BASE ]
then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/parseVersionVar.sh 

alrb_hiddenLcgDir="$ATLAS_LOCAL_ROOT/.lcgarea"
if [ ! -d $alrb_hiddenLcgDir ]; then
    mkdir -p $alrb_hiddenLcgDir
fi
cd $alrb_hiddenLcgDir
if [ $? -ne 0 ]; then
    \echo "Error: Unable to cd to $alrb_hiddenLcgDir ";
    exit 64
fi

# remove obsolete paths ...
\rm -rf $alrb_hiddenLcgDir/lcg/app
\rm -rf $alrb_hiddenLcgDir/lcg/contrib


# python
if [ -d $alrb_hiddenLcgDir/lcg/external/Python ]; then
    alrb_myCmd="\find $alrb_hiddenLcgDir/lcg/external/Python -mindepth 1 -maxdepth 1 -type d"
    alrb_releaseVersionAr=( `eval $alrb_myCmd` )
    for alrb_relVersion in ${alrb_releaseVersionAr[@]}; do
	alrb_myCmd="\find $alrb_relVersion -type l"
	alrb_dirListAr=( `eval $alrb_myCmd` )
	let alrb_count=${#alrb_dirListAr[@]}
	for alrb_theDir in ${alrb_dirListAr[@]}; do
	    $ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_theDir 2>&1 > /dev/null
	    if [ $? -ne 0 ]; then
		\rm $alrb_theDir
		let alrb_count=$alrb_count-1
	    fi
	done
	if [ $alrb_count -eq 0 ]; then
	    \rmdir $alrb_relVersion
	fi
    done
fi
if [ -e $ATLAS_LOCAL_ROOT/python/.alrb/mapfile.txt ]; then
    alrb_releaseVersionAr=( `\cat $ATLAS_LOCAL_ROOT/python/.alrb/mapfile.txt | \cut -f 3 -d "|"` )
else
    alrb_releaseVersionAr=()
fi
for alrb_relVersion in ${alrb_releaseVersionAr[@]}; do
    alrb_pyVer=`\echo $alrb_relVersion | \cut -f 1 -d "-"`
    alrb_topDir="$alrb_hiddenLcgDir/lcg/external/Python/$alrb_pyVer"
    mkdir -p $alrb_topDir
    alrb_myCmd="\find  $ATLAS_LOCAL_ROOT/python/$alrb_relVersion -name bin -type d"
    alrb_dirListAr=( `eval $alrb_myCmd` )
    for alrb_theDir in ${alrb_dirListAr[@]}; do
	alrb_pyDir=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh "$alrb_theDir/.."`
	alrb_cmtconfig=`\echo $alrb_pyDir | \sed 's/.*\/\(.*\)/\1/g'`
	# remove absolute paths
	alrb_pyDir=`\echo $alrb_pyDir | \sed -e 's|'$ATLAS_LOCAL_ROOT_BASE'|../../../../../..|g'`
	if [ -h "$alrb_topDir/$alrb_cmtconfig" ]; then
	    # need to use readlink here to see relative path
	    alrb_result=`readlink $alrb_topDir/$alrb_cmtconfig`
	    if [ "$alrb_result" != "$alrb_pyDir" ]; then
		\rm -f $alrb_topDir/$alrb_cmtconfig
	    fi
	fi
	if [ ! -h "$alrb_topDir/$alrb_cmtconfig" ]; then
	    cd $alrb_topDir
	    ln -s $alrb_pyDir
	fi
    done
done


#cmt
if [ -d $alrb_hiddenLcgDir/contrib/CMT ]; then
    alrb_myCmd="\find $alrb_hiddenLcgDir/contrib/CMT -mindepth 1 -maxdepth 1 -type l"
    alrb_dirListAr=( `eval $alrb_myCmd` )
    let alrb_count=${#alrb_dirListAr[@]}
    for alrb_theDir in ${alrb_dirListAr[@]}; do
	$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_theDir 2>&1 > /dev/null
	if [ $? -ne 0 ]; then
	    \rm $alrb_theDir
	    let alrb_count=$alrb_count-1
	fi
    done
    if [ $alrb_count -eq 0 ]; then
	\rmdir $alrb_relVersion
    fi
fi
if [ -e $ATLAS_LOCAL_ROOT/CMT/.alrb/mapfile.txt ]; then
    alrb_releaseVersionAr=( `\cat $ATLAS_LOCAL_ROOT/CMT/.alrb/mapfile.txt | \cut -f 3 -d "|"` )
    alrb_topDir="$alrb_hiddenLcgDir/contrib/CMT"
    mkdir -p $alrb_topDir
else
    alrb_releaseVersionAr=( )
fi
for alrb_relVersion in ${alrb_releaseVersionAr[@]}; do
    # remove absolute paths
    if [ -h "$alrb_topDir/$alrb_relVersion" ]; then
	# need to use readlink here to see relative path
	alrb_result=`readlink $alrb_topDir/$alrb_relVersion`
	if [ "$alrb_result" = "$ATLAS_LOCAL_ROOT/CMT/$alrb_relVersion/CMT/$alrb_relVersion" ]; then
	    \rm -f $alrb_topDir/$alrb_relVersion
	fi
    fi
    if [ ! -h "$alrb_topDir/$alrb_relVersion" ]; then
	cd $alrb_topDir
	ln -s ../../../CMT/$alrb_relVersion/CMT/$alrb_relVersion $alrb_relVersion
    fi
done

  
exit 0


