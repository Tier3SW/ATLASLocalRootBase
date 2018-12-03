#!----------------------------------------------------------------------------
#!
#! panda.sh
#!
#! check panda job submission works
#!
#! Usage:
#!     panda.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

\echo " "
\echo "  panda test job ..."
source $ALRB_SMUDIR/shared.sh

lsetup panda > $ALRB_SMUDIR/pandaClient.out 2>&1

\cp $ATLAS_LOCAL_ROOT_BASE/tutorial/prunJob.sh ./

prun --exec=prunJob.sh --outDS=user.$alrb_nickname.`uuidgen` --noBuild >> $ALRB_SMUDIR/pandaClient.out 2>&1
if [ $? -ne 0 ]; then
    \cat $ALRB_SMUDIR/pandaClient.out  | \sed -e 's/^/  /g'
    \echo "  prun submission did not work"
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi
    
if [ "$alrb_errorFound" = "YES" ]; then
    unset alrb_errorFound
    return 64
fi

unset alrb_errorFound
return 0
