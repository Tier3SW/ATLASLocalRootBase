#!----------------------------------------------------------------------------
#!
#! gangaGridSetup.sh
#!
#! A simple script to setup the grid environment for GANGA
#!
#! History:
#!   8Aug08: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

unset PYTHONHOME
export PATHENA_GRID_SETUP_SH=$ATLAS_LOCAL_ROOT_BASE/user/pandaGridSetup.sh
PANDA_EMI_SETUP=`python -c "from pandatools import Client; print Client._getGridSrc()"`
eval "$PANDA_EMI_SETUP"



