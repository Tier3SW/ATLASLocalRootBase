#! /bin/bash
#!----------------------------------------------------------------------------
#! 
#! checkGridUse.sh
#!
#! Checks for existence of grid software to determine what should be used
#!  Note: order of checks is important here;
#!    the default used is based on this ordering.
#!
#! Usage: 
#!     checkGridUse.sh
#!       returns the number of middleware and what is found.
#!       This must be run after ALRB_tmpScratch is defined
#!
#! History:
#!   09Feb10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


let alrb_count=0
alrb_found=""

alrb_existsEmi="NO"
alrb_rpmInstalled="NO"

if [ ! -z $ATLAS_LOCAL_EMI_VERSION ];then
    alrb_existsEmi="YES"
    alrb_found="$alrb_found emi"
    let alrb_count++
#elif [ ! -z $LCG_LOCATION ]; then
#    alrb_rpmInstalled="YES"
#    if [ -e /etc/emi-version ]; then
#	alrb_existsEmi="YES"
#	alrb_found="$alrb_found emi"
#	let alrb_count++	
#    fi
# if not standard locations, unset this 
    if [ "$alrb_found" = "" ]; then
	alrb_rpmInstalled="NO"
    fi
fi

if [ "$alrb_rpmInstalled" = "NO" ]; then

# first one will be the default if it exists

# emi
    if [ $"$alrb_existsEmi" = "NO" ]; then
	source $ATLAS_LOCAL_ROOT_BASE/swConfig/functions.sh
	alrb_fn_getToolVersion emi "" "" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    alrb_existsEmi="YES"
	    alrb_found="$alrb_found emi"
	    let alrb_count++
	fi
    fi
    
fi

alrb_result=`\echo "$alrb_count $alrb_found" | \sed -e 's/ [ ]*/ /g'`

\echo "$alrb_result" 


