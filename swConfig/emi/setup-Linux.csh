#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup emi for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_EMI_VERSION $1
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )

if ( "$ALRB_gridType" != "none" && "$alrb_Force" == "YES" ) then
    set alrb_cleanScript=`mktemp $alrb_lsWorkdir/gridClean_XXXXXX`
    $ATLAS_LOCAL_ROOT_BASE/utilities/cleanGridEnv.sh $ALRB_gridType $ALRB_SHELL  $GRID_ENV_LOCATION >> $alrb_cleanScript
    if ( $? == 0 ) then
	if ( "$alrb_Quiet" == "NO" ) then
	    \echo "  Cleaning up existing grid middleware"
	endif
	source $alrb_cleanScript 
	set alrb_rc=$?
	\rm -f $alrb_cleanScript
	if ( $alrb_rc != 0 ) then    
	    \echo "  Error: Failed to cleanup existing grid middleware"
	    \echo "         We will continue despite this error ..."
	endif
    endif
endif
    
set alrb_emiWrapper=""
foreach alrb_item ($alrb_tmpAr) 
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
        case sourceLocalJavaPath:
	    setenv EMI_TARBALL_BASE ${ATLAS_LOCAL_ROOT}/emi/${ATLAS_LOCAL_EMI_VERSION}
	    source ${EMI_TARBALL_BASE}/localJavaPath.csh
	    breaksw
	case alrb_javaHome:
	    set alrb_tmpVal=`\echo $alrb_item | \cut -f 2 -d "="`
	    setenv EMI_OVERRIDE_JAVA_HOME $alrb_tmpVal
	    breaksw
	case alrb_wrapper:
	    set alrb_emiWrapper=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	default:
	    breaksw
    endsw
end

setenv ALRB_useGridSW emi			       
if ( "$alrb_emiWrapper" == "" ) then
    source ${ATLAS_LOCAL_ROOT}/emi/${ATLAS_LOCAL_EMI_VERSION}/setup.csh
else
    setenv X509_CERT_DIR $ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
    insertPath PATH $ATLAS_LOCAL_ROOT_BASE/wrappers/gridMW 
    if ( "$alrb_Quiet" == "NO" ) then
	\echo "  wrapper setup for emi"
    endif
endif

unset alrb_cleanScript alrb_rc alrb_tmpAr alrb_item alrb_tmpVal alrb_emiWrapper
