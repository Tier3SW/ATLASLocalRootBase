#!----------------------------------------------------------------------------
#!
#! grid.sh
#!
#! check the grid proxy is correct
#!
#! Usage:
#!     grid.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

alrb_nickname="unknown"
alrb_identity="unknown"

\echo " "
source $ATLAS_LOCAL_ROOT_BASE/user/genericGridSetup.sh --
\echo "  You will be asked for your grid proxy password ..."
stty -echo
voms-proxy-init -voms atlas 
alrb_rc=$?
stty echo
if [ $alrb_rc -ne 0 ]; then
    \echo "  Error: Unable to get proxy."
    \echo 'alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.sh
    \echo 'alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.sh
    \echo "                                                        ... Failed"
    return 64
fi
unset alrb_rc

\echo " "
\echo "  Check voms atlas role ..."
voms-proxy-info -all > $ALRB_SMUDIR/proxy.out 2>&1
alrb_tmpVal=`\grep -e "/atlas/Role=NULL/Capability=NULL" $ALRB_SMUDIR/proxy.out 2>&1`
if [ $? -ne 0 ]; then
    \echo "  Error: atlas role is missing"
    \echo "                                                        ... Failed"
    alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
fi
unset alrb_tmpVal

\echo "  Checking nickname ..."
alrb_nickname=`\grep nickname $ALRB_SMUDIR/proxy.out 2>&1 | \sed -e 's|.*nickname = \(.*\) (atlas).*|\1|g'`
if [[ $? -ne 0 ]] || [[ "$alrb_nickname" = "" ]]; then
    alrb_nickname="unknown"
    \echo "  Error: nickname does not look correct"
    \echo "                                                        ... Failed"
    alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
fi

\echo "  Identity ..."
alrb_identity=`voms-proxy-info --identity`
if [ $? -ne 0 ]; then
    alrb_identity="unknown"
    \echo "Error: error with identity"
    \echo "                                                        ... Failed"
    alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
fi

\echo 'alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.sh
\echo 'alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.sh

if [ "$alrb_errorFound" = "YES" ]; then
    unset alrb_errorFound
    return 64
fi

unset alrb_errorFound
return 0



