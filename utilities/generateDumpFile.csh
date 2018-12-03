#!----------------------------------------------------------------------------
#!
#! generateDumpFile.csh
#!
#! Dump out information to send to user support
#!
#! Usage:
#!     generateDumpFile.csh --help
#!
#! History:
#!   18Mar10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_progname=generateDumpFile.csh

alias alrb_fn_supportInfoHelp '\echo "\\
\\
Usage: supportInfo [options] \\
\\
    Dump out information to send to user support. \\
\\
    Options (to override defaults) are:\\
     -h  --help               Print this help message\\
     --dir=STRING             Where to save dumpfile\\
\\
"'

#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------

set alrb_shortopts="h" 
set alrb_longopts="help,dir:"
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

set alrb_dirVal=~

while ( $#alrb_opts > 0 )
    switch ($alrb_opts[1])
        case -h:
	case --help:
	    alrb_fn_supportInfoHelp
	    unalias alrb_fn_supportInfoHelp
	    exit 0
	    breaksw
	case --dir:
	    set alrb_dirVal=$alrb_opts[2]
	    shift alrb_opts
	    shift alrb_opts
	case --:
	    shift alrb_opts
	    break
	default:
	    \echo "Internal Error: option processing error: $1"
	    unalias alrb_fn_supportInfoHelp
	    exit 1
	    breaksw
    endsw
end

set alrb_pid=$$
set alrb_tmpfile=$ALRB_tmpScratch/generateDumpFile_$alrb_pid.csh

set alrb_timestamp=`date +%Y%m%d_%H:%M`
set alrb_dmpfile=$alrb_dirVal/dump_$alrb_timestamp.txt
set alrb_dmpfile=`\echo $alrb_dmpfile | \sed 's/\://g'`

if ( $?ALRB_SHELL ) then
    set alrb_myShell="$ALRB_SHELL"
else
    set alrb_myShell=`\ps --no-heading -p $$  | \sed 's/.* \(.*\)$/\1/'`
endif

set alrb_getShellEnv="set | env LC_ALL=C \sort"

\cat << EOF > $alrb_tmpfile

\echo "\
--------------------------------------------------------------------------------\
General Information\
\
What to check : \
- shell: only bash, zsh and tcsh supported \
--------------------------------------------------------------------------------\
"
    \echo -n "Date: "; date
    \echo -n "User: "; whoami
    \echo -n "Id: "; id
    \echo "Shell: $alrb_myShell"
    eval $alrb_myShell --version        

    \find  / -maxdepth 1 -mindepth 1 -name .*docker*

    \echo " \
\
--------------------------------------------------------------------------------\
Release Information\
\
What to check : \
- svn difference should not show any \
- last update of ALRB should be within past 24h \
- last successful CA/CRLs; these should be past 24h; if there are longer,\
   look at the CA/CRL logfile tails below.  (Errors do not necessarily mean \
   that there is a problem, only if there are grid middleware issues.)\
-------------------------------------------------------------------------------- \
"

    \echo "svn differences ..."
    svn status --show-updates --non-interactive \$ATLAS_LOCAL_ROOT_BASE 

    \echo " "
    \echo "last updates of ALRB ..."
    \tail -4  \$ATLAS_LOCAL_ROOT_BASE/logDir/lastUpdate

    if ( -e \${ATLAS_LOCAL_ROOT}/emi ) then
      if (`\ls -1 ${ATLAS_LOCAL_ROOT}/emi | wc -l` != 0) then
        if ( -e \$ATLAS_LOCAL_ROOT_BASE/logDir/lastSuccessfulFetchCA-emi ) then
          \echo " "
          \echo "last successful emi CA update"
          \cat \$ATLAS_LOCAL_ROOT_BASE/logDir/lastSuccessfulFetchCA-emi 
        endif
        if ( -e \$ATLAS_LOCAL_ROOT_BASE/logDir/lastSuccessfulFetchCRL-emi ) then
          \echo " "
          \echo "last successful emi CRL update"
          \cat \$ATLAS_LOCAL_ROOT_BASE/logDir/lastSuccessfulFetchCRL-emi
        endif
        if ( -e \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-crl-emi.log ) then
          \echo " "
          \echo "emi CRL update logfile tail"
          \tail  -4 \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-crl-emi.log
        endif
        if ( -e \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-ca-emi.log ) then
          \echo " "
          \echo "emi CA update logfile tail"
          \tail  -4 \$ATLAS_LOCAL_ROOT_BASE/logDir/fetch-ca-emi.log
        endif
      endif
    endif
    
    \echo "\
\
--------------------------------------------------------------------------------\
System Information\
\
What to check : \
- hostname shows where this was run \
- uname shows kernel version (also shows RHEL version) \
- filesystem shows if there is a disk out of space \
- which RedHat OS version (should match kernel) \
- missing rpms listed, if any \
- drifttime in case date is incorrect (value is ppm) \
- shows grid middleward is installed on system (rpms) \
- look at which files are setup for users on the system (in particular grid \
   grid middleware in /etc/profile.d) \
--------------------------------------------------------------------------------\
"
    \echo -n "Hostname: "; hostname -f
    \echo -n "uname: "; uname -a
    if ( \$ALRB_OSTYPE == "MacOSX" )  then
      \echo " "
      \echo "cpuinfo: "
      sysctl -a | \grep machdep.cpu
      \echo " "
      \echo "meminfo: " 
      \top -l 1 | \head -n 10 | \grep PhysMem 
    else
      \echo " "
      \echo "cpuinfo: "
      \cat /proc/cpuinfo
      \echo " "
      \echo "meminfo: "
      \cat /proc/meminfo
      \echo " "
      \echo "free: "
      free
    endif
    \echo " " 
    df -h
    \echo " "
    \$ATLAS_LOCAL_ROOT_BASE/utilities/installCheck.sh
    \echo " "
    \echo "drifttime: " 
    if ( -e /var/lib/ntp/drift ) then
      \tail /var/lib/ntp/drift
    endif    
    ntpdate -q pool.ntp.org

    \echo " "
    which rpm 
    if ( \$? == 0 ) then
      \echo " "
      \echo "Check for system installed emi ..."
      rpm -qa | \grep -i emi
      \echo " " 
      \echo "Check what java is available ..."
      rpm -qa | \grep -i java
      \echo " "
      \echo "Check openssl versions ..." 
      rpm -qa | \grep -i openssl
      \echo " "                                                                           
      \echo "Check glib versions ..."                                                     
      rpm -qa | \grep -i glib           
    endif 

    if ( -d /etc/profile.d ) then 
      \echo " "
      \echo "/etc/profile.d contains ..." 
      ls -l /etc/profile.d 
    endif

    \echo "\
\
------------------------------------------------------------------------------\
cvmfs Information\
\
What to check:\
(* only listed if not nfs mounted cvmfs) \
- cvmfs probe should show * \
   Probing /cvmfs/atlas.cern.ch... OK\
   Probing /cvmfs/atlas-condb.cern.ch... OK\
   Probing /cvmfs/atlas-nightlies.cern.ch... OK\
   Probing /cvmfs/sft.cern.ch... OK\
- cvmfs stat should not show i/o errors * \
- cvmfs file open issue should show Error is 0 * \
- Check validity of cvmfs repos should not have any warnings\
------------------------------------------------------------------------------\
"
    set alrb_existCvmfsTools="YES"
    set alrb_result="`which cvmfs_config`"
    if ( \$? != 0 ) then
      set alrb_existCvmfsTools="NO"
      \echo "cvmfs commands not found; this is probably an nfs mounted cvmfs node"
    else
      cvmfs_config probe
    endif

    if ( "\$ALRB_cvmfs_ALRB" != "" || "\$ALRB_cvmfs_CDB" != "" || "\$ALRB_cvmfs_Athena" != "" ) then
      \echo " "
      \echo "cvmfs defined and mounted as ..."
      mount | \grep cvmfs

      \echo " "
      \echo "cvmfs pointers ..." 
      \echo "ALRB_cvmfs_ALRB: \$ALRB_cvmfs_ALRB"
      \echo "ALRB_cvmfs_CDB: \$ALRB_cvmfs_CDB"
      \echo "ALRB_cvmfs_Athena: \$ALRB_cvmfs_Athena"

      if ( "\$alrb_existCvmfsTools" != "NO" ) then  
        \echo " "
        \echo "cvmfs stat ..."
        cvmfs_config stat -v

        \echo " " 
        \echo "Check for cvmfs file open issue ..."
        \$ATLAS_LOCAL_ROOT_BASE/utilities/checkCvmfsOpen.sh  
      endif

      \echo " "
      \echo "Check cvmfs validity ..." 
      $ATLAS_LOCAL_ROOT_BASE/utilities/checkValidity.sh

    endif    

    \echo "\
\
--------------------------------------------------------------------------------\
Compiler Information\
\
What to check : \
- if supportInfo is called after login, these should show if site admins have\
   installed non-standard versions of gcc, python, root on the paths.\
--------------------------------------------------------------------------------\
"
    set alrb_tmpVal=\`which gcc\`
    \echo "which gcc: \$alrb_tmpVal"
    set alrb_tmpVal1=\`\$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh \$alrb_tmpVal\`
    file \$alrb_tmpVal1
    gcc --version

    \echo " "
    set alrb_tmpVal=\`which python\`
    \echo "which python: \$alrb_tmpVal"
    set alrb_tmpVal1=\`\$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh \$alrb_tmpVal\`
    file \$alrb_tmpVal1
    python -V | & \awk '{print \$0}'

    \echo " "
    set alrb_tmpVal=\`which perl\`
    \echo "which perl: \$alrb_tmpVal"
    set alrb_tmpVal1=\`\$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh \$alrb_tmpVal\`
    file \$alrb_tmpVal1
    perl --version | \grep "This is perl"

    \echo " "
    set alrb_tmpVal=\`which java\`
    \echo "which java: \$alrb_tmpVal"
    set alrb_tmpVal1=\`\$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh \$alrb_tmpVal\`
    \echo \$alrb_tmpVal1    
    
    set alrb_result="\`which root\`"
    if (  \$? == 0 ) then
	\echo " "
        set alrb_tmpVal=\`which root\`
	\echo -n "which root: \$alrb_tmpVal"
        set alrb_tmpVal1=\`\$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh \$alrb_tmpVal\`
	file \$alrb_tmpVal1
        root -b -q
    endif
    
    
    \echo "\
\
--------------------------------------------------------------------------------\
Environment Information\
\
What to check :\
- check if CUSTOM_SITE_NAME, ATLAS_SITE_NAME or SITE_NAME are defined and\
   appropriate to site if they exist. \
- check for redefined commands that may conflict\
--------------------------------------------------------------------------------\
"
    \echo "Aliases:"
    alias | env LC_ALL=C \sort
    \echo " "
    \echo "Env: "
    env | env LC_ALL=C \sort
    \echo " "                                                                    
    \echo "Shell: ($ALRB_SHELL)"
    $alrb_getShellEnv 
    if ( -e \$HOME/.local ) then
      \echo " "
      \echo "Warning: \$HOME/.local exists and can screw up python"
    endif
    if ( -e \$HOME/.pki ) then
      \echo " "
      \echo "Warning: \$HOME/.pki exists and contains:"
      ls -laR \$HOME/.pki
    endif

    \echo " " 
    \echo "User processes on this node:"
    \ps -ef | \grep `whoami`

    \echo " \
\
--------------------------------------------------------------------------------\
Proxy Information\
\
What to check :\
- who sets up grid middleware (system or ATLASLocalRootBase)\
- grid certificate - valid dates and DN\
- if exists, proxyy has /atlas/Role=NULL and /atlas/<country> \
   attributes\
- nickname exits (and matches lxplus name)\
- Note: diagnostics menu has gridCert which does more extensive testing\
--------------------------------------------------------------------------------\
"
    if ( \$ALRB_useGridSW != "0" ) then
      source \$ATLAS_LOCAL_ROOT_BASE/user/genericGridSetup.csh      
      \echo -n "which voms-proxy-init: ";which voms-proxy-init

      \echo " "
      \echo "grid certificate information:"
      grid-cert-info -subject -startdate -enddate

      voms-proxy-info -exists >& /dev/null
      if ( $? != 0 ) then
          \echo " "
          \echo "voms proxy information:"
          voms-proxy-info --all
          \echo "grid proxy information:"
          grid-proxy-info -all

          \echo " "    
          \echo "rucio information:"
          lsetup rucio -q
          rucio whoami        
          rucio-admin account list-identities \$RUCIO_ACCOUNT
      endif
    endif
    
    \echo " \
\
--------------------------------------------------------------------------------\
Asetup Information\
\
What to check :\
- if there are asetup problems, ask the user to move this file if it has\
   any uncommented settings\
--------------------------------------------------------------------------------\
"
    if ( -e \$HOME/.asetup ) then
      \echo "\$HOME/.asetup ..."
      \cat \$HOME/.asetup
    endif

    if ( -e ./.asetup ) then
      \echo "PWD/.asetup ..."
      \cat ./.asetup
    endif

    \echo " \
\
--------------------------------------------------------------------------------\
.gangarc Information\
\
What to check :\
- grid and ddm should be setup from ATLASLocalRootBase\
--------------------------------------------------------------------------------\
"
    if ( -e \$HOME/.gangarc ) then
      \echo "\$HOME/.gangarc ..."
      \grep gangaGridSetup \$HOME/.gangarc
      \grep gangaDDMSetup \$HOME/.gangarc
    endif


    \echo " \
\
--------------------------------------------------------------------------------\
Frontier Information\
\
What to check :\
- This does db-fnget of the diagnostics menu\
- It should return an OK and all combinations passed\
--------------------------------------------------------------------------------\
"
    if ( ! \$?FRONTIER_SERVER ) then
      set alrb_tmpVal="`\$ATLAS_LOCAL_ROOT_BASE/utilities/guessFrontier.sh`"
      if ( \$? == 0 ) then
         setenv FRONTIER_SERVER \$alrb_tmpVal         
      else
        \echo "Frontier settings undefined and set to default ..."
        setenv FRONTIER_SERVER "(serverurl=http://atlasfrontier-ai.cern.ch:8000/atlr)(serverurl=http://lcgft-atlas.gridpp.rl.ac.uk:3128/frontierATLAS)(serverurl=http://frontier-atlas.lcg.triumf.ca:3128/ATLAS_frontier)(serverurl=http://ccfrontier.in2p3.fr:23128/ccin2p3-AtlasFrontier)"
      endif
    else

    endif

    \${ATLAS_LOCAL_ROOT_BASE}/utilities/fngetTest.sh

    \echo "\
\
--------------------------------------------------------------------------------\
Finished\
--------------------------------------------------------------------------------\
"

unset alb_result alrb_existCvmfsTools alrb_tmpVal

EOF

source $alrb_tmpfile | tee $alrb_dmpfile

gzip -f $alrb_dmpfile

\rm -f $alrb_tmpfile

\echo "MAIL the file $alrb_dmpfile.gz to user support."

unset alrb_progname alrb_shortopts alrb_longopts alrb_dirVal alrb_pid alrb_timestamp alrb_dmpfile alrb_myShell alrb_getShellEnv

exit 0
