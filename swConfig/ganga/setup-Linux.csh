#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup Ganga for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_GANGA_VERSION $1
set alrb_skipGangaRcCheck="NO"
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )
foreach alrb_item ($alrb_tmpAr)
set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
  switch ($alrb_tmpVal)
    case skipGangaRcCheck:
	set alrb_skipGangaRcCheck=`\echo $alrb_item | \cut -f 2 -d "="`
	breaksw
    endsw
end

setenv GANGA_CONFIG_PATH GangaAtlas/Atlas.ini

if ($?ATLAS_LOCAL_GANGA_PATH) then
    deletePath PATH $ATLAS_LOCAL_GANGA_PATH
endif
set alrb_result=`\find $ATLAS_LOCAL_ROOT/Ganga/${ATLAS_LOCAL_GANGA_VERSION}/install -name bin -type d`
setenv ATLAS_LOCAL_GANGA_PATH $alrb_result

appendPath PATH $ATLAS_LOCAL_GANGA_PATH

alias generateGangarc '$ATLAS_LOCAL_ROOT_BASE/swConfig/ganga/generateGangarc.sh'

unset alrb_tmpAr alrb_item alrb_result
