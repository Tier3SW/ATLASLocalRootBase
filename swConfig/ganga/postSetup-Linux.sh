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

if [ "$alrb_Quiet" != "YES" ]; then
    \echo " ganga:" 
    export ALRB_menuFmtSkip="YES"
    $ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh ganga 2
    unset ALRB_menuFmtSkip
fi

if [ "$alrb_skipGangaRcCheck" != "YES" ];  then 
    $ATLAS_LOCAL_ROOT_BASE/swConfig/ganga/checkGangaRc.sh | \sed -e 's|^|   |g'
fi

$ATLAS_LOCAL_ROOT_BASE/swConfig/ganga/gangaWarning.sh 

unset alrb_skipGangaRcCheck
