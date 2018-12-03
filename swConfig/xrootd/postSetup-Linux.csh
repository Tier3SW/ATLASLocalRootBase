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
    # eg root built with xrootd3 has issues with xrootd4 so warn major changes
    if ( ( "$alrb_XrootdRootFromAthena" != "YES" ) && $?ROOTSYS && $?alrb_rootXrdMinVer ) then
	set alrb_xrdVerMin=`\echo $alrb_rootXrdMinVer | \cut -f 1 -d "."`
	    set alrb_xrdVerCur=`\echo $ATLAS_LOCAL_XROOTD_VERSION | \cut -f 1 -d "."`
	if ( $alrb_xrdVerMin == 3 && $alrb_xrdVerMin != $alrb_xrdVerCur ) then
	    \echo " xrootd:"
	    \echo "   Warning: root ${ATLAS_LOCAL_CERNROOT_VERSION}:"
	    \echo "            built with xrootd${alrb_xrdVerMin} ($alrb_rootXrdMinVer)"
	    \echo "            but you have setup xrootd${alrb_xrdVerCur}."
	endif
    endif
    unset alrb_xrdVerMin alrb_xrdVerCur alrb_XrootdRootFromAthena
endif
