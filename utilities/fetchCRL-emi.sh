#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! fetchCRL-emi.sh
#!
#! A script to fetch the latest crls
#!
#! Usage:
#!     fetchCRL-emi.sh --help
#!
#! History:
#!   23Feb09: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=fetchCRL-emi.sh

#!----------------------------------------------------------------------------
alrb_fn_fetchCRLHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: fetchCRL-emi.sh [options]

    This application will fetch the latest CRL files.

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --force                  Do even if it was run within the past 6 hrs
     -v --verbose             Verbose messages
   
EOF
}


#!----------------------------------------------------------------------------
alrb_fn_extractError()
#!----------------------------------------------------------------------------
{

alrb_idStamp=` \tail -1  $alrb_certLog/fetch-crl-emi.log | \cut -f 1 -d ":"`
alrb_idStamp=`\echo $alrb_idStamp | \sed -e 's/\[/\\\[/g' -e 's/\]/\\\]/g'`
\grep -e "$alrb_idStamp" $alrb_certLog/fetch-crl-emi.log | \grep failed

}

#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

alrb_shortopts="h,v" 
alrb_longopts="help,force,verbose"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_force="NO"
alrb_verbose="NO"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_fetchCRLHelp
            exit 0
            ;;
        --force)
	    alrb_force="YES"
	    shift
            ;;
        -v|--verbose)
	    alrb_verbose="YES"
	    shift
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

if [ -z $ATLAS_LOCAL_ROOT_BASE ]
then
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set"
    exit 64
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

# create the dirs
alrb_securityDir=$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi
alrb_certDir=$alrb_securityDir/certificates
alrb_certLog=$ATLAS_LOCAL_ROOT_BASE/logDir
\mkdir -p $alrb_certDir
\mkdir -p $alrb_certLog

# check the last time this was run successfully
if [[ "$alrb_force" = "NO" ]] && [[ -e $alrb_certLog/lastSuccessfulFetchCRL-emi ]]; then
    alrb_lastModified=`stat -c %Y $alrb_certLog/lastSuccessfulFetchCRL-emi`
    alrb_currentTime=`date +%s`
    alrb_diffTime=$(( $alrb_currentTime - $alrb_lastModified ))
    if [ $alrb_diffTime -lt 18000 ]; then
	if [ "$alrb_verbose" = "YES" ]; then
	    \echo "Exiting becaue this was last updated less than 6 hours ago".
	fi
	exit 0
    fi
fi

# get version of emi to use
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/functions.sh
    alrb_fn_getToolVersion emi "" "" 
    if [ $? -ne 0 ]; then
	\echo "Error: unable to get version of emi to use"
	exit 64
    fi

# run 
alrb_setupFile="$ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/setup.sh"
if [ -f $alrb_setupFile ]; then
    source $alrb_setupFile
else
    \echo "Error: $alrb_setupFile was missing but we will continue ..."
fi

# rotate logs
if [ -e $alrb_certLog/fetch-crl-emi.log ]; then
    let alrb_logSize=`du -sk $alrb_certLog/fetch-crl-emi.log | \cut -f 1`
    if [ $alrb_logSize -gt 1000 ]; then
	cd $alrb_certLog
	for alrb_idx in 4 3 2 1; do
	    let alrb_nextI=$alrb_idx+1
	    if [ -e fetch-crl-emi.log.tgz.$alrb_idx ]; then
		mv fetch-crl-emi.log.tgz.$alrb_idx fetch-crl-emi.log.tgz.$alrb_nextI
	    fi	
	done
	tar zcf fetch-crl-emi.log.tgz.1 fetch-crl-emi.log
	\rm fetch-crl-emi.log
    fi
fi

if [ ! -e $alrb_certLog/fetch-crl-emi.log ]; then
    touch $alrb_certLog/fetch-crl-emi.log
fi

alrb_rc=64
if [ -e $ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/usr/sbin/fetch-crl ]; then
# use these options : --no-check-certificate -a 24 ?
    $ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/usr/sbin/fetch-crl -l $alrb_certDir -o $alrb_certDir >> $alrb_certLog/fetch-crl-emi.log 2>&1
    alrb_rc=$?
fi

# sucessful ?  Then mark a timestamp
if [ $alrb_rc -eq 0 ]; then
    \rm -f $alrb_certLog/lastSuccessfulFetchCRL-emi
    date > $alrb_certLog/lastSuccessfulFetchCRL-emi
else
    \echo "Error: fetchCRL-emi failed.  Look at the log file \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-crl-emi.log"
    \echo "Note that the errors may be benign and they will usually correct themselves."
    \echo "You probably do not need to be concerned unless your users report a problem."
    
    \echo "The failures from the logs are : "
    alrb_fn_extractError
fi

exit $alrb_rc

