#!----------------------------------------------------------------------------
#!
#! ami.csh
#!
#! check ami works
#!
#! Usage:
#!     ami.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

source $ALRB_SMUDIR/shared.csh

\echo " "
\echo "  Testing ami list ..."
lsetup pyami >& $ALRB_SMUDIR/ami.out
ami list datasets --project mc11_7TeV --type NTUP_TAUMEDIUM % >> $ALRB_SMUDIR/ami.out
if ( $? != 0 ) then
    \cat $ALRB_SMUDIR/ami.out | \sed -e 's/^/  /g'
    \echo "  PyAMI did not work"
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
