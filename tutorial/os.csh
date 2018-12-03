#!----------------------------------------------------------------------------
#!
#! os.csh
#!
#! check the os is correct 
#!
#! Usage:
#!     os.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

\echo " "
set alrb_result=`\grep -e "^OS:" $ALRB_SMUDIR/config.txt`
if ( $? == 0 ) then
    set alrb_allowedOS=`\echo $alrb_result | \cut -f 2 -d ":"`
else 
    set alrb_allowedOS="none"
endif

set alrb_osOK="NO"

\echo "  Check OS version ..."
set alrb_result=`\echo $alrb_allowedOS | \grep -e "RHEL"`
if ( ( $? == 0 ) && ( -e /etc/redhat-release ) ) then
    set alrb_osVer=`\echo $alrb_allowedOS | \sed -e 's/.*RHEL=\([0-9]*\).*/\1/g'`
    if ( "$ALRB_OSMAJORVER" == "$alrb_osVer" ) then
	set alrb_osOK="YES"
    endif
endif
if ( "$alrb_osOK" != "YES" ) then
    \echo " "
    $ATLAS_LOCAL_ROOT_BASE/tutorial/listOS.sh | \sed -e 's/^/  /g'
    \echo "  Error: OS is not compatible"
    set alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif
unset alrb_allowedOS alrb_osVer alrb_osOK

\echo "  Check cvmfs validity ..."
# check cvmfs validity
$ATLAS_LOCAL_ROOT_BASE/utilities/checkValidity.sh --checkOnly="atlas,condb,alrb" --exitCodeFor="atlas,alrb" >& $ALRB_SMUDIR/checkValidity.out
set alrb_rc=$? 
set alrb_wcfile=`wc -l  $ALRB_SMUDIR/checkValidity.out | \cut -f 1 -d " "`
if ( $alrb_wcfile > 0 ) then
    \echo " "
    \cat $ALRB_SMUDIR/checkValidity.out | \sed -e 's/^/  /g'
endif
if ( $alrb_rc != 0 ) then
    set alrb_errorFound="YES"
    \echo "  Error: Check cvmfs validity failed."
    \echo "                                                        ... Failed"
else    
    \echo "                                                        ... OK"
endif
unset alrb_rc alrb_wcfile

# check ATLAS ready
\echo "  Check for missing software ..."
$ATLAS_LOCAL_ROOT_BASE/utilities/installCheck.sh >& $ALRB_SMUDIR/checkOS.out 
set alrb_result=`\grep -e "Missing rpms" $ALRB_SMUDIR/checkOS.out`
if ( $? == 0 ) then
    \echo " "
    \cat $ALRB_SMUDIR/checkOS.out  | \sed -e 's/^/  /g'
    \echo "  Error: CheckOS cvmfs failed."
    set alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif

# check if node has FQDN
\echo "  Check FQDN ..."
set alrb_result=`\echo $alrb_domain | \grep -e "\."`
if ( $? != 0 ) then
    \echo " "
    \echo "  Error: domain name is not set correctly : $alrb_domain"
    set alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif

if ( $alrb_errorFound == "YES" ) then
    unset alrb_errorFound alrb_result
    exit 64
endif

unset alrb_errorFound alrb_result
exit 0
