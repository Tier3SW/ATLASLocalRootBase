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
    alrb_tmpVal=`env | \grep RUCIO_ACCOUNT`
    if [[ $? -ne 0 ]] && [[ ! -z $RUCIO_ACCOUNT ]] ; then
	\echo " rucio:"
	\echo "   Warning: RUCIO_ACCOUNT was defined but not exported."
	\echo "    Exporting it now ..."
	export RUCIO_ACCOUNT
    fi
fi
unset alrb_tmpVal
