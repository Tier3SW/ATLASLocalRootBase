#!----------------------------------------------------------------------------
#!
#!  functions.sh
#!
#!    functions for CMT
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_fn_cmtPostInstall() 
{
    
    cd $alrb_InstallDir
    # fix absolute paths, need to do this for original file as it is called
    local alrb_mDir=`\find $installDir -name mgr -type d`
    local alrb_toFixAr=( "$alrb_mDir/setup.sh" "$alrb_mDir/setup.csh" )
    local alrb_toFix
    for alrb_toFix in ${alrb_toFixAr[@]}; do
	if [ -e $alrb_toFix ]; then
	    if [ ! -e $alrb_toFix.orig ]; then
		\cp $alrb_toFix $alrb_toFix.orig
	    fi
	    \rm -f $alrb_toFix.new
	    \sed -e 's|'$ATLAS_LOCAL_ROOT_BASE'|\$ATLAS_LOCAL_ROOT_BASE|g' $alrb_toFix.orig > $alrb_toFix.new
	    \mv $alrb_toFix.new $alrb_toFix
	fi
    done

    return 0
}


alrb_fn_cmtVersionConvert()
{
    local alrb_result=`\echo $1 | \sed -e 's|v1r|1\.|g' -e 's|p.*||g'`
    $ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_result 2
    return 0
}

