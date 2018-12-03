#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! getOSType.sh
#!
#! A simple script to print out the OS type and version of the machine
#!
#! Usage:
#!     getOSType.sh
#! return 
#!   Linux|MacOSX OSMajorVersion OSMinorVersion
#!
#! History:
#!    14Mar14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# default
alrb_osType="Linux"
alrb_osMajorVer=6
alrb_osMinorVer=4
 
alrb_tmpGLV=`getconf  GNU_LIBC_VERSION 2>&1`
if [ $? -eq 0 ]; then
    alrb_osType="Linux"
    alrb_glv="`\echo $alrb_tmpGLV | \awk '{print $NF}' | \awk -F. '{printf "%d%02d", $1, $2}'`"
    if [ $alrb_glv -le 205 ] ; then
	alrb_osMajorVer=5
    elif [ $alrb_glv -le 216 ] ; then
	alrb_osMajorVer=6
    else
	alrb_osMajorVer=7
    fi
    alrb_lsbRelease="`which lsb_release 2>/dev/null`"
    if [[ -s "$alrb_lsbRelease" ]] && [[ -e /etc/redhat-release ]] ; then
	alrb_osMinorVer=`$alrb_lsbRelease -r | \awk '{print $2}' | \cut -d "." -f 2`
    elif [ -e /etc/redhat-release ]; then
	alrb_osMinorVer=`\cat /etc/redhat-release | \sed -e 's/[[:alpha:]*\(\)\ ]//g' | \cut -f 2 -d '.'`
    fi
    \echo "$alrb_osType $alrb_osMajorVer $alrb_osMinorVer"
    exit 0
fi

# Mac (BSD); ignore the "10" 
alrb_result=`which sw_vers 2>&1`
if [ $? -eq 0 ]; then
    alrb_osType=`sw_vers -productName | \sed -e 's/ //g'`
    alrb_osMajorVer=`sw_vers -productVersion | \cut -f 2 -d "."`
    alrb_osMinorVer=`sw_vers -productVersion | \cut -f 3 -d "."`
    \echo "$alrb_osType $alrb_osMajorVer $alrb_osMinorVer"
    exit 0
fi

\echo "$alrb_osType $alrb_osMajorVer $alrb_osMinorVer"
exit 0