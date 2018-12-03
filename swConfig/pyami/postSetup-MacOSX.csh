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
    \echo " pyami:"
    set alrb_amiUsePass="NO"
    set alrb_amiCfg="$HOME/.pyami/pyami.cfg"
    set alrb_userToken="user"
    set alrb_passToken="pass"

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
    
    if ( ( "$alrb_amiUserVal" != "" ) && ( "$alrb_amiPassVal" != "" ) ) then
	set alrb_amiUsePass="YES"
    endif

    if ( "$alrb_amiUsePass" == "YES" ) then
	\echo "   Using authentication information from $alrb_amiCfg"
    else
	\echo "   Type 'ami auth' to setup authorization in $alrb_amiCfg"
    endif

endif

unset alrb_amiUsePass alrb_amiCfg alrb_amiPassVal alrb_amiPass alrb_amiUserVal  alrb_amiUser
