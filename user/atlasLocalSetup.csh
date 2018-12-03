#!----------------------------------------------------------------------------
#!
#! atlasLocalSetup.csh
#!
#! A simple script for users to setup the cluster environment for ATLAS
#!
#! This script adopts a minimilist approach - nothing is added to paths,
#!  only some environment variables and aliases are defined.
#!  Paths to executables and libraries are added when the aliases are 
#!  later invoked by the user.
#!
#!
#! Usage: 
#!     source atlasLocalSetup.csh --help
#!
#! History:
#!   10Oct07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_progname=atlasLocalSetup.csh

setenv ALRB_initialSetup "True"

alias alrb_fn_setupAtlasHelp '\echo "\\
Usage: atlasLocalSetup.csh [options] \\
       or setupATLAS [options]   \\
\\
    This sets up the ATLAS environment for a cluster user \\
\\
    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first. \\
\\
    Options (to override defaults) are: \\
     -h  --help                   Print this help message \\
     -q  --quiet                  Print no output \\
     -p  --noLocalPostSetup       Skip running local/site post-setup script \\
     -r  --relocateCvmfs          Use relocated cvmfs \\
     -t  --test=STRING            Used for testing \\
     -c  --container=name         setupATLAS in a container \\
                                   name can be eg sl6 or sl7 or \\
                                   the path to a container \\
\\
"; if ( -e ${ATLAS_LOCAL_ROOT_BASE}/ALRBTests.txt ) \cat ${ATLAS_LOCAL_ROOT_BASE}/ALRBTests.txt'

setenv ATLAS_LOCAL_SETUP_OPTIONS "$*"

