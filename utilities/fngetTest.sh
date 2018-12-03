#! /bin/bash
#!----------------------------------------------------------------------------
#!
#!  fngetTest.sh
#!
#!  This tests your frontier/squid access
#!
#!  Usage:
#!      fngetTest.sh
#!
#!  History:
#!    05May2010: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_progname=fngetTest.sh

#!----------------------------------------------------------------------------
alrb_fn_fngetTestHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: db-fnget [options]

    This application checks each server and proxy that is configured for 
    Frontier/Squid access.  
  
    Options (to override defaults) are:
     -h  --help               Print this help message

EOF
}


#!----------------------------------------------------------------------------
alrb_fn_cleanup()
#!----------------------------------------------------------------------------
{
    if [ "$$alrb_workdir" != "" ]; then
	\rm -rf $alrb_workdir
    fi

    return 0
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h" 
alrb_longopts="help"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_fngetTestHelp
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

mkdir -p $ALRB_SCRATCH/Frontier
alrb_workdir=`\mktemp -d $ALRB_SCRATCH/Frontier/fngetXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "Error: unable to create fir in $ALRB_SCRATCH/Frontier"
    exit 64
fi
cd $alrb_workdir

if [ -z $FRONTIER_SERVER ]; then
    \echo "Error: Frontier / squid is not defined on this machine."
    \echo " setup a release first, eg " 
    \echo "  asetup 20.20.6.3,here"
    \echo " and then rerun db-fnget"
    \echo -e "fngetTest                                                  "'[\033[31mFAILED\033[0m]'
    alrb_fn_cleanup
    exit 64
fi

alrb_testResults=()

alrb_myInfo=( `\echo $FRONTIER_SERVER | \sed -e 's/[()]/ /g'` )

alrb_myServers=()
alrb_myProxies=()

for alrb_item in ${alrb_myInfo[@]}; do
    alrb_myRHS=`\echo $alrb_item | \cut -d "=" -f 1`
    alrb_myLHS=`\echo $alrb_item | \cut -d "=" -f 2`
    if [ "$alrb_myRHS" = "serverurl" ]; then
	alrb_myLHS="$alrb_myLHS/Frontier"
	alrb_myServers=( ${alrb_myServers[@]} $alrb_myLHS )
    elif [ "$alrb_myRHS" = "proxyurl" ]; then 
	alrb_myProxies=( ${alrb_myProxies[@]} $alrb_myLHS )
    fi
done
let alrb_nProxies=${#alrb_myProxies[@]}
let alrb_nServers=${#alrb_myServers[@]}

if [ $alrb_nServers -eq 0 ]; then
    \echo "Error: There are no servers defined in FRONTIER_SERVER !"
    \echo -e "fngetTest                                                  "'[\033[31mFAILED\033[0m]'
    alrb_fn_cleanup
    exit 64
fi

\rm -f fnget.py
$ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh http://frontier.cern.ch/dist/fnget.py

let alrb_failures=0
let alrb_success=0
for alrb_myserver in ${alrb_myServers[@]}; do

    if [ $alrb_nProxies -eq 0 ]; then
	\echo "
******************************************************************************
  Testing:
     server : $alrb_myserver
     (no proxy)
******************************************************************************
"
	python fnget.py --url=$alrb_myserver --sql="select 1 from dual"
	if [ $? -ne 0 ]; then
	    let alrb_failures+=1
	    alrb_testResults=( ${alrb_testResults[@]} "FAILED#$alrb_myserver#" ) 
	else
	    alrb_testResults=( ${alrb_testResults[@]} "OK#$alrb_myserver#" ) 
	    let alrb_success+=1
	fi

    else
	for alrb_myproxy in ${alrb_myProxies[@]}; do
	    \echo "
******************************************************************************
  Testing:
     server : $alrb_myserver
     proxy  : $alrb_myproxy
******************************************************************************
"
	    export http_proxy=$alrb_myproxy
	    python fnget.py --url=$alrb_myserver --sql="select 1 from dual"
	    if [ $? -ne 0 ]; then
		let alrb_failures+=1
		alrb_testResults=( ${alrb_testResults[@]} "FAILED#$alrb_myserver#$alrb_myproxy" ) 
	    else
		let alrb_success+=1
		alrb_testResults=( ${alrb_testResults[@]} "OK#$alrb_myserver#$alrb_myproxy" ) 
	    fi
	done
    fi

done

if [ ${#alrb_testResults[@]} -gt 0 ]; then
    \echo  "

*******************************************************************************
Summary
*******************************************************************************
"
fi
for alrb_item in "${alrb_testResults[@]}"; do
    alrb_status=`\echo $alrb_item | \cut -d "#" -f 1`
    alrb_server=`\echo $alrb_item | \cut -d "#" -f 2`
    alrb_proxy=`\echo $alrb_item | \cut -d "#" -f 3`
    printf "\n%-10s\n Server: %-70s\n Proxy : %-70s\n" "$alrb_status" "$alrb_server" "$alrb_proxy"
done
\echo " "

if [ $alrb_failures -ne 0 ]; then
    \echo "
... $alrb_failures failures seen, $alrb_success success ..."
    \echo -e "fngetTest                                                  "'[\033[31mFAILED\033[0m]'
else
    \echo "
... $alrb_failures failures seen, $alrb_success success ..."
    \echo -e "fngetTest                                                  "'[\033[32m  OK  \033[0m]'
fi


\echo "
*******************************************************************************
What to expect if there are no problems:
  0 failures, all success.  
   (some failures may be ok / expected but the majority should succeed.)
  At the end of the output above, 'fngetTest [OK]'  
*******************************************************************************
"

alrb_fn_cleanup

exit 0

