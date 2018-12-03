#!----------------------------------------------------------------------------
#!
#!  postSetup.sh
#!
#!    post setup script
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if [ "$alrb_Quiet" = "NO" ]; then
    \echo " pod:" 
    export ALRB_menuFmtSkip="YES"
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh pod 2
    unset ALRB_menuFmtSkip
fi

\echo "
 pod users:
  Proof-on-Demand is no longer being developed and may be dropped on CC/SL7.
  If you still need this tool, please send an email to desilva@cern.ch 
   so that I can follow up.
"


