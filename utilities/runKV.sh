#!/bin/bash
#!----------------------------------------------------------------------------
#!
#!  runKV.sh
#!
#!  This run KV on your desktop (non-intrusive)
#!
#!  Usage:
#!    runKV.sh --help
#!
#!  History:
#!    25Sep2000: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

shopt -s expand_aliases

alrb_progname=runKV.sh

#!----------------------------------------------------------------------------
alrb_fn_runKVHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF
Usage: runKV [options]

  **** See note at the bottom of this page *****

  This application will run KitValidation on any machine.
  
  The advantage of this is that anyone can run it anywhere (eg. to test a 
  desktop or new OS installation) and it is non-intrustive (will not affect
  the actual kit.)

  This has to be run after asetup is done.  
  
    Options (to override defaults) are:
     -h  --help               Print this help message

  The utility checks that the compiler and DBRelease versions match 
  what is required by Kit Validation; you will first need to setup the release.
     (login to a new session)
     setupATLAS
     asetup 15.6.9 
     diagnostics
     runKV  

  Note that a failure does not necessarily indicate there is a problem
  with your machine - you should ask if anyone else sees it for that 
  configuration (Atlas release & project, OS version, 32 or 64 bit OS ?) on 
  another machine.

  For details on which configurations work, please see
    https://twiki.atlas-canada.ca/bin/view/AtlasCanada/ConfigurationsKV
  (and please tell us if you know something we do not !)

EOF
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h" 
alrb_longopts="help"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_runKVHelp
            exit 0
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

source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh --quiet --noLocalPostSetup

# check if project and Atlas release is defined
if [ -z $AtlasVersion ]; then
    \echo "Error: AtlasVersion is missing.  Did you do asetup <release> ?"
    exit 64
fi

if [ -z $AtlasProject ]; then
    \echo "Error: AtlasProject is missing.  Did you do asetup <release> ?"
    exit 64
fi

# get required DB versions if any
alrb_result=`curl -s -k "https://atlas-install.roma1.infn.it/atlas_install/info/showrel.php?swname=$AtlasProject&version=$AtlasVersion"`
if [ $? -ne 0 ]; then
    \echo -e "Unable to get information from installation database.     "'[\033[31mFAILED\033[0m]'
    exit 64
fi
alrb_requiredDB=`\echo $alrb_result | \sed -e 's/.*\(DBRELEASE=.*\)/\1/g' | \cut -d "," -f 1 | \sed 's/DBRELEASE=--dbrelease //g'`
if [ "$alrb_requiredDB" == "DBRELEASE=" ]; then
    alrb_requiredDB=""
fi

\echo "------------------------------------------------------------------------"
\echo "date is " `date`
\echo "hostname is " `hostname -f`
\cat /etc/redhat-release
uname -a
\echo "AtlasVersion is : $AtlasVersion "
\echo "AtlasProject is : $AtlasProject "
\echo "SITEROOT is  : $SITEROOT "
\echo "gcc versions are ..."
which gcc
gcc --version
\echo "CMT values are ..."
\echo "CMTCONFIG: $CMTCONFIG"
\echo "CMTPATH: $CMTPATH"
\echo "DBRelease ..."
\echo " required: $alrb_requiredDB"
\echo " current: $DBRELEASE"
\echo "------------------------------------------------------------------------"

alrb_pathCompilerVer=`gcc --version | \head -n 1 | \awk '{print $3}' | \cut -d "." -f 1-2 | \sed 's/\.//'`
alrb_cmtCompilerVer=`\echo $CMTCONFIG | \sed 's/.*gcc\([0-9]*\).*/\1/'`
if [ "$alrb_pathCompilerVer" != "$alrb_cmtCompilerVer" ]; then
    \echo -e "Compiler is not the one required for the kit              "'[\033[31mFAILED\033[0m]'
    exit 64
fi

if [[ "$alrb_requiredDB" != "" ]] && [[ "$alrb_requiredDB" != "DBRELEASE=" ]]; then
    if [ "$alrb_requiredDB" != "$DBRELEASE" ]; then
	\echo "DBRelease is $DBRELEASE but KV requires $alrb_requiredDB ..."
	\echo "I will now redo asetup with this dbrelease:"
	alrb_myCmd="source $AtlasSetup/scripts/asetup.sh $AtlasVersion,$AtlasProject --dbrelease=$alrb_requiredDB --cmtconfig $CMTCONFIG"
	eval $alrb_myCmd
	if [ $? -ne 0 ]; then
	    exit 64
	fi
    fi
else 
    \echo "I will now redo asetup with kit's default dbrelease:"
    alrb_myCmd="source $AtlasSetup/scripts/asetup.sh $AtlasVersion,$AtlasProject --dbrelease=\"<default>\" --cmtconfig $CMTCONFIG"
    eval $alrb_myCmd
    if [ $? -ne 0 ]; then
	exit 64
    fi    
fi

if [ -z $ALRB_SCRATCH ]; then
    alrb_homedir=$HOME/.alrb
else
    alrb_homedir=$ALRB_SCRATCH 
fi
alrb_workdir=$alrb_homedir/KV/`hostname`/$AtlasVersion.$AtlasProject
mkdir -p $alrb_workdir
cd $alrb_workdir

source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh --quiet pacman

alrb_additionalKVOptions=""
alrb_baseRel=`\echo $AtlasVersion | \cut -d "." -f 1-3`
if [ "$AtlasVersion" != "$alrb_baseRel" ]; then
    alrb_additionalKVOptions="$alrb_additionalKVOptions --require-prj AtlasOffline"
fi

#export ARCH=`\echo _$CMTCONFIG | \cut -d "-" -f 1-3 | \sed -e 's/-/_/g'`
alrb_myPRJOPT=`\echo $CMTCONFIG | \cut -d "-" -f 4`

$ATLAS_LOCAL_ROOT_BASE/sw-mgr/current/sw-mgr $alrb_additionalKVOptions --no-tag --kv-keep --test $AtlasVersion --kv-cache=KV --physical $SITEROOT --project=$AtlasProject --project-opt=$alrb_myPRJOPT --dir=$alrb_workdir

\echo "
*******************************************************************************
What to expect if there are no problems:
  At the end of the output above, '[  OK  ]' and EXIT: 0
*******************************************************************************
"

exit $rc




