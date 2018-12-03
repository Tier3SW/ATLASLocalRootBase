#! /bin/bash
#!----------------------------------------------------------------------------
#!
#!  wgetFile.sh
#!
#!  This script will fetch files
#!
#!  Usage:
#!    wgetFile.sh <url>
#!
#!  History:
#!    24Apr2014: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if [ $# -ne 1 ]; then
    \echo "Error: incorrect arguments ..."
    \echo "Usage: `basename $0` <URL>"
    exit 64
fi

alrb_result=`which wget 2>&1`
alrb_rc=$?
if [ $alrb_rc -eq 0 ]; then
    wget $1
    alrb_rc=$?
    if [ $alrb_rc -ne 0 ]; then
	alrb_tmpVal=`\echo $1 | \grep -e "https"`
	if [ $? -eq 0 ]; then
# we have to trust what ALRB installs since some HPC sites do not work 
#  otherwise witout the no-ckeck-certificate option 
	    \echo "Retrying wget with --no-check-certificate option ..."
	    wget --no-check-certificate $1
	    alrb_rc=$?
	fi
    fi
else
    curl -O $1
    alrb_rc=$?
fi

exit $alrb_rc

