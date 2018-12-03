#!----------------------------------------------------------------------------
#!
#!  postSetup.sh
#!
#!    post setup script
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if [ "$alrb_Quiet" = "NO" ]; then
    alrb_amiUsePass="NO"
    \echo " pyami:"
    let alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh pyami $ATLAS_LOCAL_PYAMI_VERSION`
    if [ $alrb_tmpVal -ge 50000 ]; then
	alrb_amiCfg="$HOME/.pyami/pyami.cfg"
	alrb_userToken="user"
	alrb_passToken="pass"
    else
	alrb_amiCfg="$HOME/.pyami/ami.cfg"
	alrb_userToken="AMIUser"
	alrb_passToken="AMIPass"
    fi

    alrb_amiUserVal=""
    alrb_amiPassVal=""
    if [ -e $alrb_amiCfg ]; then
	alrb_amiUser=`\grep -e "^$alrb_userToken" $alrb_amiCfg 2>&1`	
	if [ $? -eq 0 ]; then
	    alrb_amiUserVal=`\echo $alrb_amiUser | \cut -f 2 -d " " | \sed -e 's/ //g'`
	fi
	alrb_amiPass=`\grep -e "^$alrb_passToken" $alrb_amiCfg 2>&1`
	if [ $? -eq 0 ]; then
	    alrb_amiPassVal=`\echo $alrb_amiPass | \cut -f 2 -d " " | \sed -e 's/ //g'`
	fi
    fi

    if [[ "$alrb_amiUserVal" != "" ]] && [[ "$alrb_amiPassVal" != "" ]]; then
	alrb_amiUsePass="YES"
    fi

    if [ "$alrb_amiUsePass" = "YES" ]; then
	\echo "   Using authentication information from $alrb_amiCfg"
    else
	\echo "   Using voms proxy for authentication."
    fi

fi

unset alrb_tmpVal alrb_amiUsePass alrb_amiCfg alrb_amiPassVal alrb_amiPass alrb_amiUserVal  alrb_amiUser
