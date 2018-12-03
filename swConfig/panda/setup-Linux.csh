#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup PandaClient for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_PANDACLI_VERSION $1

if ( $?ATLAS_LOCAL_PANDACLIENT_PATH ) then
    deletePath PATH $ATLAS_LOCAL_PANDACLIENT_PATH
endif

setenv ATLAS_LOCAL_PANDACLIENT_PATH ${ATLAS_LOCAL_ROOT}/PandaClient/${ATLAS_LOCAL_PANDACLI_VERSION}

if ( $ALRB_RELOCATECVMFS != "YES" ) then
    source ${ATLAS_LOCAL_PANDACLIENT_PATH}/etc/panda/panda_setup.csh
else
    source ${ATLAS_LOCAL_PANDACLIENT_PATH}/etc/panda/panda_setup.csh.relocate
endif
setenv PATHENA_GRID_SETUP_SH ${ATLAS_LOCAL_ROOT_BASE}/user/pandaGridSetup.sh




