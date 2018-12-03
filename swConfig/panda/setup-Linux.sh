#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup PandaClient for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


alrb_fn_pandaCentOS7TransitionCheck()
{
    if [[ ! -z $AtlasVersion ]] && [[ ! -z $CMTCONFIG ]] && [[ $ALRB_OSMAJORVER -eq 7 ]]; then
	local let alrb_tmpValN=`\echo $AtlasVersion | cut -f 1 -d "."`
	if [ $alrb_tmpValN -ge 21 ]; then
	    \echo $CMTCONFIG | \grep -e "slc6" > /dev/null 2>&1
	    if [ $? -eq 0 ]; then
		\echo -e "
\033[31mWarning:\033[0m
\033[31m                               * * * * *\033[0m
  You have setup an ATLAS release $AtlasVersion $AtlasProject $CMTCONFIG
    but submitting from a centos7-compatible machine to the grid.  
  If you compiled locally, your jobs will work on Centos7 grid sites but may 
    fail on SLC6 grid sites due to incompatible system libraries.
    (Releases >= 21 are not recompliled on the grid.)
  
  If you see grid job failures and suspect this is the reason, compile and 
    submit from a SLC6 compatible machine (eg lxplus) or use a slc6 container
    (setupATLAS -c slc6) on non-slc6 machines.
    For details on containers, see:
    https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Containers
\033[31m                               * * * * *\033[0m
"
	    fi
	fi
    fi
    
    return 0
}


pathena()
{
    alrb_fn_pandaCentOS7TransitionCheck
    $ATLAS_LOCAL_PANDACLIENT_PATH/bin/pathena "$@"
    return $?
}


export ATLAS_LOCAL_PANDACLI_VERSION=$1

deletePath PATH $ATLAS_LOCAL_PANDACLIENT_PATH

export ATLAS_LOCAL_PANDACLIENT_PATH=${ATLAS_LOCAL_ROOT}/PandaClient/${ATLAS_LOCAL_PANDACLI_VERSION}

if [ $ALRB_RELOCATECVMFS != "YES" ]; then
    source ${ATLAS_LOCAL_PANDACLIENT_PATH}/etc/panda/panda_setup.sh
else
    source ${ATLAS_LOCAL_PANDACLIENT_PATH}/etc/panda/panda_setup.sh.relocate
fi
export PATHENA_GRID_SETUP_SH=${ATLAS_LOCAL_ROOT_BASE}/user/pandaGridSetup.sh




