#!----------------------------------------------------------------------------
#!
#! generatePoDSetups.sh
#!
#! Generate the PoD local-remote script pair
#!
#! Usage:
#!     source generatePoDSetups.sh --help
#!
#! History:
#!   15Nov11: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=generatePoDSetups.sh

alrb_fn_generatePoDSetupsHelp()
{
    \cat <<EOF

Usage: generatePoDSetups [options]

    This generates the PoD local and remote setup scripts for pod-remote

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.    
      and also setup PoD

    Options (to override defaults) are:
     -h  --help             Print this help message
     --outdir=STRING        Output dir for scripts (default=$HOME/myPoD)
     --prefix=STRING        Prefix to add to script name (default=`hostname -s`)

EOF
}

alrb_shortopts="h"
alrb_longopts="help,outDir:,prefix:"
alrb_result=`getopt -T >/dev/null 2>&1`
if [ $? -eq 4 ] ; then # New longopts getopt.
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
    return 1
fi

eval set -- "$alrb_opts"

alrb_outDirVal="$HOME/myPoD"
alrb_prefix=`hostname -s`

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_generatePoDSetupsHelp
            return 0
            ;;
        --outDir)
            alrb_outDirVal="$2"
	    eval alrb_outDirVal=$alrb_outDirVal
            shift 2
            ;;
        --prefix)
            alrb_prefix=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" ? /dev/stderr
            return 1
            ;;
    esac
done

if [ -z $ALRB_POD_DIR ]; then
    \echo "Error: PoD is not setup.  Please do that first." 1>&2
    return 64
fi

if [ ! -d $alrb_outDirVal ]; then
    \mkdir -p $alrb_outDirVal
fi
alrb_setupFileName="${alrb_prefix}_PoDLocalSetup.sh"
alrb_setupFile="$alrb_outDirVal/$alrb_setupFileName"
alrb_remoteFileName="${alrb_prefix}_PoDRemote.cfg"
alrb_remoteFile="$alrb_outDirVal/$alrb_remoteFileName"
if [[ -e $alrb_setupFile ]] || [[ -e $alrb_remoteFile ]]; then
    \rm -f $alrb_setupFile $alrb_remoteFile
fi

alrb_thisUser=`whoami`
alrb_thisHost=`hostname -f`
alrb_myDate=`date`
 
alrb_myASetup=""
if [ ! -z $AtlasProject ]; then
    alrb_myASetup="asetup $AtlasVersion,$AtlasProject --testarea=$TestArea"
fi

alrb_myPoDSetup="lsetup \"pod --podVersion=$ATLAS_LOCAL_POD_VERSION --skipConfirm"
if [[ "$alrb_myASetup" != "" ]] && [[ "$ROOTSYS" != "$ATLAS_LOCAL_ROOT/root/$ATLAS_LOCAL_CERNROOT_VERSION" ]]; then
    alrb_myPoDSetup="$alrb_myPoDSetup --skipRootSetup"
else
    alrb_myPoDSetup="$alrb_myPoDSetup --rootVersion=$ATLAS_LOCAL_CERNROOT_VERSION"
fi
alrb_myPoDSetup="$alrb_myPoDSetup\""

\cat <<EOF > $alrb_setupFile
# generated on $alrb_myDate

# This script will be run by pod-remote when it connects.
# Do not move or rename it.

# define ATLASLocalRootBase and setup
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source \$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh

# any Athena setups here (this is a guess, edit as appropriate)
$alrb_myASetup

# setup PoD
$alrb_myPoDSetup

EOF

\cat <<EOF > $alrb_remoteFile
# generated on $alrb_myDate

# This is the configuration file used by pod-remote.
#  Copy it to the machine where you will run pod-remote.
#  You will then be able to use it:
#   setupATLAS
#   localSetupPoD
#   pod-remote -c $alrb_remoteFileName --start
#   pod-remote --command "pod-submit -r ... "
#   etc
#   pod-remote -c $alrb_remoteFileName --stop
#
# See https://twiki.atlas-canada.ca/bin/view/AtlasCanada/ATLASLocalRootBase#PoD

remote=$alrb_thisUser@$alrb_thisHost:$ALRB_POD_DIR

env-remote=$alrb_setupFile

EOF

\cat <<EOF 

On the remote machine where you plan to run PoD, 
  scp $alrb_thisUser@$alrb_thisHost:$alrb_remoteFile ./
For details, see 
  https://twiki.atlas-canada.ca/bin/view/AtlasCanada/ATLASLocalRootBase#PoD

EOF


