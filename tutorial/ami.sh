#!----------------------------------------------------------------------------
#!
#! ami.sh
#!
#! check ami works
#!
#! Usage:
#!     ami.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

source $ALRB_SMUDIR/shared.sh

\echo " "
\echo "  Testing ami list ..."
lsetup pyami > $ALRB_SMUDIR/ami.out 2>&1
ami list datasets --project mc11_7TeV --type NTUP_TAUMEDIUM % >> $ALRB_SMUDIR/ami.out 2>&1 
if [ $? -ne 0 ]; then
    \cat $ALRB_SMUDIR/ami.out  | \sed -e 's/^/  /g'
    \echo "  PyAMI did not work"
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
