#!----------------------------------------------------------------------------
#!
#! env.csh
#!
#! check the env is correct 
#!
#! Usage:
#!     env.csh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_errorFound="NO"

source $ALRB_SMUDIR/shared.csh

set alrb_rc=0

\echo " "
# check for disk space
set alrb_spaceErrorFound="NO"
set alrb_spaceSize=0
set alrb_myDir=""
set alrb_result=`\grep -e "^FS:" $ALRB_SMUDIR/config.txt`
if ( $? == 0 ) then
    set alrb_spaceSize=`\echo $alrb_result | \cut -f 2 -d ":"`
endif
if ( $alrb_spaceSize != "0" ) then
    \echo "  You will need $alrb_spaceSize MB for this tutorial ..."
    \echo -n '  Which dir will you use for the tutorial ? ([$HOME]) : '
    set alrb_myDir=$<
    if ( "$alrb_myDir" == "" ) then
	set alrb_myDir=$HOME
    endif
    if ( ! -d $alrb_myDir ) then
	\echo "  Error: $alrb_myDir does not exist"
	set alrb_spaceErrorFound="YES"
    else
	\rm -f $ALRB_SMUDIR/dd_csh.txt
	dd if=/dev/zero of=$alrb_myDir/_DELETE_ME.img bs=1 count=0 seek=${alrb_spaceSize}M >& $ALRB_SMUDIR/dd_csh.txt
	if ( $? != 0 ) then
	    \cat $ALRB_SMUDIR/dd_csh.txt | \sed 's/^/  /g'
	    set alrb_spaceErrorFound="YES"
	endif
	\rm -f $alrb_myDir/_DELETE_ME.img
    endif
    if ( "$alrb_spaceErrorFound" != "NO" ) then
	set alrb_errorFound="YES"
	\echo "                                                        ... Failed"
    else
	\echo "                                                        ... OK"
    endif
endif
unset alrb_spaceErrorFound alrb_spaceSize alrb_myDir

$ATLAS_LOCAL_ROOT_BASE/tutorial/fixKnownHosts.sh

\echo " "
\echo "  Test if your authentication is setup properly to check out code from svn ..."
set alrb_svnPassed=""
klist -s
if ( $? != 0 ) then
    if ( "$alrb_nickname" == "unknown" ) then
	set alrb_result=`hostname | \grep lxplus`
	if ( $? == 0 ) then
	    set alrb_lxplusName=`whoami`
	else
	    \echo -n "   What is your lxplus username ? "
	    set alrb_lxplusName=$<
	endif
    else
	set alrb_lxplusName=$alrb_nickname
    endif
    \echo "  Kerberos : You will be asked for your $alrb_lxplusName@CERN.CH password ..."
    stty -echo
    \kinit $alrb_lxplusName@CERN.CH
    stty echo
    unset alrb_lxplusName
endif
klist -s
if ( $? == 0 ) then
    \ssh -o "PasswordAuthentication=no" -o " PubkeyAuthentication=no" -o "GSSAPIAuthentication=yes" svn.cern.ch >& $ALRB_SMUDIR/svnKrb.log
    if ( $? != 1 ) then
	set alrb_svnPassed="NO"
	\cat $ALRB_SMUDIR/svnKrb.log | \sed -e  's/^/  /g'
	\echo " Failed: Could not use Kerberos for svn."	
    else
	set alrb_svnPassed="YES"
    endif
else
    set alrb_svnPassed="NO"
    \echo "  Kerberos authentication failed."
endif

if ( "$alrb_svnPassed" != "YES" ) then
    \echo " "
    \echo "  Both Kerberos and public key failed ..."
    \echo "  Kerberios failed so try public key"
    \echo "  Public Key : You may be asked for your public key password ..." 
    stty -echo
    \ssh -o "PasswordAuthentication=no" -o " PubkeyAuthentication=yes" -o "GSSAPIAuthentication=no" svn.cern.ch >& $ALRB_SMUDIR/svnPub.log
    set alrb_rc=$?
    stty echo
    if ( $alrb_rc != 1 ) then
	set alrb_svnPassed="NO"
	\cat $ALRB_SMUDIR/svnPub.log | \sed -e  's/^/  /g'
	\echo "  Failed: Could not use public key for svn."	
    else
	set alrb_svnPassed="YES"
    endif
endif

if ( "$alrb_svnPassed" != "YES" ) then
    set alrb_errorFound="YES"
    \echo " "
    \echo "  You should look at how to setup passwordless access.  See"
    \echo "   https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Password-lessSsh"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif

unset alrb_svnPassed

\echo " "
\echo "  Check if RUCIO_ACCOUNT is defined ..."
set alrb_result=`env | \grep RUCIO_ACCOUNT`
if ( $? != 0 ) then
    \echo "  Failed: the env variable RUCIO_ACCOUNT is not defined. \
      setenv RUCIO_ACCOUNT <your lxplus username>\
    should be setup in your login scripts."
    set alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
endif

if ( "$alrb_errorFound" == "YES" ) then
    unset alrb_errorFound alrb_result alrb_rc
    exit 64
endif

unset alrb_errorFound alrb_result alrb_rc
exit 0
