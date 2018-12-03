#!----------------------------------------------------------------------------
#!
#! relocateCvmfs-asetup.csh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs-asetup.csh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# change AtlasSetupSite if it exists    
if ( $?AtlasSetupSite ) then
    set alrb_asetupLocalConfigDir="$ALRB_localConfigDir/asetup-config"
    mkdir -p $alrb_asetupLocalConfigDir
    set alrb_result=`\grep -e releasesarea -e nightliesarea $AtlasSetupSite | \grep -e $ATLAS_SW_BASE`
    if ( $? != 0 ) then
	set alrb_updateIt="NO"
	\rm -f $alrb_asetupLocalConfigDir/.asetup.site.new
	\sed -e 's|\([= :]\)/cvmfs|\1'$ATLAS_SW_BASE'|g' $AtlasSetupSite > $alrb_asetupLocalConfigDir/.asetup.site.new 
	if ( -e $alrb_asetupLocalConfigDir/.asetup.site ) then
	    set alrb_result=`diff $alrb_asetupLocalConfigDir/.asetup.site $alrb_asetupLocalConfigDir/.asetup.site.new`
	    if ( $? != 0 ) then
		set alrb_updateIt="YES"
	    endif
	else
	    set alrb_updateIt="YES"
        endif
	if ( "$alrb_updateIt" == "YES" ) then
	    mv $alrb_asetupLocalConfigDir/.asetup.site.new $alrb_asetupLocalConfigDir/.asetup.site 
	endif
	setenv AtlasSetupSite $alrb_asetupLocalConfigDir/.asetup.site
    endif
    unset alrb_asetupLocalConfigDir
endif

# change AtlasSetupSiteCMake if it exists    
if ( $?AtlasSetupSiteCMake ) then
    set alrb_asetupLocalConfigDir="$ALRB_localConfigDir/asetup-cmake-config"
    mkdir -p $alrb_asetupLocalConfigDir
    set alrb_result=`\grep -e releasesarea -e nightliesarea $AtlasSetupSiteCMake | \grep -e $ATLAS_SW_BASE`
    if ( $? != 0 ) then
	set alrb_updateIt="NO"
	\rm -f $alrb_asetupLocalConfigDir/.asetup.site.new
	\sed -e 's|\([= :]\)/cvmfs|\1'$ATLAS_SW_BASE'|g' $AtlasSetupSiteCMake > $alrb_asetupLocalConfigDir/.asetup.site.new 
	if ( -e $alrb_asetupLocalConfigDir/.asetup.site ) then
	    set alrb_result=`diff $alrb_asetupLocalConfigDir/.asetup.site $alrb_asetupLocalConfigDir/.asetup.site.new`
	    if ( $? != 0 ) then
		set alrb_updateIt="YES"
	    endif
	else
	    set alrb_updateIt="YES"
        endif
	if ( "$alrb_updateIt" == "YES" ) then
	    mv $alrb_asetupLocalConfigDir/.asetup.site.new $alrb_asetupLocalConfigDir/.asetup.site 
	endif
	setenv AtlasSetupSiteCMake $alrb_asetupLocalConfigDir/.asetup.site
    endif
    unset alrb_asetupLocalConfigDir
endif

