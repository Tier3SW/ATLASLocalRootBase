#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! postInstallChanges.sh
#!
#! After everything is installed, run this
#!
#! Usage:
#!     postInstallChanges.sh
#!
#! History:
#!   26Aug10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

let alrb_retCode=0

source $ATLAS_LOCAL_ROOT_BASE/utilities/checkAtlasLocalRoot.sh

if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/gcc/createGccSlc5Wrapper.sh ]; then
    \echo " "
    \echo "Creating gcc wrapper for slc5  ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/gcc/createGccSlc5Wrapper.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi    
fi

if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetup.sh ]; then
    \echo " "
    \echo "Creating the AtlasSetup site files ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetup.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi
fi

if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupTest.sh ]; then
    \echo " "
    \echo "Creating the AtlasSetup (test) site files ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupTest.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi
fi

if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupCMake.sh ]; then
    \echo " "
    \echo "Creating the AtlasSetupCMake site files ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupCMake.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi
fi

if [ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupCMakeTest.sh ]; then
    \echo " "
    \echo "Creating the AtlasSetupCMake (test) site files ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createSiteASetupCMakeTest.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi
fi



if [[ "$ALRB_OSTYPE" = "Linux" ]] && [[ -e $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createLcgArea.sh ]]; then
    \echo " "
    \echo "Creating the lcgarea dir ..."
    $ATLAS_LOCAL_ROOT_BASE/swConfig/asetup/createLcgArea.sh
    if [ $? -ne 0 ]; then
	let alrb_retCode=64
    fi
fi

\echo " " 
\echo "Creating wrapper ... "
$ATLAS_LOCAL_ROOT_BASE/utilities/createWrappers.sh
if [ $? -ne 0 ]; then
    let alrb_retCode=64
fi

\echo " "
\echo "Creating mapfile ..."
$ATLAS_LOCAL_ROOT_BASE/swConfig/createMaps.sh
if [ $? -ne 0 ]; then
    let alrb_retCode=64
fi


exit $alrb_retCode
