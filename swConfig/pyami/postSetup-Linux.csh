#!----------------------------------------------------------------------------
#!
#!  postSetup.csh
#!
#!    post setup script
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if ( "$alrb_Quiet" == "NO" ) then
    set alrb_amiUsePass="NO"
    \echo " pyami:"
    set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh pyami $ATLAS_LOCAL_PYAMI_VERSION`
    if ( $alrb_tmpVal >=  50000 ) then
      set alrb_amiCfg="$HOME/.pyami/pyami.cfg"
      set alrb_userToken="user"
      set alrb_passToken="pass"
    else
      set alrb_amiCfg="$HOME/.pyami/ami.cfg"
      set alrb_userToken="AMIUser"
      set alrb_passToken="AMIPass"
    endif

    set alrb_amiUserVal=""
    set alrb_amiPassVal=""
    if ( -e $alrb_amiCfg ) then
	set alrb_amiUser=`\grep -e "^$alrb_userToken" $alrb_amiCfg`
	if ( $? == 0 ) then
	    set alrb_amiUserVal=`\echo $alrb_amiUser | \cut -f 2 -d " " | \sed -e 's/ //g'`
	endif
	set alrb_amiPass=`\grep -e "^$alrb_passToken" $alrb_amiCfg`
	if ( $? == 0 ) then
	    set alrb_amiPassVal=`\echo $alrb_amiPass | \cut -f 2 -d " " | \sed -e 's/ //g'`
	endif
    endif

    if ( (  "$alrb_amiUserVal" != "" )  && ( "$alrb_amiPassVal" != "" ) ) then
	set alrb_amiUsePass="YES"
    endif

    if ( "$alrb_amiUsePass" == "YES" ) then
	\echo "   Using authentication information from $alrb_amiCfg"
    else
	\echo "   Using voms proxy for authentication."
    endif

endif

unset alrb_tmpVal alrb_amiUsePass alrb_amiCfg alrb_amiPassVal alrb_amiPass alrb_amiUserVal  alrb_amiUser

	

