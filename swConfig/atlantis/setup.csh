#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup Atlantis for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_ATLANTIS_VERSION $1
setenv ATLAS_LOCAL_ATLANTIS_PATH ${ATLAS_LOCAL_ROOT}/Atlantis/${ATLAS_LOCAL_ATLANTIS_VERSION}/AtlantisJava

set alrb_javaAtlantis="java"
set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )
foreach alrb_item ($alrb_tmpAr) 
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
        case alrb_javaHome:
	    set alrb_javaAtlantis=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
	default:
	    breaksw
    endsw
end

if ( $ALRB_OSTYPE == "MacOSX" ) then
    alias runAtlantis '$alrb_javaAtlantis -Dapple.awt.graphics.UseQuartz=false -jar $ATLAS_LOCAL_ATLANTIS_PATH/atlantis.jar'
else
    alias runAtlantis '$alrb_javaAtlantis -jar $ATLAS_LOCAL_ATLANTIS_PATH/atlantis.jar'
endif

unset alrb_tmpAr alrb_tmpVal alrb_item

