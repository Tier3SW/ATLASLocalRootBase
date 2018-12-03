#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! fetchCA-emi.sh
#!
#! A script to fetch the latest grid CA
#!
#! Usage:
#!     fetchCA-emi.sh --help
#!
#! History:
#!   10Jul09: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=fetchCA-emi.sh

#!----------------------------------------------------------------------------
alrb_fn_fetchCAHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: fetchCA-emi.sh [options]

    This application will fetch the latest grid CA files.

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --force                  Do even if it was run within the past 6 hrs
     -v --verbose             Verbose messages
   
EOF
}

#!----------------------------------------------------------------------------
# override to make this false; this is not an alrb function !
function central_certs {
#!----------------------------------------------------------------------------
    return 1
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
            alrb_fn_fetchCAHelp
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

{
    alrb_rc=0

# create the dirs
    alrb_securityDir=$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi
    alrb_certDir=$alrb_securityDir/certificates
    alrb_certLog=$ATLAS_LOCAL_ROOT_BASE/logDir
    mkdir -p $alrb_certDir
    mkdir -p $alrb_certLog

# check the last time this was run successfully
    if [[ "$alrb_force" = "NO" ]] && [[ -e $alrb_certLog/lastSuccessfulFetchCA-emi ]]; then
	alrb_lastModified=`stat -c %Y $alrb_certLog/lastSuccessfulFetchCA-emi`
	alrb_currentTime=`date +%s`
	alrb_diffTime=$(( $alrb_currentTime - $alrb_lastModified ))
	if [ $alrb_diffTime -lt 82800 ]; then
	    if [ "$alrb_verbose" = "YES" ]; then
		\echo "Exiting becaue this was last updated less than 24 hours ago".
	    fi
	    exit 0
	fi
    fi

# rotate logs
    if [ -e $alrb_certLog/fetch-ca-emi.log ]; then
	let alrb_logSize=`du -sk $alrb_certLog/fetch-ca-emi.log | \cut -f 1`
	if [ $alrb_logSize -gt 1000 ]; then
	    cd $alrb_certLog
	    for alrb_idx in 4 3 2 1; do
	        let alrb_nextI=$alrb_idx+1
		if [ -e fetch-ca-emi.log.tgz.$alrb_idx ]; then
		    mv fetch-ca-emi.log.tgz.$alrb_idx fetch-ca-emi.log.tgz.$alrb_nextI
		fi
	    done
	    tar zcf fetch-ca-emi.log.tgz.1 fetch-ca-emi.log
	    \rm fetch-ca-emi.log
	fi
    fi
    
    if [ ! -e $alrb_certLog/fetch-ca-emi.log ]; then
	touch $alrb_certLog/fetch-ca-emi.log
    fi

    alrb_thisTime=`date`
    \echo "$alrb_thisTime - start fetchCA run" >> $alrb_certLog/fetch-ca-emi.log

# get version of emi to use
    source $ATLAS_LOCAL_ROOT_BASE/swConfig/functions.sh
    alrb_fn_getToolVersion emi "" "" 
    if [ $? -ne 0 ]; then
	\echo "Error: unable to get version of emi to use"
	exit 64
    fi

# source setups and define stuff
    alrb_setupFile="$ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/setup.sh"
    if [ -f $alrb_setupFile ]; then
	source $alrb_setupFile
    else
	\echo "Error: $alrb_setupFile was missing ..."
	exit 64
    fi

    alrb_sitedefFile="$ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/site-info.def"
    if [ -f $sidedefFile ]; then
	source $alrb_sitedefFile
    else
	\echo "Error: $alrb_sitedefFile was missing ..."
	exit 64
    fi
        
    alrb_functionFile="$ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/opt/glite/yaim/functions/config_certs_userland"
    if [ -f $alrb_functionFile ]; then
	source $alrb_functionFile
    else
	\echo "Error: $alrb_functionFile was missing ..."
	exit 64
    fi

    YAIM_LOG=$alrb_certLog/fetch-ca-emi.log
    source $ATLAS_LOCAL_ROOT/emi/$alrb_candRealVersion/opt/glite/yaim/functions/utils/yaimlog >> $alrb_certLog/fetch-ca-emi.log

# cleanup first - any crl_url files older than 7 days
    \find $alrb_certDir -mtime +7 -type f -name "*.crl_url" | \awk '{print "\\rm "$1""}' | sh
       
# run ...
    config_certs_userland_setenv >> $alrb_certLog/fetch-ca-emi.log 2>&1
    config_certs_userland >> $alrb_certLog/fetch-ca-emi.log 2>&1
    alrb_rc=$?

    alrb_thisTime=`date`
    \echo "$alrb_thisTime - finish fetchCA run" >> $alrb_certLog/fetch-ca-emi.log
    
# sucessful ?  Then mark a timestamp
    if [ $alrb_rc -eq 0 ]; then
	\rm -f $alrb_certLog/lastSuccessfulFetchCA-emi
	date > $alrb_certLog/lastSuccessfulFetchCA-emi
    else
	\echo "Error: fetchCA failed.  Look at the log file \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-ca-emi.log"
	\echo "Note that the errors may be benign and they will usually correct themselves."
	\echo "You probably do not need to be concerned unless your users report a problem."
    fi

    exit $alrb_rc
}

