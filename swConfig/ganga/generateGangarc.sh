#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! generateGangarc.sh
#!
#! This script generates a new .gangarc file
#!
#! Usage: 
#!     generateGangarc.sh --help
#!
#! History:
#!   19Mar09: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname="generateGangarc.sh"

#!----------------------------------------------------------------------------
alrb_fn_generateGangaRcHelp()
# Simple help to stdout
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: $alrb_progname [options]

    This script generates a .gangarc file

    Options (to override defaults) are:
    -h  --help                 Print this help message
    --outDir=STRING            Output directory (default: \$HOME)
    --outFilename=STRING       Output file name (default: .gangarc)
    --voms=STRING              Voms (default: atlas); you will want 
                                 eg. atlas:/atlas/ca 
    --gangadir=STRING          PARENT of gangadir (default: \$HOME)

EOF
}

alrb_shortopts="h"
alrb_longopts="help,outDir:,outFilename:,voms:,gangadir:"
alrb_result=`getopt -T >/dev/null 2>&1`
if [ $? = 4 ] ; then # New longopts getopt.
    alrb_opts=$(getopt -o $alrb_shortopts --long $alrb_longopts -n "$alrb_progname" -- "$@")
    alrb_returnVal=$?
else # use wrapper
    alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_getopt.py $alrb_shortopts $alrb_longopts $*`
    alrb_returnVal=$?
    if [ $alrb_returnVal -ne 0 ]; then
	\echo $alrb_opts
    fi
fi

# do we have an error here ?
if [ $alrb_returnVal -ne 0 ]; then
    \echo $alrb_opts 1>&2
    \echo "'$alrb_progname --help' for more information" 1>&2
    exit 1
fi

eval set -- "$alrb_opts"

alrb_outDir="$HOME"
alrb_outFilename=".gangarc"
alrb_voms="atlas"
alrb_gangaDir="$HOME"
while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_generateGangaRcHelp
            exit 0
            ;;
        --outDir)
            alrb_outDir=$2
	    alrb_outDir=${alrb_outDir/\~/$HOME}
            shift 2
            ;;
        --outFilename)
            alrb_outFilename=$2
            shift 2
            ;;
        --voms)
            alrb_voms=$2
            shift 2
            ;;
        --gangadir)
            alrb_gangaDir=$2
            shift 2
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


# do everything in a sub-shell to avoid contaminating
(
    if [  -z $ATLAS_LOCAL_ROOT_BASE ]; then
	\echo "Error: Missing \$ATLAS_LOCAL_ROOT_BASE environment" 1>&2
	return 64
    fi

    alrb_gangaVersion=""
    if [ ! -z $ATLAS_LOCAL_GANGA_VERSION ]; then
	alrb_gangaVersion="--gangaVersion=$ATLAS_LOCAL_GANGA_VERSION"
    fi
    source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh --quiet
    source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh  --quiet "ganga --skipGangaRcCheck $alrb_gangaVersion"    
    
    \mkdir -p $alrb_outDir
    if [ $? -ne 0 ]; then
	\echo "Error: Cannot create $alrb_outDir" 1>&2
	exit 54
    fi

    alrn_oldFile=$HOME/.gangarc.`date '+%s'`.old
    if [ -e $HOME/.gangarc ]; then
	\cp $HOME/.gangarc $alrn_oldFile
    fi

    alrb_addOpts=" -o[LCG]EDG_ENABLE=False -o[LCG]GLITE_ENABLE=False"
    ganga -g --very-quiet $alrb_addOpts
    if [ $? -ne 0 ]; then
	exit 64
    fi

    \mv $HOME/.gangarc $HOME/.gangarc.original
    alrb_newFile="$alrb_outDir/$alrb_outFilename"
    if [ "$alrb_newFile" != "$HOME/.gangarc" ]; then
	if [ -e $alrn_oldFile ]; then
	    \cp $alrn_oldFile $HOME/.gangarc
	fi
    fi

    \rm -f $alrb_newFile

    \sed -e 's|^[# ]*RUNTIME_PATH[ ]*=.*|RUNTIME_PATH = GangaAtlas:GangaPanda|g' \
	-e 's|^[# ]*EDG_SETUP[ ]*=.*|EDG_SETUP ='"$ATLAS_LOCAL_ROOT_BASE"'/user/gangaGridSetup.sh|g' \
	-e 's|^[# ]*GLITE_ENABLE[ ]*=.*|GLITE_ENABLE = True|g' \
	-e 's|^[# ]*GLITE_SETUP[ ]*=.*|GLITE_SETUP ='"$ATLAS_LOCAL_ROOT_BASE"'/user/gangaGridSetup.sh|g' \
	-e 's|^[# ]*init_opts[ ]*=.*|init_opts = -voms '"${alrb_voms}"'|g' \
	-e 's|^[# ]*VirtualOrganisation[ ]*=.*|VirtualOrganisation = atlas|g' \
	-e 's|^[# ]*gangadir[ ]*=.*|gangadir ='"${alrb_gangaDir}"'/gangadir|g' \
	-e 's|^[# ]*setup[ ]*=.*/afs/cern.ch/.*ddm/.*|setup = '"$ATLAS_LOCAL_ROOT_BASE"'/user/gangaDDMSetup.sh|g' \
	-e 's|^[# ]*setupScript[ ]*=.*/afs/cern.ch/.*ddm/.*|setupScript = '"$ATLAS_LOCAL_ROOT_BASE"'/user/gangaDDMSetup.sh|g' \
	-e 's|^[#]*[ ]*setupScript[ ]*=.*gangaDDMSetup.sh.*|setupScript = '"$ATLAS_LOCAL_ROOT_BASE"'/user/gangaDDMSetup.sh|g' \
	$HOME/.gangarc.original  > $alrb_newFile

)
