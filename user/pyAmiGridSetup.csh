#!----------------------------------------------------------------------------
#!
#! pyAmiGridSetup.csh
#!
#! A simple script to setup the grid environment for pyAMI
#!
#! History:
#!   28Mar12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------
 
# rucio uses wrappers and seem a natural fit ...
#localSetupRucio --quiet > /dev/null
#localSetupRucio
insertPath PATH $ATLAS_LOCAL_ROOT_BASE/wrappers/gridMW