set alrb_shortopts="h,q,p,t:,o:,c:"
set alrb_longopts="help,quiet,noLocalPostSetup,test:,relocateCvmfs,overrideARCH:,gangaVersion:,pacmanVersion:,rootVersion:,pandaClientVersion:,gccVersion:,asetupVersion:,rucioVersion:,pyAMIVersion:,emiVersion:,agisVersion:,xrootdVersion:,rcSetupVersion:,faxtoolsVersion:,rucioclientsVersion:,atlantisVersion:,davixVersion:,eiClientVersion:,container:"
set alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh tcsh $alrb_shortopts $alrb_longopts $alrb_progname $*:q`
if ( $? != 0 ) then
    exit 64
else
    source $alrb_tmpVal    
    if ( $?alrb_tempDir) then
	\rm -rf $alrb_tempDir
	unset alrb_tempDir alrb_tmpVal
    endif
endif

# backward compatibility
set agisVersionVal="dynamic"
set atlantisVersionVal="dynamic"
set gangaVersionVal="dynamic"
set davixVersionVal="dynamic"
set emiVersionVal="dynamic"
set eiClientVersionVal="dynamic"
set gccVersionVal="dynamic"
set pacmanVersionVal="dynamic"
set rootVersionVal="dynamic"
set pandaClientVersionVal="dynamic"
set asetupVersionVal="dynamic"
set rucioVersionVal="dynamic"
set rucioclientsVersionVal="dynamic"
set xrootdVersionVal="dynamic"
set pyAMIVersionVal="dynamic"
set rcSetupVersionVal="dynamic"
set faxtoolsVersionVal="dynamic"

# obsolete, remove this
setenv ALRB_allowSL6onSL5 "NO"

unsetenv ATLAS_LOCAL_ROOT_ARCH_OVERRIDE
unset ALRB_OSTYPE_OVERRIDE
unset ALRB_OSMAJORVER_OVERRIDE

set alrb_Quiet="NO"
set alrb_quietOpt=""
set alrb_noLocalPostSetup="NO"
set alrb_container=""

if ( ! $?ALRB_RELOCATECVMFS ) then
    setenv ALRB_RELOCATECVMFS "NO"
endif
if ( ! $?ALRB_testPath ) then
    set ALRB_testPath=""
    if ( $?ALRBtestPath ) then
# obsolete but backward compatible
	set ALRB_testPath=$ALRBtestPath
	unsetenv ALRBtestPath
	unset ALRBtestPath
    endif
endif

while ( $#alrb_opts > 0 )
    switch ($alrb_opts[1])
        case -h:
        case --help:
            alrb_fn_setupAtlasHelp
            unalias alrb_fn_setupAtlasHelp
            exit 0
            breaksw
        case -q:
        case --quiet:
            set alrb_Quiet="YES"
	    set alrb_quietOpt=" --quiet"
            shift alrb_opts
            breaksw
        case -p:
        case --noLocalPostSetup:
	    set alrb_noLocalPostSetup="YES"
            shift alrb_opts
            breaksw
        case -o:
	case --overrideARCH:
	    setenv ATLAS_LOCAL_ROOT_ARCH_OVERRIDE $alrb_opts[2]
            shift alrb_opts
            shift alrb_opts
            breaksw	    
        case -t:
	case --test:
	    set ALRB_testPath=$alrb_opts[2]
            shift alrb_opts
            shift alrb_opts
            breaksw
	case -r:
        case --relocateCvmfs:
	    setenv ALRB_RELOCATECVMFS "YES"
            shift alrb_opts
            breaksw
	case -c:
	case --container:
	    set alrb_container=$alrb_opts[2]
	    shift alrb_opts
	    shift alrb_opts
	    breaksw
        case --agisVersion:
        case --asetupVersion:
        case --emiVersion:
        case --eiClientVersion:
        case --faxtoolsVersion:
        case --gangaVersion:
        case --gccVersion:
        case --pacmanVersion:
        case --pandaClientVersion:
        case --rootVersion:
        case --rucioVersion:
        case --rucioclientsVersion:
        case --atlantisVersion:
        case --davixVersion:
        case --xrootdVersion:
        case --pyAMIVersion:
        case --rcSetupVersion:
	    \echo "option $1 is obsolete.  Please do not use it." > /dev/stderr
            shift alrb_opts
            shift alrb_opts
            breaksw 
        case --:
            shift alrb_opts
            break
        default:
            \echo "Internal Error: option processing error: $1" > /dev/stderr
            unalias alrb_fn_setupAtlasHelp
            exit 1
            breaksw
    endsw
end

if ( ! $?ATLAS_LOCAL_ROOT_BASE ) then 
    \echo "Error: ATLAS_LOCAL_ROOT_BASE not set" > /dev/stderr
    unalias alrb_fn_setupAtlasHelp
    exit 64
else
    if ( $?ALRB_CONT_HOSTALRBDIR ) then
	source ${ATLAS_LOCAL_ROOT_BASE}/relocate/container.csh	
    else if ( "$ALRB_RELOCATECVMFS" == "YES" ) then
	source ${ATLAS_LOCAL_ROOT_BASE}/relocate/relocateCvmfs.csh
    endif
    source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.csh
endif

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/setupAliases.csh

set ALRB_testPath=",$ALRB_testPath,"
setenv ALRB_testPath $ALRB_testPath

# if container, then go away; need to copy it since the container can run long
if ( "$alrb_container" != "" ) then
    mkdir -p $ALRB_SCRATCH/container/scripts
    set alrb_scriptFile=`mktemp $ALRB_SCRATCH/container/scripts/startContainer.sh.XXXXXX`
    if ( $? != 0 ) then
	exit 64
    endif
    \cp $ATLAS_LOCAL_ROOT_BASE/utilities/startContainer.sh $alrb_scriptFile
    chmod +x $alrb_scriptFile
    eval $alrb_scriptFile  -c "$alrb_container" $alrb_quietOpt
    set alrb_rc=$?
    \rm -f $alrb_scriptFile
    exit $alrb_rc
else if ( $?ALRB_containerSiteOnly ) then
    if ( "$ALRB_containerSiteOnly" == "YES" ) then
	\echo "setupATLAS is meant to only run on a container at this site"
	\echo '       You should do "setupATLAS -c slc6"'
	\echo 'see https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Containers'
	exit 64
    endif
endif

set alrb_AvailableTools=""
set alrb_AvailableToolsPre=""
set alrb_AvailableToolsPost=""

set alrb_menuTypeAr=( "Pre" "." "Post" )
foreach alrb_menuType ($alrb_menuTypeAr)
    set alrb_dirAr=( `\find $ATLAS_LOCAL_ROOT_BASE/swConfig/${alrb_menuType} -maxdepth 1 -mindepth 1 -type d | \sed -e 's/.*\///' | env LC_ALL=C \sort` )
    foreach alrb_menuItem ($alrb_dirAr)
        set alrb_QuietSaved=$alrb_Quiet
	if ( -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu-${ALRB_OSTYPE}.csh" ) then
	    source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu-${ALRB_OSTYPE}.csh
	else if ( -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu.csh" ) then
		source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_menuItem}/menu.csh
        endif
        set alrb_Quiet=$alrb_QuietSaved
    end
end

setenv ALRB_availableTools "$alrb_AvailableTools"
setenv ALRB_availableToolsPre "$alrb_AvailableToolsPre"
setenv ALRB_availableToolsPost "$alrb_AvailableToolsPost"

# save this application as an alias                                            
alias atlasLocalRootBaseSetup 'source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.csh'

# check if more than one grid middleware is available
set alrb_result=`${ATLAS_LOCAL_ROOT_BASE}/utilities/checkGridUse.sh`
set alrb_nGridSW=`\echo $alrb_result | \cut -f 1 -d " "`
set alrb_availableSW=`\echo $alrb_result | \cut -f 2- -d " "`
if ( ! $?ALRB_useGridSW )  then
    if ( "$alrb_nGridSW" == 0 ) then
	setenv ALRB_useGridSW 0
    else
	setenv ALRB_useGridSW `\echo $alrb_result | \cut -f 2 -d " "`
    endif
endif
if (( "$alrb_nGridSW" > 1 ) && ( "${alrb_Quiet}" == "NO" )) then    
    \echo "*******************************************************************************"
    \echo "Grid middleware note:"
    \echo "  $availableSW are available on this machine."
    \echo "  Current value is $ALRB_useGridSW"
    \echo "  The default value is set by the environment variable ALRB_useGridSW"
    \echo "    possible values for ALRB_useGridSW: $availableSW"
    \echo "*******************************************************************************"
endif

# motd
if ( "${alrb_Quiet}" == "NO" ) then
    if ( -e $ATLAS_LOCAL_ROOT_BASE/etc/motd ) then
	$ATLAS_LOCAL_ROOT_BASE/etc/motd
    endif
endif


# warnings

set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $ATLAS_LOCAL_ROOT_BASE | \grep -e "^/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"`
if ( $? == 0 ) then
    if ( ! -d $ATLAS_LOCAL_ROOT_BASE ) then
	\echo "Error: "'$ATLAS_LOCAL_ROOT_BASE'" does not exist." > /dev/stderr
    else if ( $ATLAS_LOCAL_ROOT_ARCH == "i686" ) then
	\echo "Error: "'$ATLAS_LOCAL_ROOT_BASE'" on cvmfs is not available for i686"
    endif
