#!----------------------------------------------------------------------------
#!
#! relocateCvmfs-pool.sh
#!
#! defines relocatable env for cvmfs
#!
#! These need to be defined:
#!   ATLAS_SW_BASE should be defined and point to somewhere other than /cvmfs
#!   ALRB_localConfigDir needs to be defined to a writebale area  
#!
#! Usage: 
#!     source relocateCvmfs-pool.sh
#!
#! History:
#!   16Jul14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

# change ATLAS_POOLCOND_PATH if it exists    
if [ ! -z $ATLAS_POOLCOND_PATH ]; then
    alrb_result=`\grep $ATLAS_SW_BASE "$ATLAS_POOLCOND_PATH/poolcond/PoolFileCatalog.xml" 2>&1`
    if [ $? -ne 0 ]; then
	mkdir -p "$ALRB_localConfigDir/poolcond"
	alrb_updateIt="NO"
	\rm -f $ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new
	\sed -e 's|/cvmfs|'$ATLAS_SW_BASE'|g' "$ATLAS_POOLCOND_PATH/poolcond/PoolFileCatalog.xml" > "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new"
	if [ -e "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml" ]; then
	    alrb_result=`diff "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml" "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new" 2>&1`
	    if [ $? -ne 0 ]; then
		alrb_updateIt="YES"
	    fi
	else
	    alrb_updateIt="YES"
	fi
	if [ "$alrb_updateIt" = "YES" ]; then
	    mv "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml.new" "$ALRB_localConfigDir/poolcond/PoolFileCatalog.xml"
	fi
	export ATLAS_POOLCOND_PATH=$ALRB_localConfigDir
    fi
fi


