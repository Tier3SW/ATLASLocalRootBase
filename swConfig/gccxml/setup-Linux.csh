#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup gccxml for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


setenv ATLAS_LOCAL_GCCXML_VERSION $1
setenv ATLAS_LOCAL_GCCXML_PATH ${ATLAS_LOCAL_ROOT}/gccxml/${ATLAS_LOCAL_GCCXML_VERSION}

set alrb_gccxmlBin=`\find $ATLAS_LOCAL_GCCXML_PATH -name bin -type d`
if ( -d ${alrb_gccxmlBin} ) then
    insertPath PATH $alrb_gccxmlBin
else
    \echo "Error: bin dir for gccxml not found $ATLAS_LOCAL_GCCXML_PATH ..." > /dev/stderr
endif
    
unset alrb_gccxmlBin
