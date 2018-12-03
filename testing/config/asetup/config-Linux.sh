#!----------------------------------------------------------------------------
#!
#! config-Linux.sh 
#!
#! configs for tool testing
#!
#! Usage:
#!     not directly
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

##
## asetup configurations:

##
## releases to use for testing
## ALRB_testAsetupReleaseList= list of releases to setup separated by ;
if [ -z $ALRB_testAsetupReleaseList ]; then
    if [ "$ALRB_OSMAJORVER" = "6" ]; then
# slc6 machine tests
	export ALRB_testAsetupReleaseList="AthAnalysisSUSY,2.3.46,slc6;16.6.7,slc5,gcc43,32;19.0.3,slc6;AtlasOffline,21.0.8,slc6;Athena,21.0.33,slc6;AthAnalysis,21.2.27,slc6"
    else
# slc7 machine tests
	export ALRB_testAsetupReleaseList="AthAnalysisSUSY,2.3.46,slc6;19.0.3,slc6;AtlasOffline,21.0.8,slc6;Athena,21.0.33,slc6;AthAnalysis,21.2.27,slc6"
    fi
fi

##
## version to use for reference and comparision
## ALRB_asetupVersion="current"
## ALRB_testAsetupVersionNew="testing"
if [ -z $ALRB_asetupVersion ]; then
    export ALRB_asetupVersion="current"
fi
if [ -z $ALRB_testAsetupVersionNew ]; then
    export ALRB_testAsetupVersionNew="testing"
fi

##
## site config files for reference and comparison
## ALRB_testASetupCScript=
## ALRB_testASetupCScriptNew=
if [ -z $ALRB_testASetupCScript ]; then 
    export ALRB_testASetupCScript="$ATLAS_LOCAL_ROOT/AtlasSetup/.config/.asetup.site"
fi
if [ -z $ALRB_testASetupCScriptNew ]; then
    export ALRB_testASetupCScriptNew="$ATLAS_LOCAL_ROOT/AtlasSetup/.config/.asetup.site"
fi


##
## site config files for reference and comparison (cmake)
## ALRB_testASetupCMakeScript=
## ALRB_testASetupCMakeScriptNew=
if [ -z $ALRB_testASetupCMakeScript ]; then 
    export ALRB_testASetupCMakeScript="$ATLAS_LOCAL_ROOT/AtlasSetup/.configCMake/.asetup.site"
fi
if [ -z $ALRB_testASetupCMakeScriptNew ]; then
    export ALRB_testASetupCMakeScriptNew="$ATLAS_LOCAL_ROOT/AtlasSetup/.configCMake/.asetup.site"
fi




