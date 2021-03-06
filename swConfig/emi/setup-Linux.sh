#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup emi for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_EMI_VERSION=$1
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 

if [[ "$ALRB_gridType" != "none" ]] && [[ "$alrb_Force" = "YES" ]]; then
    alrb_cleanScript=`mktemp $alrb_lsWorkdir/gridClean_XXXXXX`
    $ATLAS_LOCAL_ROOT_BASE/utilities/cleanGridEnv.sh $ALRB_gridType $ALRB_SHELL  $GRID_ENV_LOCATION >> $alrb_cleanScript
    if [ $? -eq 0 ]; then
	if [ "$alrb_Quiet" = "NO" ]; then
	    \echo "  Cleaning up existing grid middleware"
	fi
	source $alrb_cleanScript 
	alrb_rc=$?
	\rm -f $alrb_cleanScript
	if [ $alrb_rc -ne 0 ]; then    
	    \echo "  Error: Failed to cleanup existing grid middleware"
	    \echo "         We will continue despite this error ..."
	fi
    fi	
fi
    
alrb_emiWrapper=""
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	sourceLocalJavaPath)
	    export EMI_TARBALL_BASE=${ATLAS_LOCAL_ROOT}/emi/${ATLAS_LOCAL_EMI_VERSION}
	    source ${EMI_TARBALL_BASE}/localJavaPath.sh
	    ;;
	alrb_javaHome)
	    alrb_tmpVal=`\echo $alrb_item | \cut -f 2 -d "="`
	    export EMI_OVERRIDE_JAVA_HOME=$alrb_tmpVal
	    ;;
	alrb_wrapper)
	    alrb_emiWrapper=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

export ALRB_useGridSW=emi
if [ "$alrb_emiWrapper" = "" ]; then
    source ${ATLAS_LOCAL_ROOT}/emi/${ATLAS_LOCAL_EMI_VERSION}/setup.sh
else
    export X509_CERT_DIR=$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
    insertPath PATH $ATLAS_LOCAL_ROOT_BASE/wrappers/gridMW 
    if [ "$alrb_Quiet" = "NO" ]; then
	\echo "  wrapper setup for emi"
    fi
fi

unset alrb_cleanScript alrb_rc alrb_tmpAr alrb_item alrb_tmpVal alrb_emiWrapper

