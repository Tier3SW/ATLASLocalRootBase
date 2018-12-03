#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup rucio for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_RUCIOCLIENTS_VERSION $1

set alrb_rucioWrapper=""
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )
foreach alrb_item ($alrb_tmpAr) 
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
        case alrb_wrapper:
	    set alrb_rucioWrapper=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	default:
	    breaksw
    endsw
end

if ( "$alrb_rucioWrapper" != "" ) then
    setenv ALRB_rucioVersion $ATLAS_LOCAL_RUCIOCLIENTS_VERSION
    insertPath PATH $ATLAS_LOCAL_ROOT_BASE/wrappers/rucioClients
    if ( "$alrb_Quiet" == "NO" ) then
	\echo "  wrapper setup for rucio"
    endif
else
    setenv  RUCIO_HOME "${ATLAS_LOCAL_ROOT}/rucio-clients/$ATLAS_LOCAL_RUCIOCLIENTS_VERSION"
    if ( "$alrb_Quiet" == "NO" ) then
	source $RUCIO_HOME/setup.csh 
    else
	source $RUCIO_HOME/setup.csh --quiet
    endif
endif

unset alrb_tmpVal alrb_rucioWrapper alrb_tmpAr alrb_item



