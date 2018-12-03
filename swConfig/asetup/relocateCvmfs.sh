#!----------------------------------------------------------------------------
#!
#! relocateCvmfs-asetup.sh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs-asetup.sh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# change AtlasSetupSite if it exists    
if [ ! -z $AtlasSetupSite ]; then
    alrb_asetupLocalConfigDir="$ALRB_localConfigDir/asetup-config"
    mkdir -p $alrb_asetupLocalConfigDir
    alrb_result=`\grep -e releasesarea -e nightliesarea $AtlasSetupSite | \grep -e $ATLAS_SW_BASE 2>&1`
    if [ $? -ne 0 ]; then
	alrb_updateIt="NO"
	\rm -f $alrb_asetupLocalConfigDir/.asetup.site.new
	\sed -e 's|\([= :]\)/cvmfs|\1'$ATLAS_SW_BASE'|g' $AtlasSetupSite > $alrb_asetupLocalConfigDir/.asetup.site.new 
	if [ -e $alrb_asetupLocalConfigDir/.asetup.site ]; then
	    alrb_result=`diff $alrb_asetupLocalConfigDir/.asetup.site $alrb_asetupLocalConfigDir/.asetup.site.new 2>&1`
	    if [ $? -ne 0 ]; then
		alrb_updateIt="YES"
	    fi
	else
	    alrb_updateIt="YES"
	fi
	if [ "$alrb_updateIt" = "YES" ]; then
	    mv $alrb_asetupLocalConfigDir/.asetup.site.new $alrb_asetupLocalConfigDir/.asetup.site 
	fi
	export AtlasSetupSite=$alrb_asetupLocalConfigDir/.asetup.site
    fi
    unset alrb_asetupLocalConfigDir
fi

# change AtlasSetupSiteCMake if it exists    
if [ ! -z $AtlasSetupSiteCMake ]; then
    alrb_asetupLocalConfigDir="$ALRB_localConfigDir/asetup-cmake-config"
    mkdir -p $alrb_asetupLocalConfigDir
    alrb_result=`\grep -e releasesarea -e nightliesarea $AtlasSetupSiteCMake | \grep -e $ATLAS_SW_BASE 2>&1`
    if [ $? -ne 0 ]; then
	alrb_updateIt="NO"
	\rm -f $alrb_asetupLocalConfigDir/.asetup.site.new
	\sed -e 's|\([= :]\)/cvmfs|\1'$ATLAS_SW_BASE'|g' $AtlasSetupSiteCMake > $alrb_asetupLocalConfigDir/.asetup.site.new 
	if [ -e $alrb_asetupLocalConfigDir/.asetup.site ]; then
	    alrb_result=`diff $alrb_asetupLocalConfigDir/.asetup.site $alrb_asetupLocalConfigDir/.asetup.site.new 2>&1`
	    if [ $? -ne 0 ]; then
		alrb_updateIt="YES"
	    fi
	else
	    alrb_updateIt="YES"
	fi
	if [ "$alrb_updateIt" = "YES" ]; then
	    mv $alrb_asetupLocalConfigDir/.asetup.site.new $alrb_asetupLocalConfigDir/.asetup.site 
	fi
	export AtlasSetupSiteCMake=$alrb_asetupLocalConfigDir/.asetup.site
    fi
    unset alrb_asetupLocalConfigDir
fi



