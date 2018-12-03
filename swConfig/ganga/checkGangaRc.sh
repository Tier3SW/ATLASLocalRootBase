#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! checkGangaRc.sh
#!
#! Checks the ~/.gangarc file
#!
#! Usage:
#!     checkGangaRc.sh 
#!
#! History:
#!   27Jul15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ -e ~/.gangarc ]; then
    alrb_gangaMajorVer=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $ATLAS_LOCAL_GANGA_VERSION 1`
    alrb_tmpVal=`\grep -e "Ganga-[[:digit:]]" ~/.gangarc 2>&1`
    if [ $? -eq 0 ]; then
	alrb_gangaRcMajorVer=`\echo $alrb_tmpVal | \sed 's/.*Ganga-\([[:digit:]]*\).*/\1/'`	    
	if [ $alrb_gangaRcMajorVer -lt $alrb_gangaMajorVer ]; then
	    \echo "Warning : ~/.gangarc is for an older Ganga version and needs to be regenerated: generateGangarc"
	fi
    else
	\echo "Warning: ~/.gangarc does not seem to have a version."
	\echo "         If you encounter any problems, regenerate it: generateGangarc"
    fi

    alrb_error="NO"
    \grep -e "^EDG_SETUP[ ]*=.*gangaGridSetup.sh"  ~/.gangarc 2>&1 > /dev/null || alrb_error="YES"    
    \grep -e "^GLITE_SETUP[ ]*=.*gangaGridSetup.sh"  ~/.gangarc 2>&1 > /dev/null || alrb_error="YES"
    \grep -e "^setup.*[ ]*=.*gangaDDMSetup.sh"  ~/.gangarc 2>&1 > /dev/null || alrb_error="YES"
    if [ $alrb_error != "NO" ]; then
	\echo "Warning : ~/.gangarc is not properly setup for grid middleware and ddm: generateGangarc"
    fi

    
else
    \echo "Warning: ~/.gangarc is missing.  Please regenerate it: generateGangarc"
fi

