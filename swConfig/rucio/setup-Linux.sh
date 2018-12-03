#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup rucio-clients for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_RUCIOCLIENTS_VERSION=$1

alrb_rucioWrapper=""
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	alrb_wrapper)
	    alrb_rucioWrapper=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

if [ "$alrb_rucioWrapper" != "" ]; then
    export ALRB_rucioVersion=$ATLAS_LOCAL_RUCIOCLIENTS_VERSION
    insertPath PATH $ATLAS_LOCAL_ROOT_BASE/wrappers/rucioClients
    if [ "$alrb_Quiet" = "NO" ]; then
	\echo "  wrapper setup for rucio"
    fi
else
    RUCIO_HOME="${ATLAS_LOCAL_ROOT}/rucio-clients/$ATLAS_LOCAL_RUCIOCLIENTS_VERSION"
    alrb_rucioSetupFile="$RUCIO_HOME/setup.sh"
    if [[ "$ALRB_SHELL" = "zsh" ]] && [[ -e $RUCIO_HOME/setup.zsh ]]; then
	alrb_rucioSetupFile="$RUCIO_HOME/setup.zsh"
    fi
    export RUCIO_HOME=$RUCIO_HOME
    if [ "$alrb_Quiet" = "NO" ]; then
	source $alrb_rucioSetupFile 
    else
	source $alrb_rucioSetupFile --quiet
    fi
fi

unset alrb_rucioSetupFile alrb_tmpVal alrb_rucioWrapper alrb_tmpAr alrb_item
return 0
