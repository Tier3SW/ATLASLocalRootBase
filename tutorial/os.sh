#!----------------------------------------------------------------------------
#!
#! os.sh
#!
#! check the os is correct
#!
#! Usage:
#!     os.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

\echo " "
alrb_result=`\grep -e "^OS:" $ALRB_SMUDIR/config.txt 2>&1`
if [ $? -eq 0 ]; then
    alrb_allowedOS=`\echo $alrb_result | \cut -f 2 -d ":"`
else  
    alrb_allowedOS="none"
fi

alrb_osOK="NO"

\echo "  Check OS version ..."
alrb_result=`\echo $alrb_allowedOS | \grep -e "RHEL" 2>&1`
if [[ $? -eq 0 ]] && [[ -e /etc/redhat-release ]]; then
    alrb_osVer=`\echo $alrb_allowedOS | \sed -e 's/.*RHEL=\([0-9]*\).*/\1/g'`
    if [ "$ALRB_OSMAJORVER" = "$alrb_osVer" ]; then
	alrb_osOK="YES"
    fi
fi
if [ "$alrb_osOK" != "YES" ]; then
    \echo " "
    $ATLAS_LOCAL_ROOT_BASE/tutorial/listOS.sh | \sed -e 's/^/  /g'
    \echo "  Error: OS is not compatible"
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi
unset alrb_allowedOS alrb_osVer alrb_osOK

\echo "  Check cvmfs validity ..."
# check cvmfs validity
$ATLAS_LOCAL_ROOT_BASE/utilities/checkValidity.sh --checkOnly="atlas,condb,alrb" --exitCodeFor="atlas,alrb" > $ALRB_SMUDIR/checkValidity.out 2>&1
alrb_rc=$?
let alrb_wcfile=`wc -l  $ALRB_SMUDIR/checkValidity.out | \cut -f 1 -d " "`
if [ $alrb_wcfile -gt 0 ]; then
    \echo " "
    \cat $ALRB_SMUDIR/checkValidity.out | \sed -e 's/^/  /g'
fi
if [ $alrb_rc -ne 0 ]; then
    \echo "  Error: Check cvmfs validity failed."
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi
unset alrb_rc alrb_wcfile

# check ATLAS ready
\echo "  Check for missing software ..."
$ATLAS_LOCAL_ROOT_BASE/utilities/installCheck.sh > $ALRB_SMUDIR/checkOS.out 2>&1
alrb_result=`\grep -e "Missing rpms" $ALRB_SMUDIR/checkOS.out 2>&1`
if [ $? -eq 0 ]; then
    \echo " "
    \cat $ALRB_SMUDIR/checkOS.out  | \sed -e 's/^/  /g'
    \echo "  Error: CheckOS cvmfs failed."
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi

# check if node has FQDN
\echo "  Check FQDN ..."
alrb_result=`\echo $alrb_domain | \grep -e "\."`
if [ $? -ne 0 ]; then
    \echo " "
    \echo "  Error: domain name is not set correctly : $alrb_domain"
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi

if [ "$alrb_errorFound" = "YES" ]; then
    unset alrb_errorFound alrb_result
    return 64
fi

unset alrb_errorFound alrb_result
return 0
