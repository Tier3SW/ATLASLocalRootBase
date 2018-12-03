#!/bin/bash
#!----------------------------------------------------------------------------
#!
#!  checkUserGrid.sh
#!
#!  Checks the user's grid certificates etc
#!
#!  Usage:
#!    checkUserGrid.sh --help
#!
#!  History:
#!    18Feb2011: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

shopt -s expand_aliases

alrb_progname=checkUserGrid.sh

alrb_summaryAr=()

#!----------------------------------------------------------------------------
alrb_fn_checkUserGridHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF
Usage: gridCert [options]

    This will check various things about the user's grid certificate and 
    LCG registration.
  
    Options (to override defaults) are:
     -h  --help               Print this help message

    Note that the grid password will be asked more than once.

EOF
}


#!----------------------------------------------------------------------------
alrb_fn_cleanup() 
#!----------------------------------------------------------------------------
{
    if [ "$alrb_workdir" != "" ]; then
	\rm -rf $alrb_workdir
    fi
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_initSummary() 
# args: 1: description
#!----------------------------------------------------------------------------
{
    let alrb_ThisStep+=1
    alrb_SkipTest="NO"
    alrb_altStatusFailed=""
    alrb_altStatusOK=""
    alrb_TestDescription=$1
    printf "\n\n\033[7m%3s\033[0m %-60s\n" "${alrb_ThisStep}:" "${alrb_TestDescription} ..."

    return 0
}

#!----------------------------------------------------------------------------
alrb_fn_addSummary() 
# args: 1: exit code, 2: exit or continue (only $1 != 0)
#!----------------------------------------------------------------------------
{
    local alrb_exitCode=$1
    local alrb_next=$2
    local alrb_status

    local alrb_color="32"
    if [ "$alrb_altStatusFailed" != "" ]; then
	alrb_status="$alrb_altStatusFailed"
	local alrb_color="34"
    elif [ "$alrb_altStatusOK" != "" ]; then
	alrb_status="$alrb_altStatusOK"
	local alrb_color="34"
    elif [ "$alrb_exitCode" -eq 0 ]; then
	if [ "$alrb_SkipTest" = "YES" ]; then
	        alrb_status=" SKIP "
		else
	        alrb_status=" OK "
		fi
    else
	local alrb_color="31"
	alrb_status="FAILED"
    fi
    printf "%-60s [\033[%2sm%s\033[0m]\n" "$alrb_TestDescription" $alrb_color "$alrb_status"

    alrb_SummaryAr=( "${alrb_SummaryAr[@]}" "$alrb_ThisStep:$alrb_TestDescription:$alrb_status" ) 

    if [[ "$alrb_next" = "exit" ]] && [[ $alrb_exitCode -ne 0 ]]; then
	alrb_fn_printSummary
	alrb_fn_cleanup
	exit $alrb_exitCode
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_printSummary() 
#!----------------------------------------------------------------------------
{

    if [ ${#alrb_SummaryAr[@]} -gt 0 ]; then
	printf "\n\n  %4s %-50s %s\n" "Step" "Test Description" "Result"
    fi
    for alrb_item in "${alrb_SummaryAr[@]}"; do
local alrb_step=`\echo $alrb_item | \cut -d ":" -f 1`
local alrb_descr=`\echo $alrb_item | \cut -d ":" -f 2`
local alrb_result=`\echo $alrb_item | \cut -d ":" -f 3`

printf "  %4s %-50s %s\n" "$alrb_step" "$alrb_descr" "$alrb_result"
    done
    if [ ${#alrb_SummaryAr[@]} -gt 0 ]; then
	\echo  " "
    fi

\echo "
*******************************************************************************
What to expect if there are no problems:
  In the summary, it should show '[  OK  ]' or '[ N/M  OK  ]' for checks.
  Check that the proxy attributes have atlas and /atlas/<country>
  Check that the nickname is the same as user's lxplus account (ask user)
  if AMI fails, use Firefox to access https://ami.in2p3.fr/index.php/en/ 
   and see if you can login with the same grid credentials.
  Sometimes, Step $alrb_serverCheckStep (Checking each voms server for authentication) may fail
   but it should be for one server at most and for 24h until your proxy
   is propagated to that server.  This is expected behaviour.
  Rucio and AMI may take up to 24h to know your certificates after LCG 
   registration.  If it is longer, contact user support. 
*******************************************************************************
Please MAIL the COMPLETE output from gridCert to user support.
*******************************************************************************
"
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_checkPermissions()
#!----------------------------------------------------------------------------
{
    local let alrb_retCode=0

    if [ ! -e $HOME/.globus/usercert.pem ]; then
	\echo " ---> Error: missing $HOME/.globus/usercert.pem"
	let alrb_retCode=64
    else
	alrb_filenameCert=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $HOME/.globus/usercert.pem`
	\ls -l $alrb_filenameCert
	alrb_permission=`stat --format=%a $alrb_filenameCert`
	if [[ "$alrb_permission" != "644" ]] && [[ "$alrb_permission" != "444" ]]; then
	    \ls -l $alrb_filenameCert
	    \echo " ---> recommend: chmod 444 $alrb_filenameCert"
	    let alrb_retCode=1
	fi
    fi
    if [ ! -e $HOME/.globus/userkey.pem ]; then
	\echo " ---> Error: missing $HOME/.globus/userkey.pem"
	let alrb_retCode=64
    else
	alrb_filenameKey=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $HOME/.globus/userkey.pem`
	\ls -l $alrb_filenameKey
	alrb_permission=`stat --format=%a $alrb_filenameKey`
	if [ "$alrb_permission" != "400" ]; then
	    \ls -l $alrb_filenameKey
	    \echo " ---> recommend: chmod 400 $alrb_filenameKey"
	    let alrb_retCode=1
	fi
    fi

    if [ $alrb_retCode -eq 1 ]; then
	\echo "You have permissions incorerct for one or more files."
	\echo " Please fix it first as suggested above and then retry gridCert"
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_setupGridSW()
#!----------------------------------------------------------------------------
{
    
    local let alrb_retCode=0

    if [ ! -z $GRID_ENV_LOCATION ]; then
	source $GRID_ENV_LOCATION/grid-env.sh
    else
	if [ "$ALRB_useGridSW" = "emi" ]; then
	    lsetup emi
	else
	    \echo " ---> Error: unable to determine grid middleware type to setup"
	    return 64
	fi
    fi
    local alrb_result=`which voms-proxy-init 2>&1`
    alrb_retCode=$?

    if [ $alrb_retCode -eq 0 ]; then
	if [ -z $ATLAS_LOCAL_EMI_VERSION ]; then
	    \echo " Grid middleware is setup from site rpms"
	fi
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_checkValidity()
#!----------------------------------------------------------------------------
{
    local let alrb_retCode=0

    local alrb_gridCertInfo="$alrb_workdir/gridcert.txt"
    grid-cert-info -all > $alrb_gridCertInfo 2>&1
    if [ $? -ne 0 ]; then
	\echo " ---> Error: Unable to do grid-cert-info"
	\cat $alrb_gridCertInfo
	return 64
    fi
    
    \echo -n "Certificate is : "
    grid-cert-info -subject

    \echo "Certificate Usage is : "
    \grep -A 1 -e "Usage:" $alrb_gridCertInfo
    
    \echo -n "Public key strength is : "
    \grep -e "Public-Key:" $alrb_gridCertInfo

    local alrb_start
    alrb_start=`grid-cert-info -startdate`
    local alrb_rc1=$?
    local alrb_end
    alrb_end=`grid-cert-info -enddate`
    local alrb_rc2=$?
    if [[ $alrb_rc1 -ne 0 ]] || [[ $alrb_rc2 -ne 0 ]]; then
	\echo " ---> Error: unable to get validity from grid certificate"
	let alrb_retCode=1
    else
	\echo "Start date: $alrb_start"
	\echo "End date  : $alrb_end"
	local let alrb_stime=`date -d "$alrb_start" --utc +%s`
	local let alrb_etime=`date -d "$alrb_end" --utc +%s`
	local let alrb_now=`date --utc +%s`
	if [ $alrb_stime -gt $alrb_now ]; then
	    \echo " ---> Error: valid start time is in the future"
	    let alrb_retCode=1
	fi
	if [ $alrb_etime -le $alrb_now ]; then
	    \echo " ---> Error: certificate has expired"
	    let alrb_retCode=1
	fi
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_matchKeyCert()
#!----------------------------------------------------------------------------
{

    local alrb_retCode=0

    \echo "  You will now be asked for your grid password ..."
    local alrb_modCert
    alrb_modCert=`openssl x509 -in $alrb_filenameCert -noout -modulus`
    local alrb_rc1=$?
    local alrb_modKey
    alrb_modKey=`openssl rsa -in $alrb_filenameKey -noout -modulus`
    local alrb_rc2=$?
    if [[ $alrb_rc1 -ne 0 ]] || [[ $alrb_rc2 -ne 0 ]]; then
	\echo " ---> Error: failed to get the information.  Did you entry the correct password ?"
	let alrb_retCode=64
    fi
    if [[ $alrb_retCode -eq 0 ]] && [[ "$alrb_modCert" != "$alrb_modKey" ]]; then
	\echo " ---> Error: key and certificate do not match !"
	\echo "      Cert $alrb_modCert"
	\echo "      Key  $alrb_modKey"
	let alrb_retCode=64
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_gridInitCheck()
#!----------------------------------------------------------------------------
{
    local let alrb_retCode=0

    \echo "  You will now be asked for your grid password ..."
    alrb_novomsProxy="$alrb_workdir/x509up_u${alrb_uid}_novoms"
    \rm -f $alrb_novomsProxy
    grid-proxy-init -out $alrb_novomsProxy -valid 96:00
    local alrb_rc1=$?
    if [ $alrb_rc1 -ne 0 ]; then
	\echo " ---> Error in getting the proxy"
	let alrb_retCode=$alrb_rc1
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_vomsCheck()
#!----------------------------------------------------------------------------
{
    local let alrb_retCode=0

    local alrb_serverList=( 
	"atlas-lcg-voms2.cern.ch"
	"atlas-voms2.cern.ch"
    )
    
    local let alrb_failure=0
    local let alrb_success=0
    
    alrb_myVomsesDir="$GLITE_LOCATION/etc/vomses"
    if [[ ! -d $alrb_myVomsesDir ]] && [[ ! -z $VOMS_USERCONF ]] && [[ -d $VOMS_USERCONF ]]; then
	alrb_myVomsesDir="$VOMS_USERCONF"
# need to unset this so that server error returns a failure
	unset VOMS_USERCONF
    fi
    if [[ ! -d $alrb_myVomsesDir ]] && [[ -d /etc/vomses ]]; then
	alrb_myVomsesDir=/etc/vomses
    fi
    \echo " vomses used: $alrb_myVomsesDir"
    local alrb_server
    for alrb_server in ${alrb_serverList[@]}; do
	\echo "
  server: $alrb_server ..."
	local alrb_vomsProxyFile="$alrb_workdir/x509up_u${alrb_uid}_$alrb_server"
	local alrb_oldAttrib=""
	\rm -f $alrb_vomsProxyFile
	export X509_USER_PROXY=$alrb_novomsProxy
	voms-proxy-init --voms atlas --out $alrb_vomsProxyFile --noregen --vomses $alrb_myVomsesDir/$alrb_server
	local alrb_rc1=$?
	local let alrb_rc2=0
	if [ $alrb_rc1 -ne 0 ]; then
	    \echo " ---> Error: Failed to get proxy from $alrb_server"
	    let alrb_failure+=1
	else
	    export X509_USER_PROXY=$alrb_vomsProxyFile
	    local alrb_proxyInfoFile="$alrb_workdir/proxy_info_$alrb_server.txt"
	    \rm -f $alrb_proxyInfoFile
	    voms-proxy-info --all | tee $alrb_proxyInfoFile
	    local alrb_attrib=`\grep attribute $alrb_proxyInfoFile | env LC_ALL=C \sort`
	    if [[ ! $alrb_attrib =~ "nickname" ]]; then
		\echo " ---> Error: missing attribute : nickname"
		let alrb_rc2=1
	    fi
	    if [ "$alrb_oldAttrib" = "" ]; then
		local alrb_oldAttrib="$alrb_attrib"
	    elif [ "$alrb_oldAttrib" != "$alrb_attrib" ]; then
		\echo " ---> Error: attributes are different from previous one"
		let alrb_rc2=1
	    fi
	fi    
	if [[ $alrb_rc1 -ne 0 ]] || [[ $alrb_rc2 -ne 0 ]]; then
 	    let alrb_failure+=1
	else
	    alrb_lastSuccessfulServer="$alrb_server"
	    let alrb_success+=1
	fi
	alrb_oldAttrib="$alrb_attrib"
    done

    if [ $alrb_failure -ne 0 ]; then
	if [ $alrb_success -ne 0 ]; then
	    local let alrb_total=`expr $alrb_failure + $alrb_success`
	    alrb_altStatusOK="$alrb_success/$alrb_total OK"
	else
	    alrb_retCode=64
	fi
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_roleCheck()
#!----------------------------------------------------------------------------
{

    local let alrb_retCode=0

    export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer
    local alrb_tmpVal
    alrb_tmpVal==`voms-proxy-info --exist 2>&1`
    if [ $? -ne 0 ]; then
	export X509_USER_PROXY=$alrb_novomsProxy
	voms-proxy-init --voms atlas --out $alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer  --noregen --vomses $alrb_myVomsesDir/$alrb_lastSuccessfulServer
	export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer
    fi
    voms-proxy-info -all > $alrb_workdir/proxyInfo.out 2>&1
    local alrb_result
    alrb_result=`\grep -e "/atlas/Role=NULL/Capability=NULL" $alrb_workdir/proxyInfo.out 2>&1`
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
	\echo " ---> Error: atlas role is missing"
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_nicknameCheck()
#!----------------------------------------------------------------------------
{

    local let alrb_retCode=0

    export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer
    local alrb_tmpVal
    alrb_tmpVal=`voms-proxy-info --exist 2>&1`
    if [ $? -ne 0 ]; then
	export X509_USER_PROXY=$alrb_novomsProxy
	voms-proxy-init --voms atlas --out $alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer  --noregen --vomses $alrb_myVomsesDir/$alrb_lastSuccessfulServer
	export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer
    fi
    voms-proxy-info -all > $alrb_workdir/proxyInfo.out 2>&1
    local alrb_result
    alrb_result=`\grep -e "nickname" $alrb_workdir/proxyInfo.out 2>&1`
    if [ $? -ne 0 ]; then
	\echo " ---> Error: nickname is missing"
	alrb_retCode=64
    else
	alrb_foundNickname=`\echo $alrb_result |  \sed -e 's/.*=[\ ]*//g' | \cut -f 1 -d " "` 
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_pandaserverCheck()
#!----------------------------------------------------------------------------
{

    let local alrb_retCode=0

    let local alrb_failure=0
    let local alrb_success=0
 
    export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer
    if [ -z $X509_CERT_DIR ]; then
	if [ -d /etc//grid-security/certificates ]; then
	    export X509_CERT_DIR=/etc//grid-security/certificates
	else
	    \echo " ---> Error: could not determine 509_CERT_DIR dir."	    
	    return 64
	fi
    fi

    if [ -d ~/.pki ]; then
	let alrb_result=`\find ~/.pki -type f | wc -l`
	if [ $alrb_result -ne 0 ]; then
	    \echo " "
	    \echo "Warning: ~/.pki has files which may cause failures."
	    \echo " "
	fi
    fi
	
# skip IPv6 for now
    local alrb_serverList=( `host pandaserver.cern.ch | egrep -v "IPv6" | \grep -e address | \cut -f 4 -d " "` )
    local alrb_server
    for alrb_server in ${alrb_serverList[@]}; do
	local alrb_serverReal=`host $alrb_server | \sed -e 's/.*pointer \(.*\.cern\.ch\)[.$]/\1/g'`
	\echo -e "\n Check $alrb_serverReal ..."
	curl --cert $X509_USER_PROXY --capath $X509_CERT_DIR  --cacert $X509_USER_PROXY https://${alrb_serverReal}:25443/server/panda/isAlive
	if [ $? -ne 0 ]; then
	    let alrb_failure+=1
	else
	    let alrb_success+=1
	fi
    done
    \echo " "

    if [ $alrb_failure -ne 0 ]; then
	if [ $alrb_success -ne 0 ]; then
	    local let alrb_total=`expr $alrb_failure + $alrb_success`
	    alrb_altStatusOK="$alrb_success/$alrb_total OK"
	else
	    alrb_retCode=64
	fi
    fi

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
alrb_fn_amiAccessCheck()
#!----------------------------------------------------------------------------
{

    local let alrb_retCode=0

    export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer

    \echo -n " Using identity "
    voms-proxy-info -identity

    (
	lsetup pyami

	ami list runs --year 15 > /dev/null
	exit $?
    )
    alrb_retCode=$?

    return $alrb_retCode
}    


#!----------------------------------------------------------------------------
alrb_fn_rucioInfo()
#!----------------------------------------------------------------------------
{
    local let alrb_retCode=0

    export X509_USER_PROXY=$alrb_workdir/x509up_u${alrb_uid}_$alrb_lastSuccessfulServer

    (
	local let alrb_rc1=0
	
	local alrb_result
	alrb_result=`which rucio 2>&1`
	if [ $? -ne 0 ]; then
	    \echo "setup RucioClients ..."
	    lsetup rucio
	    alrb_rc1=$?
	    if [ $alrb_rc1 -ne 0 ]; then
		\echo " ---> Error setting up RucioClients"
		let alrb_retCode=$alrb_rc1
	    fi	    
	else
	    \echo " Rucio was already setup ..."
	fi
	
	if [ -z $RUCIO_ACCOUNT ]; then
	    \echo "Warning: RUCIO_ACCOUNT is not defined."
	    if [ "$alrb_foundNickname" != "" ]; then
		\echo " "
		\echo " Setting RUCIO_ACCOUNT=$alrb_foundNickname"
		export RUCIO_ACCOUNT=$alrb_foundNickname
	    fi
	else
	    \echo "RUCIO_ACCOUNT is : $RUCIO_ACCOUNT"
	fi
	
	\echo "
 rucio whoami ...."
	rucio whoami
	alrb_rc1=$?
	if [ $alrb_rc1 -ne 0 ]; then
	    \echo " ---> Error: rucio whoami failed"
            let alrb_retCode=$alrb_rc1
	fi	    
	
	if [ ! -z $RUCIO_ACCOUNT ]; then
	    
	    \echo "
 rucio scope ..."
	    rucio-admin scope list | \grep -e "$RUCIO_ACCOUNT"
	    alrb_rc1=$?
	    if [ $alrb_rc1 -ne 0 ]; then
		\echo " ---> Error: rucio could not find scope for $RUCIO_ACCOUNT"
		let alrb_retCode=$alrb_rc1
	    fi	    
	    
	    \echo " 
 rucio identities ..."
	    rucio-admin account list-identities $RUCIO_ACCOUNT
	    alrb_rc1=$?
	    if [ $alrb_rc1 -ne 0 ]; then
		\echo " ---> Error: rucio list identities failed"
		let alrb_retCode=$alrb_rc1
	    fi	    
	    
	    \echo "
 rucio account usage ..."
	    rucio list-account-usage $RUCIO_ACCOUNT
	    alrb_rc1=$?
	    if [ $alrb_rc1 -ne 0 ]; then
		\echo " ---> Error: rucio account usage failed"
		let alrb_retCode=$alrb_rc1
	    fi	    
	    
	fi

	exit $alrb_retCode
    )

    alrb_retCode=$?

    return $alrb_retCode
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------


let alrb_ThisStep=0
alrb_SummaryAr=()
alrb_SkipTest="NO"
alrb_TestDescription=""
alrb_altStatusFailed=""
alrb_altStatusOK=""
alrb_lastSuccessfulServer=""
alrb_myVomsesDir=""
alrb_novomsProxy=""
alrb_foundNickname=""
alrb_serverCheckStep=""
alrb_uid=`id -u`

alrb_shortopts="h" 
alrb_longopts="help"
alrb_result=`getopt -T >/dev/null 2>&1`
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_checkUserGridHelp
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

if [ -z $ATLAS_LOCAL_ROOT_BASE ]
then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh --quiet --noLocalPostSetup
\mkdir -p $ALRB_tmpScratch/Diagnostics
alrb_workdir=`\mktemp -d ${ALRB_tmpScratch}/Diagnostics/checkUserGridXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "unable to create dir in $ALRB_tmpScratch/Diagnostics"
    exit 64
fi
cd $alrb_workdir

\echo "
**************************************************************************
 `date -u`
 gridCert running on "`hostname -f`"
**************************************************************************
"


alrb_fn_initSummary "Permissions certificate/key"
alrb_fn_checkPermissions
alrb_fn_addSummary $? "exit"

alrb_fn_initSummary "Setting up grid software"
alrb_fn_setupGridSW
alrb_fn_addSummary $? "exit"

alrb_fn_initSummary  "Certificate validity"
alrb_fn_checkValidity
alrb_fn_addSummary $? "exit"

alrb_fn_initSummary "Key / Certificate match"
alrb_fn_matchKeyCert
alrb_fn_addSummary $? "exit"

alrb_fn_initSummary "Check grid proxy"
alrb_fn_gridInitCheck
alrb_fn_addSummary $? "exit"

alrb_fn_initSummary "Authenticate voms server"
alrb_serverCheckStep=$alrb_ThisStep
alrb_fn_vomsCheck
alrb_rc=$?
if [ "$alrb_lastSuccessfulServer" = "" ]; then
    alrb_fn_addSummary $alrb_rc "exit"
else
    alrb_fn_addSummary $alrb_rc "continue"
fi

alrb_fn_initSummary "Role check"
alrb_fn_roleCheck
alrb_fn_addSummary $? "continue"

alrb_fn_initSummary "Nickname check"
alrb_fn_nicknameCheck
alrb_fn_addSummary $? "continue"

alrb_fn_initSummary "Pandaserver connect check"
alrb_fn_pandaserverCheck
alrb_fn_addSummary $? "continue"

alrb_fn_initSummary "AMI access check"
alrb_fn_amiAccessCheck
alrb_fn_addSummary $? "continue"

alrb_fn_initSummary "Rucio Information"
alrb_fn_rucioInfo
alrb_fn_addSummary $? "continue"

alrb_fn_printSummary
alrb_fn_cleanup

exit 0

