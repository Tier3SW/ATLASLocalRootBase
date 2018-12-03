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

if ( ( $?alrb_sftPostPrintAr ) && ( $#alrb_sftPostPrintAr > 0 ) ) then
    if ( "$alrb_Quiet" == "NO" ) then
	\echo " sft:"
	set alrb_lastPkg=""
	foreach alrb_item ($alrb_sftPostPrintAr:q)
	    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "%"`
	    if ( "$alrb_tmpVal" != "$alrb_lastPkg" ) then
		set alrb_lastPkg=$alrb_tmpVal
		\echo "  ${alrb_tmpVal}:"
	    endif
	    set alrb_tmpVal=`\echo $alrb_item | \cut -f 2- -d "%"`            
	    \echo "    $alrb_tmpVal"
	end
    endif
endif
unset alrb_sftPostPrintAr alrb_item alrb_lastPkg alrb_tmpVal


