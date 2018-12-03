#!----------------------------------------------------------------------------
#!
#! panda.csh
#!
#! check panda job submission works  
#!
#! Usage:
#!     panda.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

\echo " "
\echo "  panda test job ..."
source $ALRB_SMUDIR/shared.csh

\cp $ATLAS_LOCAL_ROOT_BASE/tutorial/prunJob.sh ./
lsetup panda >& $ALRB_SMUDIR/pandaClient.out
prun --exec=prunJob.sh --outDS=user.$alrb_nickname.`uuidgen` --noBuild >>& $ALRB_SMUDIR/pandaClient.out
if ( $? != 0 ) then
    \cat $ALRB_SMUDIR/pandaClient.out | \sed -e 's/^/  /g'
    \echo "  prun submission did not work"
    set alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif

if ( "$alrb_errorFound" == "YES" ) then
    unset alrb_errorFound
    exit 64
endif

unset alrb_errorFound
exit 0