endif

if ( $ALRB_RHVER >= 6 && $ATLAS_LOCAL_ROOT_ARCH == "i686" ) then
    \echo "Warning: 32-bit is unsupported on SL${ALRB_RHVER}." > /dev/stderr
    \echo "  Please migrate to 64-bit OS for SL${ALRB_RHVER}." > /dev/stderr
endif

if (( $ALRB_RHVER <= 5 ) && ( $ALRB_RHVER != 0 )) then
    \echo "Warning: SL${ALRB_RHVER} is unsupported." > /dev/stderr
    \echo " Please switch to using SL6 machines now (all SL${ALRB_RHVER} releases work on SL6)." > /dev/stderr
    if ( $?ATLAS_LOCAL_ROOT_CERNVM ) then
	\echo "  CernVM users: please upgrade to CernVM3; see \
   https://twiki.cern.ch/twiki/bin/view/AtlasComputing/CernVMFS#Setup_Instructions_for_CernVM_Us" > /dev/stderr
    endif
endif

# PFC exists ?
if ( ! $?ATLAS_POOLCOND_PATH) then
    if ( "$ALRB_cvmfs_CDB" != "" ) then
	setenv ATLAS_POOLCOND_PATH $ALRB_cvmfs_CDB
    endif
endif
if ( "$ALRB_RELOCATECVMFS" == "YES" ) then
    source ${ATLAS_LOCAL_ROOT_BASE}/relocate/relocateCvmfs-pool.csh
endif

# Frontier setup
if ( -e $ATLAS_LOCAL_ROOT_BASE/config/localFrontierSquid.csh ) then
    source $ATLAS_LOCAL_ROOT_BASE/config/localFrontierSquid.csh
endif

# Missing Frontier in flat files - try to "guess" (may be from AGIS)
if ( ! $?FRONTIER_SERVER ) then
    set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/guessFrontier.sh`
    if ( $? == 0 ) then
	setenv FRONTIER_SERVER $alrb_result
    endif
endif
if ( $?FRONTIER_SERVER ) then
    set alrb_result=`$ATLAS_LOCAL_ROOT_BASE/utilities/addBackupFrontier.sh`
    if ( $? == 0 ) then
	setenv FRONTIER_SERVER $alrb_result
    endif
endif

# here we will allow a site to run their own post configuration; but users 
# can override it - especially when asked by user spport.

if ( $?ALRB_localConfigDir ) then
    set alrb_localConfigDir2="$ALRB_localConfigDir"
else
    set alrb_localConfigDir2="willNotExist"
endif
if (( -d $alrb_localConfigDir2 ) && ( $alrb_noLocalPostSetup == "NO" )) then
    foreach alrb_item ( localFrontierSquid.csh localPostUserSetup.csh)
        if ( -e "$alrb_localConfigDir2/$alrb_item" ) then
            source $alrb_localConfigDir2/$alrb_item
        endif
    end
endif

if (( -e $ATLAS_LOCAL_ROOT_BASE/config/localPostUserSetup.sh ) && ( "$alrb_noLocalPostSetup" == "NO" ))  then
    source $ATLAS_LOCAL_ROOT_BASE/config/localPostUserSetup.csh
endif


# cvmfs validity check
eval $ATLAS_LOCAL_ROOT_BASE/utilities/checkValidity.sh $alrb_quietOpt
set alrb_returnVal=$?  # suppress exit code from this

# fix manpath so that it does not get clobbered 
if ( ! $?MANPATH ) then
    setenv MANPATH `manpath`
endif

# tab completion
set alrb_availableToolsAr=( `\echo $ALRB_availableTools` )
complete lsetup 'p/*/$alrb_availableToolsAr/'

# cleanup
unalias alrb_fn_setupAtlasHelp
unset alrb_shortopts alrb_longopts alrb_result alrb_returnVal alrb_Quiet alrb_QuietSaved alrb_dirAr alrb_menuItem alrb_nGridSW alrb_availableSW alrb_menuTypeAr alrb_menuType  alrb_item alrb_localConfigDir2 ALRB_initialSetup
unsetenv ALRB_initialSetup


