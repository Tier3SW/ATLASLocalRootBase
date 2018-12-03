#!----------------------------------------------------------------------------
#!
#! genericGridSetup.csh
#!
#! A simple script to setup the grid environment
#!
#! History:
#!   8Aug08: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_tmpVal=`${ATLAS_LOCAL_ROOT_BASE}/utilities/isGridSetup.sh`
if ( "$alrb_tmpVal" == "none" ) then
    if ( "$ALRB_useGridSW" == "emi" ) then
	source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.csh emi
    endif
endif


