#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup Ganga for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_GANGA_VERSION=$1
alrb_skipGangaRcCheck="NO"
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	skipGangaRcCheck)
	    alrb_skipGangaRcCheck=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

export GANGA_CONFIG_PATH=GangaAtlas/Atlas.ini

deletePath PATH $ATLAS_LOCAL_GANGA_PATH
alrb_result=`\find $ATLAS_LOCAL_ROOT/Ganga/${ATLAS_LOCAL_GANGA_VERSION}/install -name bin -type d`
export ATLAS_LOCAL_GANGA_PATH=$alrb_result
appendPath PATH $ATLAS_LOCAL_GANGA_PATH

alias generateGangarc='$ATLAS_LOCAL_ROOT_BASE/swConfig/ganga/generateGangarc.sh'

unset alrb_tmpAr alrb_item alrb_result

