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
    set alrb_tmpVal=`env | \grep RUCIO_ACCOUNT`
    if  ( ( $? != 0 )  && ( $?RUCIO_ACCOUNT ) ) then
	\echo " rucio:"
	\echo "   Warning: RUCIO_ACCOUNT was defined but not exported."
	\echo "    Exporting it now ..."
	setenv RUCIO_ACCOUNT $RUCIO_ACCOUNT
    endif
endif
unset alrb_tmpVal
