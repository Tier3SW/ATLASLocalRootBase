#!----------------------------------------------------------------------------
#!
#! pandaGridSetup.sh
#!
#! A simple script to setup the grid environment for Panda
#!
#! History:
#!   30Jan09: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# unset GRID_ENV_LOCATION since Panda will remove system paths for glite ...
# see http://savannah.cern.ch/bugs/?95311>
unset GRID_ENV_LOCATION
unset LCG_LOCATION

# so in efect, there is no grid middleware on the system ... 
#alrb_tmpVal=`${ATLAS_LOCAL_ROOT_BASE}/utilities/isGridSetup.sh`
#if [ "$alrb_tmpVal" = "none" ]; then
    if [ "$ALRB_useGridSW" = "emi" ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh --quiet
	source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh emi
    fi
#fi
