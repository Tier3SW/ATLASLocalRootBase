#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! createMaps.sh
#!
#! creates maps for installed sw
#!
#! Usage:
#!     createMaps.sh
#!
#! History:
#!   09May16: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/functions.sh

alrb_SetupToolAr=( `\grep -i -e '^,[A-Z]*' $ATLAS_LOCAL_ROOT_BASE/swConfig/synonyms.txt | \cut -f 4 -d ","  |  \tr '[:upper:]' '[:lower:]'` )

for alrb_item in ${alrb_SetupToolAr[@]}; do
    alrb_fn_createReleaseMap $alrb_item
done

exit 0


