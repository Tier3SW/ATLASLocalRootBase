#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! checkRucioRSE.sh
#!
#! Checks access to a rucio RSE
#!
#! Usage: 
#!     checkRucioRSE.sh <RSE>
#!
#! History:
#!   09Jun16: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=checkRucioRSE

alrb_GfalTimeout="60"
alrb_MaxGetFileSize="1000"

#!----------------------------------------------------------------------------
alrb_fn_checkRucioRSEHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF 
Usage: checkRucioRSE [RSE|DID] [options]

    This will check if you are able to properly access files at a site.

    You can either suppply the RSE or the rucio did; eg
       checkRucioRSE user.dario:user.dario.test2.physics_ZeroBias.repro20_v02_hist.81190568
       or
       checkRucioRSE INFN-GENOVA_SCRATCHDISK

    Note that if the RSEs is not either SCRATCH or USERDISK,
      a DID that resides on the space token should be specified instead.
  
    Options (to override defaults) are:
     -g --getLimit <integer>  rucio get file size limit; defailt $alrb_MaxGetFileSize MB
     -h --help                Print this help message
     -r --rse <string>        Specify rse to use (eg with did as input)
     -s --skipConfirm         Skip all confirmation queries
     -t --timeout <integer>   Timeout for gfal-ls; default: $alrb_GfalTimeout s
     -p --protocol <string>   Rucio download protocol if not default

    Note that the grid password may be asked.

EOF
}


