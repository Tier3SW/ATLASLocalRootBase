#!----------------------------------------------------------------------------
#!
#! env.sh
#!
#! check the env is correct
#!
#! Usage:
#!     env.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_errorFound="NO"

source $ALRB_SMUDIR/shared.sh

let alrb_rc=0

\echo " "
# check for disk space
alrb_spaceErrorFound="NO"
alrb_spaceSize=0
alrb_myDir=""
alrb_result=`\grep -e "^FS:" $ALRB_SMUDIR/config.txt 2>&1`
if [ $? -eq 0 ]; then
    alrb_spaceSize=`\echo $alrb_result | \cut -f 2 -d ":"`
fi
if [ $alrb_spaceSize != "0" ]; then
    \echo "  You will need $alrb_spaceSize MB for this tutorial ..."
    \echo -n "  Which dir will you use for the tutorial ? ([\$HOME]) : " 
    read alrb_myDir
    if [ "$alrb_myDir" = "" ]; then
	alrb_myDir=$HOME
    fi
    if [ ! -d $alrb_myDir ]; then
	\echo "  Error: $alrb_myDir does not exist"
	alrb_spaceErrorFound="YES"
    else
	alrb_result=`dd if=/dev/zero of=$alrb_myDir/_DELETE_ME.img bs=1 count=0 seek=${alrb_spaceSize}M 2>&1`
	if [ $? -ne 0 ]; then
	    \echo $alrb_result | \sed 's/^/  /g'
	    alrb_spaceErrorFound="YES"
	fi
	\rm -f $alrb_myDir/_DELETE_ME.img
    fi
    if [ "$alrb_spaceErrorFound" != "NO" ]; then
	alrb_errorFound="YES"
	\echo "                                                        ... Failed"
    else
	\echo "                                                        ... OK"
    fi
fi
unset alrb_spaceErrorFound alrb_spaceSize alrb_myDir

$ATLAS_LOCAL_ROOT_BASE/tutorial/fixKnownHosts.sh

\echo " "
\echo "  Test if your authentication is setup properly to check out code from svn ..."
alrb_svnPassed=""
klist -s
if [ $? -ne 0 ]; then
    if [ "$alrb_nickname" = "unknown" ]; then
	alrb_result=`hostname | \grep lxplus 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_lxplusName=`whoami`
	else
	    \echo -n "   What is your lxplus username ? "
	    read alrb_lxplusName
	fi
    else
	alrb_lxplusName=$alrb_nickname
    fi
    \echo "  Kerberos : You will be asked for your $alrb_lxplusName@CERN.CH password ..."
    stty -echo
    \kinit $alrb_lxplusName@CERN.CH    
    stty echo
    unset alrb_lxplusName
fi
klist -s
if [ $? -eq 0 ]; then
    \ssh -o "PasswordAuthentication=no" -o " PubkeyAuthentication=no" -o "GSSAPIAuthentication=yes" svn.cern.ch > $ALRB_SMUDIR/svnKrb.log 2>&1
    if [ $? -ne 1 ]; then
	alrb_svnPassed="NO"
	\cat $ALRB_SMUDIR/svnKrb.log | \sed -e  's/^/  /g'
	\echo " Failed: Could not use Kerberos for svn."
    else
	alrb_svnPassed="YES"
    fi
else
    alrb_svnPassed="NO"
    \echo "  Kerberos authentication failed."
fi

if [ "$alrb_svnPassed" != "YES" ]; then
    \echo " "
    \echo "  Public Key : You may be asked for your public key password ..."
    stty -echo
    \ssh -o "PasswordAuthentication=no" -o " PubkeyAuthentication=yes" -o "GSSAPIAuthentication=no" svn.cern.ch > $ALRB_SMUDIR/svnPub.log 2>&1    
    alrb_rc=$?
    stty echo
    if [ $alrb_rc -ne 1 ]; then
	alrb_svnPassed="NO"
	\cat $ALRB_SMUDIR/svnPub.log | \sed -e  's/^/  /g'
	\echo "  Failed: Could not use public key for svn."
    else
	alrb_svnPassed="YES"
    fi
fi

if [ "$alrb_svnPassed" != "YES" ]; then
    \echo " "
    \echo "  Both Kerberos and public key failed ..."
    \echo "  You should look at how to setup passwordless access.  See"
    \echo "   https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Password-lessSsh"
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi

unset alrb_svnPassed

\echo " "
\echo "  Check if RUCIO_ACCOUNT is defined ..."
alrb_result=`env | \grep RUCIO_ACCOUNT`
if [ $? -ne 0 ]; then
    \echo "  Failed: the env variable RUCIO_ACCOUNT is not defined. 
      export RUCIO_ACCOUNT=<your lxplus username> 
    should be setup in your login scripts."
    alrb_errorFound="YES"
    \echo "                                                        ... Failed"
else
    \echo "                                                        ... OK"
fi
 
if [ "$alrb_errorFound" = "YES" ]; then
    unset alrb_errorFound alrb_result alrb_rc
    return 64
fi

unset alrb_errorFound alrb_result alrb_rc
return 0