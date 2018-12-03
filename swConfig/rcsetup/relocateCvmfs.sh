#!----------------------------------------------------------------------------
#!
#! relocateCvmfs-rcsetup.sh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs-rcsetup.sh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# change rcSetupSite if it exists    
if [ ! -z $rcSetupSite ]; then
    alrb_result=`\grep $ATLAS_SW_BASE $rcSetupSite 2>&1`
    if [ $? -ne 0 ]; then
	alrb_updateIt="NO"
	\rm -f $ALRB_localConfigDir/.rcsetup.site.new
	\sed -e 's|/cvmfs|'$ATLAS_SW_BASE'|g' $rcSetupSite > $ALRB_localConfigDir/.rcsetup.site.new
	if [ -e $ALRB_localConfigDir/.rcsetup.site ]; then
	    alrb_result=`diff $ALRB_localConfigDir/.rcsetup.site $ALRB_localConfigDir/.rcsetup.site.new 2>&1`
	    if [ $? -ne 0 ]; then
		alrb_updateIt="YES"
	    fi
	else
	    alrb_updateIt="YES"
	fi
	if [ "$alrb_updateIt" = "YES" ]; then
	    mv $ALRB_localConfigDir/.rcsetup.site.new $ALRB_localConfigDir/.rcsetup.site 
	fi
	export rcSetupSite=$ALRB_localConfigDir/.rcsetup.site
    fi
fi
