#! /bin/bash
#!----------------------------------------------------------------------------
#!
#!  readRealTest.sh
#!
#!  This tests your frontier/squid access
#!
#!  Usage:
#!      readRealTest.sh
#!
#!  History:
#!    05May2010: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_progname=readRealTest.sh

#!----------------------------------------------------------------------------
alrb_fn_readRealTestHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: db-readReal [options]

  This application will run a test accessing Frontier/squid as well as the 
  conditions pool files.

  This has to be run after cmthome/setup is done.  
  (A release >= 15.6.3 should be setup).

  Requirements: the path to the pool conditions data PFC and 
  Frontier-squid environment.  These are setup centrally by the ATLAS 
  Tier-3 administrator.
  
    Options (to override defaults) are:
     -h  --help               Print this help message

EOF
}


#!----------------------------------------------------------------------------
alrb_fn_cleanup()
#!----------------------------------------------------------------------------
{
    if [ "$$alrb_workdir" != "" ]; then
	\rm -rf $alrb_workdir
    fi

    return 0
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
            alrb_fn_readRealTestHelp
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

mkdir -p $ALRB_SCRATCH/Frontier
alrb_workdir=`\mktemp -d $ALRB_SCRATCH/Frontier/readRealXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "Error: unable to create fir in $ALRB_SCRATCH/Frontier"
    exit 64
fi
cd $alrb_workdir

if [ -z $FRONTIER_SERVER ]; then
    \echo "Error: Frontier / squid is not defined on this machine."
    \echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'
    alrb_fn_cleanup
    exit 64
fi

if [ -z $ATLAS_POOLCOND_PATH ]; then
    \echo "Error: pool condition path is not defined on this machine."
    \echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'
    alrb_fn_cleanup
    exit 64
fi

if [ -z $AtlasVersion ]; then
    \echo "Error: you should first setup an Athena release >= 15.6.3."
    \echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'
    alrb_fn_cleanup
    exit 64
else
    alrb_baseRel=`\echo $AtlasVersion | \cut -d "." -f 1-3`
    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_baseRel 3`
    if [ $alrb_result -lt 150603 ]; then
	\echo "This only runs on a release >= 15.6.3"
	\echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'	
	alrb_fn_cleanup
	exit 64
    elif [[ $alrb_result -ge 170000 ]] && [[ $alrb_result -lt 170800 ]] ; then
	\echo "This will not work on a 17.* release.  Please use newer releases"
	\echo " eg. asetup 20.20.6.3,here"
	\echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'		
	alrb_fn_cleanup
	exit 64
    fi
fi

alrb_relTestDir=$SITEROOT/AtlasConditions/$alrb_baseRel/AtlasTest/DatabaseTest/AthenaDBTestRec
if [ ! -d "$alrb_relTestDir" ]; then
    alrb_relTestDir=$SITEROOT/AtlasEvent/$alrb_baseRel/AtlasTest/DatabaseTest/AthenaDBTestRec
fi 

python $alrb_relTestDir/scripts/ReadReal.py --debug 1 $alrb_relTestDir/config/Tier0Cosmic1.py COMCOND-ES1C-000-00 90758
alrb_rc=$?

if [ $alrb_rc -ne 0 ]; then
    \echo -e "readReal                                                   "'[\033[31mFAILED\033[0m]'
else
    \echo " "
    \echo -e "readReal                                                   "'[\033[32m  OK  \033[0m]'
fi

\echo "
*******************************************************************************
What to expect if there are no problems:
  At the end of the output above, you should see, for example:
  >== All done, return code 0 time taken is 142.297781944
  readReal                                                   [  OK  ]
*******************************************************************************
"

alrb_fn_cleanup

exit $alrb_rc