#!----------------------------------------------------------------------------
alrb_fn_initSummary() 
# args: 1: description
#!----------------------------------------------------------------------------
{
    let alrb_ThisStep+=1
    alrb_SkipTest="NO"
    alrb_altStatus=""
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
    if [ "$alrb_altStatus" != "" ]; then
	alrb_status="$alrb_altStatus"
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

    printf "%-67s [\033[%2sm%6s\033[0m]\n" "$alrb_TestDescription" $alrb_color "$alrb_status"

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
	printf "\n\n  %4s %-50s %10s\n" "Step" "Test Description" "Result"
    fi
    for alrb_item in "${alrb_SummaryAr[@]}"; do
	local alrb_step=`\echo $alrb_item | \cut -d ":" -f 1`
	local alrb_descr=`\echo $alrb_item | \cut -d ":" -f 2`
	local alrb_result=`\echo $alrb_item | \cut -d ":" -f 3`
	printf "  %4s %-50s %10s\n" "$alrb_step" "$alrb_descr" "$alrb_result"
    done
    if [ ${#alrb_SummaryAr[@]} -gt 0 ]; then
		\echo  " "
    fi

    \echo "
*******************************************************************************
What to expect if there are no problems:
  All tests should pass.  Skipping tests expected if user has no quota on RSE.
  If you have a quota on an RSE, and the RSE has free space, then upload 
    and erase tests will also run and should pass 
  If the site is in downtime, some tests may be expected to fail.  This depends
    on the type of donwtime declared as described in the test.
*******************************************************************************
Please MAIL the COMPLETE output from rseCheck to user support.
*******************************************************************************
"
    
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_getRSEList() 
#!----------------------------------------------------------------------------
{
    rucio list-rses | \egrep -v "TAPE" > $alrb_rseWorkdir/rseList.txt 2>&1 
    if [ $? -eq 0 ]; then
	alrb_RseListFile="$alrb_rseWorkdir/rseList.txt"
    else
	return 64
    fi
    return 0
}


#!----------------------------------------------------------------------------
 alrb_fn_getRSEQuota() 
#!----------------------------------------------------------------------------
{
    \rm -f $alrb_rseWorkdir/quota.txt
    rucio list-account-usage --rse "$alrb_RseName" "$RUCIO_ACCOUNT" > $alrb_rseWorkdir/quota.txt 2>&1 
    if [ $? -ne 0 ]; then
	\echo "Error getting quota for $alrb_RseName"
	return 64
    fi
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_getDidReplicas() 
#!----------------------------------------------------------------------------
{
    \rm -f $alrb_rseWorkdir/replicas.txt
    rucio list-file-replicas $alrb_DidName > $alrb_rseWorkdir/replicas.txt
    if [ $? -ne 0 ]; then
	\echo "Error getting replicas for $alrb_DidName"
	return 64
    fi
    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_getInput() 
#!----------------------------------------------------------------------------
{

    local alrb_result=""
    local alrb_candInput=""

    if [ $# -eq 0 ]; then
	if [ "$alrb_SkipDiaglog" = "NO" ]; then
	    \echo " "
	    \echo "What is the RSE or DID to check ?  
 If the RSE is not SCRATCHDISK USERDISK or LOCALGROUPDISK 
 on which you have a quota, then you need to specify a DID instead"
	    \echo -n "RSE or DID ? "
	    read alrb_candInput
	else
	    \echo "Failed: skipConfirm specified and I need a talk to a human !"
	    return 64
	fi
    else
	alrb_candInput=$1
    fi

    if [ "$alrb_candInput" = "" ]; then
	alrb_fn_getInput
	return $?
    fi

    alrb_result=`\echo $alrb_candInput | \grep -e "\*"`
    if [ $? -eq 0 ]; then
	\echo "Error: Wildcards are not allowed."
	alrb_fn_getInput
	return $?
    fi

    alrb_result=`\echo $alrb_candInput | \grep -e "\."`
    if [ $? -ne 0 ]; then
	alrb_fn_checkRSE $alrb_candInput 
	return $?
    else
	alrb_fn_checkDID $alrb_candInput 
	return $?
    fi

    return 0

}


#!----------------------------------------------------------------------------
alrb_fn_checkRSE() 
#!----------------------------------------------------------------------------
{

    local alrb_result
    local alrb_candRseName=$1
    alrb_RseName=""

    local alrb_resultAr=( `\grep -i -e "$alrb_candRseName" $alrb_RseListFile` )
    if [ ${#alrb_resultAr[@]} -eq 0 ]; then
	\echo "Error: could not find $alrb_candRseName in the list of RSEs"
	alrb_fn_getInput
	return $?
    elif [ ${#alrb_resultAr[@]} -gt 1 ]; then
	\echo "There is more than one possibility; please choose:"
	\echo ${alrb_resultAr[@]} | \sed -e 's/\ /\n/g'
	alrb_fn_getInput
	return $?
    else
	alrb_RseName=${alrb_resultAr[0]}
	if [ "$alrb_DidName" != "" ]; then
	    alrb_fn_getDidReplicas
	    if [ $? -ne 0 ]; then
		return 64
	    fi
	    alrb_result=`\grep -e "$alrb_RseName" $alrb_rseWorkdir/replicas.txt`
	    if [ "$alrb_result" = "" ]; then
		\echo "Error: $alrb_DidName does not reside at $alrb_RseName"
		\echo "Please choose one of these RSEs :"
		\cat $alrb_rseWorkdir/replicas.txt | \egrep -v "SCOPE" | \egrep -v "\+" | \cut -f 6 -d "|" | \cut -f 1 -d ":"  | env LC_ALL=C \sort -u
		alrb_fn_getInput
		return $?
	    fi
	fi
    fi

    alrb_fn_getRSEQuota
    if [ $? -ne 0 ]; then
	return 64
    else
	alrb_result=`\grep -e "$alrb_RseName" $alrb_rseWorkdir/quota.txt 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_WritePriv="YES"
	else
	    alrb_WritePriv="NO"
	    if [ "$alrb_DidName" = "" ]; then
		\echo "You do not have write access ar $alrb_RseName"
		\echo " so you need to specify a DID that resides there.  Please retry."
		alrb_fn_getInput
		return $?
	    fi
	fi
    fi    

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_checkDID()
#!----------------------------------------------------------------------------
{
    local alrb_candDidName=$1
    alrb_DidName=""

    local alrb_rucioStat="$alrb_rseWorkdir/rucio.statfile"
    \rm -f $alrb_rucioStat
    rucio stat $alrb_candDidName 2>&1 > $alrb_rucioStat
    if [ $? -ne 0 ]; then
	cat $alrb_rucioStat
	\echo "Error: rucio stat returned an error"
	return 64
    fi

    local alrb_result=`grep -i type $alrb_rucioStat | \cut -f 2 -d ":" | \sed -e 's/ //g' |  \tr '[:lower:]' '[:upper:]'`
    if [ "$alrb_result" != "FILE" ]; then
	\echo " $alrb_candDidName is not a file."
	\echo " It is a $alrb_result"
	\echo " Please specify a file instead."
        alrb_fn_getInput
	return $?
    fi	
    alrb_DidName=$alrb_candDidName

    if [ "$alrb_RequestedRseName" = "" ]; then
	local alrb_resultAr=( `rucio list-file-replicas $alrb_DidName | \egrep -v "\+" | \egrep -v "SCOPE" | \egrep -v "TAPE" | \cut -f 6 -d "|" | \cut -f 1 -d ":" | env LC_ALL=C \sort -u | \sed -e 's/ //g'` )
    else
	local alrb_resultAr=( `rucio list-file-replicas $alrb_DidName | \grep -e $alrb_RequestedRseName | \cut -f 6 -d "|" | \cut -f 1 -d ":" | env LC_ALL=C \sort -u | \sed -e 's/ //g'` )
    fi
    if [ ${#alrb_resultAr[@]} -gt 1 ]; then
	\echo "There is more than one possibility; please choose from:"
	\echo ${alrb_resultAr[@]} | \sed -e 's/\ /\n/g'
	alrb_fn_getInput
	return $?
    elif [ ${#alrb_resultAr[@]} -eq 1 ]; then
	alrb_fn_checkRSE "${alrb_resultAr[0]}"
	return $?
    else
	\echo "Error: rucio did $alrb_DidName does not seem to exist"
	return 64
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_getProxy() 
#!----------------------------------------------------------------------------
{
    local alrb_doProxy=""
    local alrb_result

    voms-proxy-info -exists > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	alrb_doProxy="Y"
    else
	alrb_result=`voms-proxy-info --actimeleft 2>&1 | \grep -e "^[0-9]*$"`
	if [[ $? -ne 0 ]] || [[ "$alrb_result" = "" ]]; then
	    alrb_doProxy="Y"
	fi
    fi

    if [ "$alrb_doProxy" = "Y" ]; then
	\echo ""
	\echo "Getting a valid proxy ..."
	voms-proxy-init -voms atlas
	if [ $? -ne 0 ]; then
	    return 64
	fi
    fi

    voms-proxy-info -all > $alrb_rseWorkdir/proxyInfo.out 2>&1
    \cat $alrb_rseWorkdir/proxyInfo.out

     alrb_result=`\grep -e "nickname" $alrb_rseWorkdir/proxyInfo.out 2>&1`
     if [ $? -ne 0 ]; then
	 \echo "Error: nickname is missing in proxy"
	 return 64
     else
	 alrb_nickname=`\echo $alrb_result | \sed -e 's/.*=[\ ]*//g' | \cut -f 1 -d " "`
     fi

     if [ -z $RUCIO_ACCOUNT ]; then
	 \echo "Setting RUCIO_ACCOUNT=$alrb_nickname"
	 export RUCIO_ACCOUNT=$alrb_nickname
     elif [ "$RUCIO_ACCOUNT" != "$alrb_nickname" ]; then
	 \echo "Error: \$RUCIO_ACCOUNT ($RUCIO_ACCOUNT)  != voms nickname ($alrb_nickname) "
	 return 64
     fi

     \echo "
rucio whoami ..."
     rucio whoami

     \echo "
rucio-admin account list-identities $RUCIO_ACCOUNT ..."
     rucio-admin account list-identities $RUCIO_ACCOUNT

     \echo "
rucio scope ..."
     rucio-admin scope list | \grep -e "$RUCIO_ACCOUNT"
     if [ $? -ne 0 ]; then
	 \echo "Error: rucio could not find scope for $RUCIO_ACCOUNT"
     fi    


    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_uploadFile() 
#!----------------------------------------------------------------------------
{
    if [ "$alrb_WritePriv" != "YES"  ]; then
	\echo "Skipping rucio upload for $alrb_RseName"
	alrb_SkipTest="YES"
	return 0
    fi

    \mkdir -p $alrb_rseWorkdir/upload
    local alrb_uploadFile="$alrb_rseWorkdir/upload/test.$alrb_Uuidgen"
    cp $alrb_RseListFile $alrb_uploadFile
    \echo "rucio upload --scope user.$RUCIO_ACCOUNT --rse $alrb_RseName $alrb_uploadFile"
    rucio upload --scope user.$RUCIO_ACCOUNT --rse $alrb_RseName $alrb_uploadFile
    return $?
}


#!----------------------------------------------------------------------------
alrb_fn_listFile() 
#!----------------------------------------------------------------------------
{
    local let alrb_exitCode0=0
    local let alrb_rc=0

    if [ "$alrb_UploadedFileName" != "" ]; then
	\echo "rucio list-dids $alrb_UploadedFileName"
	rucio list-dids $alrb_UploadedFileName
	alrb_rc=$?
	alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
    fi

    if [ "$alrb_DidName" != "" ]; then
	\echo " "
	local alrb_listFile=$alrb_DidName
	\echo "rucio get-metadata $alrb_listFile"
	\rm -f $alrb_rseWorkdir/metadata.txt
	rucio get-metadata $alrb_listFile > $alrb_rseWorkdir/metadata.txt 2>&1 
	\cat $alrb_rseWorkdir/metadata.txt
	\echo " "
	\echo "rucio list-dids $alrb_DidName"
	rucio list-dids $alrb_DidName
	alrb_rc=$?
	alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))

	alrb_Turl=""
	\echo " "
	\echo "rucio list-file-replicas --rse $alrb_RseName $alrb_DidNam"
	rucio list-file-replicas --rse $alrb_RseName $alrb_DidName > $alrb_rseWorkdir/fileReplicas.txt 2>&1
	alrb_rc=$?
	alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	\cat $alrb_rseWorkdir/fileReplicas.txt
	if [ $alrb_rc -eq 0 ]; then
	    alrb_Turl=`\grep -e $alrb_RseName $alrb_rseWorkdir/fileReplicas.txt | \sed -e 's/.*: //' | \cut -f 1 -d " "`
	    if [ "$alrb_Turl" != "" ]; then
		\echo " "
		\echo "gfal-ls -lt $alrb_GfalTimeout $alrb_Turl"
		gfal-ls -lt $alrb_GfalTimeout $alrb_Turl
		alrb_rc=$?
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	fi
    fi

    return $alrb_exitCode0
}


#!----------------------------------------------------------------------------
alrb_fn_getFile() 
#!----------------------------------------------------------------------------
{
    local alrb_tmpVal
    local let alrb_exitCode0=0
    local let alrb_rc=0

    \mkdir -p $alrb_rseWorkdir/get

    if [ "$alrb_UploadedFileName" != "" ]; then
	\echo "rucio get --dir $alrb_rseWorkdir/get --rse $alrb_RseName $alrb_UploadedFileName $alrb_protocol"
	rucio get --dir $alrb_rseWorkdir/get --rse $alrb_RseName $alrb_UploadedFileName $alrb_protocol
	alrb_rc=$?
	alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
    fi

    if [ "$alrb_DidName" != "" ]; then
 
	\echo " "
	local let alrb_nBytes=`\grep -e "bytes:" $alrb_rseWorkdir/metadata.txt | \cut -f 2 -d ":"`
	if [ $? -ne 0 ]; then
	    return 64
	fi

	local let alrb_nMBytes=`expr $alrb_nBytes / 1024000`
	\echo "File to fetch is $alrb_nMBytes MB"
	if [ $alrb_nMBytes -gt $alrb_MaxGetFileSize ]; then
	    \echo "File to get is $alrb_nMBytes MB >  $alrb_MaxGetFileSize MB"
	    if [ "$alrb_SkipDiaglog" = "NO" ]; then
		read -r -p "Continue to get file ? [y/N]" alrb_tmpVal
		case $alrb_tmpVal in
		    [yY][eE][sS]|[yY]) 
			;;
		    *)
			alrb_SkipTest="YES"
			\echo "Skipping rucio get."
			return $alrb_exitCode0
		esac
	    fi
	fi	
	\echo "rucio get --dir $alrb_rseWorkdir/get --rse $alrb_RseName $alrb_DidName $alrb_protocol"
	rucio get --dir $alrb_rseWorkdir/get --rse $alrb_RseName $alrb_DidName $alrb_protocol
	alrb_rc=$?
	alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))

	if [[ $alrb_rc -ne 0 ]] && [[ "$alrb_Turl" != "" ]]; then
	    \echo " "
	    \echo " "
	    \mkdir -p $alrb_rseWorkdir/gfalCopy
	    \echo "gfal-copy -t $alrb_GfalTimeout $alrb_Turl file://$alrb_rseWorkdir/gfalCopy/test.file"
	    gfal-copy -t $alrb_GfalTimeout $alrb_Turl file://$alrb_rseWorkdir/gfalCopy/test.file
	    alrb_rc=$?
	    alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))	    
	fi

    fi

    return $alrb_exitCode0
}


#!----------------------------------------------------------------------------
alrb_fn_eraseFile() 
#!----------------------------------------------------------------------------
{

    if [ "$alrb_UploadedFileName" = "" ]; then
	\echo "Skipping rucio erase for $alrb_RseName"
	alrb_SkipTest="YES"
	return 0
    fi
    \echo "rucio erase $alrb_UploadedFileName"
    rucio erase $alrb_UploadedFileName
    return $?
}


#!----------------------------------------------------------------------------
alrb_fn_checkSiteStatus() 
#!----------------------------------------------------------------------------
{
    local alrb_result
    \rm -f $alrb_rseWorkdir/siteInfo
    agis-list-ddmendpoints -d $alrb_RseName | \egrep -v "^#" | \tr -s " " > $alrb_rseWorkdir/siteInfo
    local alrb_tier=`\cat $alrb_rseWorkdir/siteInfo | \cut -f 7 -d " "`
    if [ "$alrb_tier" = "3" ]; then
	\echo " "
	\echo "Warning: Site is a Tier3 and may not be completely accessible"
    fi
    local alrb_siteName=`\cat $alrb_rseWorkdir/siteInfo | \cut -f 4 -d " "`
    agis-list-downtimes -s $alrb_siteName > $alrb_rseWorkdir/downtime.txt 2>&1 
    alrb_result=`\grep -e "NO matches found" $alrb_rseWorkdir/downtime.txt`
    if [ $? -ne 0 ]; then 
	\echo " "
	\echo "Found possible information for services that could affect $alrb_RseName:"
	\cat $alrb_rseWorkdir/downtime.txt
	\echo " "
	\echo "These are not definitive and you should read the above description to be sure."
	alrb_altStatus="*READ*"
	return 64
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_accessSE() 
#!----------------------------------------------------------------------------
{

    local alrb_rc=0

    local alrb_getProtocolScript="$alrb_rseWorkdir/getSEReadProtocol.py"
    \rm -f $alrb_getProtocolScript

# at this point, we have a valid RSE so minimal checks ... 
    \cat <<EOF > $alrb_getProtocolScript
#! /usr/bin/env python

import sys
rseSite = sys.argv[1]

from rucio.client.rseclient import RSEClient
client = RSEClient()
rseinfo = client.get_rse(rseSite)
protocolList = rseinfo['protocols']
for protocol in sorted(protocolList, key=lambda k: k['domains']['wan']['read']):

  thePriority = protocol['domains']['wan']['read']
  if thePriority == 0 : 
    continue

  if protocol['port'] != None :
    port = ':' + str(protocol['port'])
  else:
    port=''

  if protocol['scheme'] == 'davs':
    print("webdav|davs://%s%s%s" % 
          (
           protocol['hostname'], 
           port,
           protocol['prefix']
           ))

  elif protocol['scheme'] == 'root':  
    print("root|root://%s%s%s" % 
          (
           protocol['hostname'], 
           port,
           protocol['prefix']
           ))

  elif protocol['scheme'] == 'srm':  
    print("srm|srm://%s%s%s%s" % 
          (
           protocol['hostname'], 
           port,
           protocol['extended_attributes']['web_service_path'],
           protocol['prefix']
           ))

  elif protocol['scheme'] == 'gsiftp':  
    print("gsiftp|gsiftp://%s%s%s" % 
          (
           protocol['hostname'], 
           port,
           protocol['prefix']
           ))

  else:
    print('Error|unknown protocol %s' % protocol['scheme'])
EOF
    chmod +x $alrb_getProtocolScript 
    
    local alrb_oldifs="$IFS"
    IFS=$'\n'
    local alrb_testAr=( `$alrb_getProtocolScript $alrb_RseName` )
    IFS="$alrb_oldifs"

    if [ ${#alrb_testAr[@]} -le 0 ]; then
	\echo "Error: unable to obtain WAN read protocols from rucio for $alrb_RseName"
	return 64
    fi

    \echo " "
    \echo "WAN read protocol priority:"
    local alrb_item
    for alrb_item in "${alrb_testAr[@]}"; do
	\echo $alrb_item | \sed -e 's/|/ : /'
    done
    \echo " "

    local alrb_primaryAccess="${alrb_testAr[0]}"
    local alrb_protocol=`\echo $alrb_primaryAccess | \cut -f 1 -d "|"`
    local alrb_url=`\echo $alrb_primaryAccess | \cut -f 2 -d "|"`

    if [ "$alrb_protocol" = "Error" ]; then
	\echo "Error: unable to understand primary protocol."
	return 64
    fi

    \echo "Checking protocol $alrb_protocol $alrb_url ..."
    
    \echo "gfal-ls timeout set to $alrb_GfalTimeout s ..."
    \echo "gfal-ls -t $alrb_GfalTimeout $alrb_url ..."
    gfal-ls -t $alrb_GfalTimeout $alrb_url
    local alrb_rc=$?

    if [[ $alrb_rc -ne 0 ]] && [[ "$alrb_protocol" = "gsiftp" ]]; then
	\echo " "
	\echo "Doing access check with uberftp ..."
	local alrb_tmpVal=`\echo $alrb_url | \sed -e 's|gsiftp://||' | \cut -f 1 -d "/"`
	local alrb_host=`\echo $alrb_tmpVal | \cut -f 1 -d ":"`
	local alrb_result=`\echo $alrb_tmpVal | \grep -e ":" 2>&1`
	if [ $? -eq 0 ]; then
	    local alrb_port=`\echo $alrb_tmpVal | \cut -f 2 -d ":"`
	else
	    local alrb_port="2811"
	fi
	\echo "uberftp -P $alrb_port $alrb_host quit"
	timeout $alrb_GfalTimeout uberftp -P $alrb_port $alrb_host quit
	if [ $? -eq 0 ]; then
	    \echo "ubeftp acccess worked."
	    alrb_altStatus="*READ*"
	else
	    \echo "uberftp access also failed."
	fi
	\echo " "

    fi

    return $alrb_rc

}


#!----------------------------------------------------------------------------
alrb_fn_listRSEQuota() 
#!----------------------------------------------------------------------------
{
    \echo "rucio list-account-usage --rse $alrb_RseName $RUCIO_ACCOUNT ..."
    rucio list-account-usage --rse "$alrb_RseName" "$RUCIO_ACCOUNT"

#    \echo "rucio list-rse-usage $alrb_RseName ..."
#    rucio list-rse-usage "$alrb_RseName"
    \echo "rucio-admin rse info $alrb_RseName ..." 
    rucio-admin rse info "$alrb_RseName"

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_cleanup() 
#!----------------------------------------------------------------------------
{
    if [ "$alrb_rseWorkdir" != "" ]; then
	\rm -rf $alrb_rseWorkdir
    fi
    return 0
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

let alrb_ThisStep=0
alrb_RseListFile=""
alrb_RseName=""
alrb_RequestedRseName=""
alrb_DidName=""
alrb_SummaryAr=()
alrb_Uuidgen=`uuidgen`
alrb_UploadedFileName=""

alrb_WritePriv="NO"
alrb_SkipDiaglog="NO"
alrb_SkipTest="NO"
alrb_TestDescription=""
alrb_altStatus=""
alrb_protocol=""

alrb_shortopts="h,g:,t:,r:,p:,s" 
alrb_longopts="help,timeout:,getLimit:,rse:,protocol:,skipConfirm"
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
            alrb_fn_checkRucioRSEHelp
            exit 0
            ;;
	-g|--getLimit) 
	    if [[ "$2" =~ ^[0-9]+$ ]]; then		
		let alrb_MaxGetFileSize=$2		
		if [ $alrb_MaxGetFileSize -le 0 ]; then
		    \echo "Error: integer > 0 expected for -g option"
		    exit 64
		fi
	    else
		\echo "Error: integer > 0 expected for -g option"
		exit 64
	    fi
	    shift 2
	    ;;
	-t|--timeout) 
	    if [[ "$2" =~ ^[0-9]+$ ]]; then		
		let alrb_GfalTimeout=$2		
		if [ $alrb_GfalTimeout -le 0 ]; then
		    \echo "Error: integer > 0 expected for -t option"
		    exit 64
		fi
	    else
		\echo "Error: integer > 0 expected for -t option"
		exit 64
	    fi
	    shift 2
	    ;;
        -r|--rse)
	    alrb_RequestedRseName=$2
	    shift 2
	    ;;
	-p|--protocol) 
	    alrb_protocol="--protocol $2"
	    shift 2
	    ;;
        -s|--skipConfirm)
            alrb_SkipDiaglog="YES"
            shift 
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

if [ -z $ATLAS_LOCAL_ROOT_BASE ]; then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

alrb_myArgs="$*"

\echo "
**************************************************************************
 `date -u`
 rseCheck running on " `hostname -f`"
**************************************************************************
"

let alrb_exitCodeNow=0
alrb_fn_initSummary "Setup the environment"
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh -q
lsetup rucio agis

\mkdir -p ${ALRB_tmpScratch}/checkRSE
if [ $? -ne 0 ]; then
    let alrb_exitCodeNow=1
else
    alrb_rseWorkdir=`\mktemp -d ${ALRB_tmpScratch}/checkRSE/testXXXXXX 2>&1`
    if [ $? -ne 0 ]; then
	let alrb_exitCodeNow=1
    fi
fi
alrb_fn_addSummary $alrb_exitCodeNow "exit"


alrb_fn_initSummary "Get proxy"
alrb_fn_getProxy
alrb_fn_addSummary $? "exit"


alrb_fn_initSummary "Get RSE List"
alrb_fn_getRSEList
alrb_fn_addSummary $? "exit"


if [ "$alrb_RequestedRseName" != "" ]; then
    alrb_fn_initSummary "Check Requested RSE"
    alrb_resultAr=( `\grep -i -e "$alrb_RequestedRseName" $alrb_RseListFile` )
    if [ ${#alrb_resultAr[@]} -gt 1 ]; then
	\echo "Error: Requested rse $alrb_RequestedRseName is not unique. Possibilities:"
	\echo ${alrb_resultAr[@]} | \sed -e 's/\ /\n/g'
	false
    elif [ ${#alrb_resultAr[@]} -eq 0 ]; then
	\echo "Error: Requested rse $alrb_RequestedRseName does not exist."
	false
    fi
    alrb_fn_addSummary $? "exit"
fi


alrb_fn_initSummary "Validate the RSE"
if [ $# -eq 0 ]; then
    alrb_tmpVal="$alrb_RequestedRseName"
else
    alrb_tmpVal=$1
fi
alrb_fn_getInput "$alrb_tmpVal"
alrb_fn_addSummary $? "exit"


alrb_fn_initSummary "RSE quota and limits"
alrb_fn_listRSEQuota
alrb_fn_addSummary $? "continue"


alrb_fn_initSummary "Check if site is in downtime"
alrb_fn_checkSiteStatus
alrb_fn_addSummary $? "continue"


alrb_fn_initSummary "Test SE access"
alrb_fn_accessSE
#alrb_fn_addSummary $? "exit"
alrb_fn_addSummary $? "continue"


alrb_fn_initSummary "Test rucio upload"
alrb_fn_uploadFile
alrb_rc=$?
if [[ $alrb_rc -eq 0 ]] && [[ "$alrb_WritePriv" = "YES"  ]]; then
    alrb_UploadedFileName="user.$RUCIO_ACCOUNT:test.$alrb_Uuidgen"
else
    alrb_UploadedFileName=""
fi
if [ "$alrb_DidName" = "" ]; then
    alrb_fn_addSummary $alrb_rc "exit"
else
    alrb_fn_addSummary $alrb_rc "continue"
fi

alrb_fn_initSummary "Test rucio list-files"
alrb_fn_listFile
alrb_fn_addSummary $? "continue"


alrb_fn_initSummary "Test rucio get"
alrb_fn_getFile
alrb_fn_addSummary $? "continue"


alrb_fn_initSummary "Test rucio erase"
alrb_fn_eraseFile
alrb_fn_addSummary $? "continue"


alrb_fn_printSummary

alrb_fn_cleanup



