#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup sft for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------
 
set alrb_listPackages=()
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
foreach alrb_item ($alrb_tmpAr:q)
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
	case cmt:
	    set alrb_sftCmtConfig=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	case pkg:
	    set alrb_tmpVal=`\echo $alrb_item | \cut -f 2 -d "="`
	    set alrb_listPackages=( $alrb_listPackages:q "$alrb_tmpVal" )
	    breaksw
	default:
	    breaksw
    endsw
end

set alrb_result=`(python -V > /dev/tty) |& \awk '{print $2}'`
set alrb_thisPython=`\echo $alrb_result | \cut -f 2 -d " " | \cut -f 1-2 -d "."`

set alrb_abort="NO"
set alrb_listPackagesSetup=()
foreach alrb_item ($alrb_listPackages:q)
    set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/sft//navigateSFT.sh $alrb_item $alrb_sftCmtConfig $alrb_thisPython`
    if ( $? != 0 ) then
	\echo "  Error: $alrb_result" > /dev/stderr
	set alrb_abort="YES"
    else
	set alrb_result="P%$alrb_item|$alrb_result"
	set alrb_listPackagesSetup=( $alrb_listPackagesSetup:q "$alrb_result" )
    endif
end
if ( "$alrb_abort" == "YES" ) then
    exit 64
endif

set alrb_sftPostPrintAr=() 
foreach alrb_item ($alrb_listPackagesSetup:q)
    set alrb_fullPath="error !"
    @ alrb_idx=1
    set alrb_mySetup=`\echo $alrb_item | \cut -d "|" -f $alrb_idx`
    while ( "$alrb_mySetup" != "" )
	set alrb_action=`\echo $alrb_mySetup | \cut -f 1 -d "%"`
	if ( "$alrb_action" == "P" ) then
	    set alrb_tmpVal=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    set alrb_fullPath="$ALRB_SFT_LCG/$alrb_tmpVal/$alrb_sftCmtConfig" 
	else if ( "$alrb_action" == "H" ) then
	    set alrb_name=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    set alrb_name2=`\echo $alrb_name | \sed -e 's|\+|P|g'`
	    set alrb_version=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    set alrb_sftHome="SFT_HOME_$alrb_name2"
	    eval setenv "$alrb_sftHome" "$alrb_fullPath"
	    if ( "$alrb_Quiet" == "NO" ) then
		\echo "  Setting up $alrb_name $alrb_version ..."
		set alrb_tmpVal="${alrb_name}%The env $alrb_sftHome is the home dir"
		set alrb_sftPostPrintAr=( $alrb_sftPostPrintAr:q "$alrb_tmpVal" ) 
	    endif
	else if ( "$alrb_action" == "IP" ) then
	    set alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    set alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    set alrb_tmpVal=`(eval \echo '$'$alrb_key) >& /dev/null`
	    if ( $? == 0 ) then
		eval insertPath $alrb_key "$alrb_fullPath/$alrb_value"    
	    else
		eval setenv $alrb_key "$alrb_fullPath/$alrb_value"
	    endif    
	else if ( "$alrb_action" == "EP" ) then
	    set alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    set alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    eval setenv $alrb_key "$alrb_fullPath/$alrb_value"
	else if ( "$alrb_action" == "EC" ) then
	    if ( "$alrb_Quiet" == "NO" ) then
		set alrb_value=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
		set alrb_tmpVal="${alrb_name}%${alrb_value}"
		set alrb_sftPostPrintAr=( $alrb_sftPostPrintAr:q "$alrb_tmpVal" )
	    endif
	else if ( "$alrb_action" == "S" ) then    
	    set alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    set alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    if ( "$alrb_key" == "$ALRB_SHELL" ) then
		source ${alrb_fullPath}/${alrb_value}
	    endif
	else 
	    \echo "  Error: unknown action $alrb_mySetup" > /dev/stderr
	    \echo "   Please report this.  Continuing ..." > /dev/stderr
	endif
	@ alrb_idx++
	set alrb_mySetup=`\echo $alrb_item | \cut -d "|" -f $alrb_idx`
    end
end

unset alrb_tmpAr alrb_item alrb_sftCmtConfig alrb_thisPython alrb_result alrb_abort alrb_listPackagesSetup alrb_tmpVal alrb_fullPath alrb_idx alrb_mySetup alrb_action alrb_name alrb_name2 alrb_key alrb_value alrb_sftHome


