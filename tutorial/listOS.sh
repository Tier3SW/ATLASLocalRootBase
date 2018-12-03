#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! listOS.sh
#!
#! list the OS types and versions for this tutorial
#!
#! Usage:
#!     listOS.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_result=`\grep -e "^OS:" $ALRB_SMUDIR/config.txt 2>&1`
if [ $? -eq 0 ]; then
    alrb_allowedOS=`\echo $alrb_result | \cut -f 2 -d ":"`
fi

alrb_listOS=( `\echo $alrb_allowedOS | \sed -e 's/,/ /g'` )
\echo "Supported OS for this tutorial are : "
for alrb_item in ${alrb_listOS[@]}; do
    alrb_osName=`\echo $alrb_item | \cut -d "=" -f 1`
    alrb_osVer=`\echo $alrb_item | \cut -d "=" -f 2`
    if [ "$alrb_osName" = "RHEL" ]; then
	\echo " RedHat EL compatible (eg SL, SLC, CentOS) version $alrb_osVer"
    elif [ "$alrb_osName" = "MacOS" ]; then
	\echo " MacOS version $alrb_osVer"
    else
	\echo "Error: unknown type defined in config file : $alrb_item"
    fi

done
