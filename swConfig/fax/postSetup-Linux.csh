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

if ( -e "$FAXtoolsDir/bin/fax-run-test" ) then
    alias testFAX '$FAXtoolsDir/bin/fax-run-test -a'
    if ( "$alrb_Quiet" != "YES" ) then
	\echo " fax:"
	setenv ALRB_menuFmtSkip "YES"
	$ATLAS_LOCAL_ROOT_BASE/swConfig/printMenu.sh fax 2
	unsetenv ALRB_menuFmtSkip
    endif
endif

\echo -e "\
*******************************************************************************\
\033[1m\033[4mFAX is depreciated\033[0m and will be removed soon. \
Please use rucio and xrootd protocol:\
  rucio list-file-replicas --protocol root --pfns <did> \
and you may find xcache useful \
  https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Xcache\
*******************************************************************************\
"
