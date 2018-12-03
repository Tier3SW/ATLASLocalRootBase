#!----------------------------------------------------------------------------
#!
#! grid.csh
#!
#! check the grid proxy is correct 
#!
#! Usage:
#!     grid.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

set alrb_nickname="unknown"
set alrb_identity="unknown"

\echo " "
source $ATLAS_LOCAL_ROOT_BASE/user/genericGridSetup.csh --
\echo "  You will be asked for your grid proxy password ..."
stty -echo
voms-proxy-init -voms atlas 
set alrb_rc=$?
stty echo
if ( $alrb_rc != 0 ) then
    \echo "  Error: Unable to get proxy."
    \echo 'set alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.csh
    \echo 'set alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.csh
    \echo 'alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.sh
    \echo 'alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.sh
    \echo "                                                        ... Failed"
    exit 64
endif
unset alrb_rc

\echo " "
\echo "  Check voms atlas role ..."
voms-proxy-info -all >& $ALRB_SMUDIR/proxy.out
set alrb_tmpVal=`\grep -e "/atlas/Role=NULL/Capability=NULL" $ALRB_SMUDIR/proxy.out`
if ( $? != 0 ) then
    \echo "  Error: atlas role is missing"
    \echo "                                                        ... Failed"
    set alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
endif
unset alrb_tmpVal

\echo "  Checking nickname ..."
set alrb_nickname=`\grep nickname $ALRB_SMUDIR/proxy.out | \sed -e 's|.*nickname = \(.*\) (atlas).*|\1|g'`
if (( $? != 0 ) || ( "$alrb_nickname" == "" ))  then
    set alrb_nickname="unknown"
    \echo "  Error: nickname does not look correct"
    \echo "                                                        ... Failed"
    set alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
endif

\echo "  Identity ..."
set alrb_identity=`voms-proxy-info --identity`
if ( $? != 0 ) then
    set alrb_identity="unknown"
    \echo "  Error: error with identity"
    \echo "                                                        ... Failed"
    set alrb_errorFound="YES"
else
    \echo "                                                        ... OK"
endif

\echo 'set alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.csh
\echo 'set alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.csh
\echo 'alrb_identity="'$alrb_identity'"' >> $ALRB_SMUDIR/shared.sh
\echo 'alrb_nickname="'$alrb_nickname'"' >> $ALRB_SMUDIR/shared.sh

if ( $alrb_errorFound == "YES" ) then
    unset alrb_errorFound
    exit 64
endif

unset alrb_errorFound
exit 0
