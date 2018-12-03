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

if [[ ! -z $alrb_sftPostPrintAr ]] && [[ ${#alrb_sftPostPrintAr[@]} -gt 0 ]]; then
    if [ "$alrb_Quiet" = "NO" ]; then
	\echo " sft:"
	alrb_lastPkg=""
	for alrb_item in "${alrb_sftPostPrintAr[@]}"; do
	    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "%"`
	    if [ "$alrb_tmpVal" != "$alrb_lastPkg" ]; then
		alrb_lastPkg=$alrb_tmpVal
		\echo "  $alrb_tmpVal:"
	    fi
	    alrb_tmpVal=`\echo $alrb_item | \cut -f 2- -d "%"`            
	    \echo "    $alrb_tmpVal"
	done
    fi
fi
unset alrb_sftPostPrintAr alrb_item alrb_lastPkg alrb_tmpVal


