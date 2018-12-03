#!----------------------------------------------------------------------------
#!
#! genericGridSetup.sh
#!
#! A simple script to setup the grid environment
#!
#! History:
#!   8Aug08: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_tmpValue=`${ATLAS_LOCAL_ROOT_BASE}/utilities/isGridSetup.sh`
if [ "$alrb_tmpValue" = "none" ]; then
    if [ "$ALRB_useGridSW" = "emi" ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh emi
    fi
fi

