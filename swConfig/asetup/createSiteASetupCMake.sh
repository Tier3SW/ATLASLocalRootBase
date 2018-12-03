#! /bin/bash
#!----------------------------------------------------------------------------
#! this is v1 for the new cvmfs cmake releases
#! createSiteASetupCmake.sh
#!
#! Creates a new site asetup file if needed
#!
#! Usage: 
#!     createSiteASetupCMake.sh --help
#!
#! History:
#!   23Aug10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=createSiteASetupCmake.sh


#!----------------------------------------------------------------------------
alrb_fn_ceateSiteASetupCmakeHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: createSiteASetupCmake.sh [options]

    This application will create the site AtlasSetup config file
    if it does not exist or upgrade it if needed.

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --force                  Recreate the file

EOF
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------
 
alrb_shortopts="h" 
alrb_longopts="help,force"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_recreate="NO";

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_ceateSiteASetupCmakeHelp
            exit 0
            ;;
	--force)
	    alrb_recreate="YES"
	    shift
	    break
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

alrb_cvmfsNightlyReleasePath="nightliesarea = $ALRB_cvmfs_nightly_repo/sw"

alrb_cvmfsReleasePath="$ALRB_cvmfs_repo/sw/software"

alrb_configDir="$ATLAS_LOCAL_ROOT/AtlasSetup/.configCMake"
if [ ! -d $alrb_configDir ]; then
    mkdir -p $alrb_configDir
fi 
alrb_siteAsetup="$alrb_configDir/.asetup.site"

alrb_cvmfsDBPath="$ALRB_cvmfs_repo/sw/database"

alrb_siteAsetupTmp=$alrb_siteAsetup.tmp
\rm -f $alrb_siteAsetupTmp

\echo "

# See https://twiki.cern.ch/twiki/bin/view/Atlas/AtlasSetup for details

[defaults]

# paths to release areas; note that cvmfs, if it exists, is searched first
releasesarea = $alrb_cvmfsReleasePath

# (if exists on cvmfs) nightlisDir
$alrb_cvmfsNightlyReleasePath

# dbrelease area ... this is the search path
dbarea = $alrb_cvmfsDBPath

# default dbrelease versions
dbrelease = current

cmakearea = $ATLAS_LOCAL_ROOT/Cmake

[epilog.sh]
source $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/asetupEpilog.sh 

" > $alrb_siteAsetupTmp

alrb_updateIt="NO"
if [ -e $alrb_siteAsetup ]; then
    result=`diff $alrb_siteAsetupTmp $alrb_siteAsetup  2>&1`
    if [ $? -ne 0 ]; then
	alrb_updateIt="YES"
    fi
else
    alrb_updateIt="YES"
fi

if [[ "$alrb_recreate" = "YES" ]] || [[ "$alrb_updateIt" = "YES" ]]; then
    \echo "Updating $alrb_siteAsetup .."
    \mv $alrb_siteAsetupTmp $alrb_siteAsetup
fi

\rm -f $alrb_siteAsetupTmp

exit 0

