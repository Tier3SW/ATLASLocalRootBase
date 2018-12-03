#!----------------------------------------------------------------------------
#!
#! relocateCvmfs-pool.csh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs-pool.csh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# change ATLAS_POOLCOND_PATH if it exists    
if ( $?ATLAS_POOLCOND_PATH ) then
    set alrb_result=`\grep $ATLAS_SW_BASE "$ATLAS_POOLCOND_PATH/poolcond/PoolFileCatalog.xml"`
    if ( $? != 0 ) then
	mkdir -p "$ALRB_localConfigDir/poolcond"
	set alrb_updateIt="NO"
	\rm -f $ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new
	\sed -e 's|/cvmfs|'$ATLAS_SW_BASE'|g' "$ATLAS_POOLCOND_PATH/poolcond/PoolFileCatalog.xml" > "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new"
	if ( -e "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml" ) then
	    set alrb_result=`diff "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml" "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new"`
	    if ( $? != 0 ) then
		set alrb_updateIt="YES"
	    endif
	 else
	    set alrb_updateIt="YES"
         endif
	 if ( "$alrb_updateIt" == "YES" ) then
	     mv "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new" "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml"
	 endif
	 setenv ATLAS_POOLCOND_PATH $ALRB_localConfigDir
     endif
endif


