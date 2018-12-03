#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! checkInput.sh
#!
#! checks each required input file
#!
#! Usage:
#!     checkInput.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

source $ALRB_SMUDIR/shared.sh

alrb_errorFound="NO"
\echo " "
\echo "  Checking the individual files ..."
alrb_domain=`hostname -d`
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet 2>&1 > $ALRB_SMUDIR/checkInputGrid.log
source $ATLAS_LOCAL_ROOT_BASE/user/genericGridSetup.sh 2>&1 >> $ALRB_SMUDIR/checkInputGrid.log

alrb_result="which gfal-sum 2>&1"
if [ $? -ne 0 ]; then
    \echo " "
    \cat $ALRB_SMUDIR/checkInputGrid.log | \sed -e 's/^/  /g'
    \echo "  Error : gfal-sum is not found."
    \echo "                                                        ... Failed"
    exit 64
fi

\echo " "
\echo "  This will take a little time while datafiles are checked ..."
if [ ! -z $ALRB_TutorialData ]; then
    \echo "  \$ALRB_TutorialData is defined and will use that for data locations."
fi
if [ -z $ALRB_TutorialData ]; then
    alrb_result=`\grep -e "ALRBTD:${alrb_domain}" $ALRB_SMUDIR/config.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_tmpVal=`\echo $alrb_result | \cut -d ":" -f 3`
	if [ -d $alrb_tmpVal ]; then
	    \echo "  \$ALRB_TutorialData=$alrb_tmpVal for $alrb_domain found and used"
	    \echo "  You should define ALRB_TutorialData=$alrb_tmpVal in your login scripts"
	    export ALRB_TutorialData=$alrb_tmpVal
	fi
    fi
fi

# force ALRB_TutorialData setting 
while [ -z $ALRB_TutorialData ]; do
    \echo "  The env variable ALRB_TutorialData is not defined or cannot be determined."
    \echo "  This is given by the person who downloaded data with setMeUpData."
    \echo -n "  ALRB_TutorialData is (return to abort test) : "
    read alrb_dspath 
    alrb_dspath=`eval \echo $alrb_dspath`
    if [ "$alrb_dspath" = "" ]; then
	\echo "  Aborting ..."
	\echo "                                                        ... Failed"
	exit 64
    fi
    if [ ! -d "$alrb_dspath" ]; then	
	\echo "  $alrb_dspath does not exist on this node."
	alrb_dspath=""
    else
	export ALRB_TutorialData=$alrb_dspath
    fi
done

alrb_dspath=$ALRB_TutorialData

# dq2 - obsolete but we can check
alrb_dsList=( `\grep -e "^DS:" $ALRB_SMUDIR/config.txt` )
for alrb_ds in ${alrb_dsList[@]}; do
    \echo " " 
    alrb_idx=`\echo $alrb_ds | \cut -f 2 -d ":"`
    alrb_dsname=`\echo $alrb_ds | \cut -f 3 -d ":"`
    alrb_dsname0=`\echo $alrb_dsname | \sed -e 's|/$||'`

    alrb_downloadItem="${ALRB_downloadServer}/${alrb_tutorialVersion}/ds${alrb_idx}.txt"
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadItem >>  $ALRB_SMUDIR/wget_dq2-$alrb_idx.out 2>&1
    if [ $? -ne 0 ]; then    
	alrb_errorFound="YES"
    fi

    alrb_expectedPath=`\grep -e "^DSEL:$alrb_idx" $ALRB_SMUDIR/config.txt | \cut -f 3 -d ":"`
    if [ $? -eq 0 ]; then
	alrb_expectedPath0=`\echo $alrb_expectedPath | \sed 's/\_DDM/'$alrb_dsname0'/g'`
    else
	alrb_expectedPath0="$alrb_dsname0"
    fi

    \echo "  checking dataset : $alrb_dsname"    
    alrb_dsfList=( `\grep -e "^DSF:$alrb_idx" $ALRB_SMUDIR/config.txt | \cut -f 3 -d ":" ` )
    for alrb_dsf in ${alrb_dsfList[@]}; do
	alrb_theFile=`\find -L $alrb_dspath -maxdepth 6 -name $alrb_dsf 2>&1 | \grep $alrb_expectedPath0`
	if [ $? -ne 0 ]; then
	    \echo "   Error: file not found $alrb_dsf"
	    \echo "    Check that it is under a dir $alrb_expectedPath0"
	    alrb_errorFound="YES"
	    continue
	fi
	alrb_dq2Adler=`\grep $alrb_dsf $ALRB_SMUDIR/ds${alrb_idx}.txt | \cut -f 4 | \cut -d ":" -f 2 2>&1`
	if [ $? -ne 0 ]; then
	    \echo "   Error: file not found $alrb_dsf in $ALRB_SMUDIR/ds${alrb_idx}.txt"
	    alrb_errorFound="YES"
	    continue
	fi
	\echo "   Checking file $alrb_dsf ..."
	alrb_theFile0=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_theFile`
	alrb_nowAdler=`gfal-sum file://$alrb_theFile0 ADLER32 2>&1 | \cut -f 2 -d " "`
	if [ "$alrb_nowAdler" != "$alrb_dq2Adler" ]; then
	    \echo "    Error: adler mismatch $alrb_nowAdler != $alrb_dq2Adler"
	    alrb_errorFound="YES"
	    continue
	fi
    done
done    

alrb_result=`\grep -e "^RDID:" $ALRB_SMUDIR/config.txt`
if [ $? -eq 0 ]; then
# needed for adler32 check
    \echo " " 
    \echo "Will now setup rucio-clients but not proxy ..."
    source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet
    lsetup rucio
fi

alrb_rList=( `\grep -e "^RDID:" $ALRB_SMUDIR/config.txt` )
alrb_expectedPath0="none"
for alrb_theFile in ${alrb_rList[@]}; do
    alrb_scope=`\echo $alrb_theFile | \cut -f 2 -d ":"`
    alrb_file=`\echo $alrb_theFile | \cut -f 3 -d ":"`
    \echo " "
    \echo "  Checkimg rucio did : $alrb_scope:$alrb_file ..."
    alrb_pathFlag=`\echo $alrb_theFile | \cut -f 4 -d ":"`
    alrb_expectedPath=`\echo $alrb_theFile | \cut -f 5 -d ":"`
#    alrb_checksumType=`\echo $alrb_theFile | \cut -f 6 -d ":"`
    alrb_checksum=`\echo $alrb_theFile | \cut -f 7 -d ":"`

    if [ "alrb_expectedPath" != "" ]; then
	alrb_tmpVal="$ALRB_TutorialData/$alrb_expectedPath"
    else
	alrb_tmpVal="$ALRB_TutorialData"
    fi

   if [ "$alrb_pathFlag" = "A" ]; then
       alrb_expectedFile="$alrb_tmpVal/$alrb_file"
    else
       alrb_expectedFile="$alrb_tmpVal/$alrb_scope/$alrb_file"
    fi

    if [ -e "$alrb_expectedFile" ]; then
	alrb_tmpVal=`gfal-sum file://$alrb_expectedFile ADLER32 2>&1 | \cut -f 2 -d " "`
	if [ "$alrb_tmpVal" != "$alrb_checksum" ]; then
	    \echo "   Error: incorrect checksum."
	    alrb_errorFound="YES"
	fi
    else
	\echo "   Error: file not found."
	alrb_errorFound="YES"
    fi

done

alrb_dspath="$ALRB_TutorialData"
alrb_fList=( `\grep -e "^FWGET:" $ALRB_SMUDIR/config.txt` )
let alrb_step=0
for alrb_theFile in ${alrb_fList[@]}; do
    let alrb_step+=1
    \echo " "
    alrb_idx=`\echo $alrb_theFile | \cut -f 2 -d ":"`
    alrb_actualfile=`\echo $alrb_theFile | \cut -f 3 -d ":"`
    alrb_installDir=`\echo $alrb_theFile | \cut -f 4 -d ":"`

    alrb_result=`\echo $alrb_actualfile | \grep -e "\.tar\.gz$" -e "\.tgz$"`
    if [ $? -eq 0 ]; then
	alrb_md5file="${alrb_actualfile}.contents.md5sum"
    else
	alrb_md5file="${alrb_actualfile}.md5sum"
    fi

    \echo "  file:  $alrb_actualfile ..." 
    alrb_downloadItem="${ALRB_downloadServer}/${alrb_tutorialVersion}/${alrb_md5file}"
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadItem >>  $ALRB_SMUDIR/wget_md5sum-$alrb_step.out 2>&1
    if [ $? -ne 0 ]; then    
	\cat $ALRB_SMUDIR/wget_md5sum-$alrb_step.out
	\echo "    Error: Could not fetch $alrb_md5file"
	alrb_errorFound="YES"
	continue
    fi      

    alrb_expectedDir=`\grep -e "FWGETEL:${alrb_idx}" $ALRB_SMUDIR/config.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_expectedDir=`\echo $alrb_expectedDir | \cut -d ":" -f 3`
    else
	alrb_expectedDir=""
    fi

    alrb_OLDIFS="$IFS"
    IFS=$'\n'
    while read alrb_line; do
	alrb_expectedmd5=`\echo $alrb_line | \cut -f 1 -d " "`
	alrb_expectedFile=`\echo $alrb_line | \sed -e 's|.* \(.*\)|\1|'`
	alrb_expectedFile0=`\echo $alrb_expectedFile | \sed -e 's|.*/||'`
	\echo "   Checking $alrb_expectedFile ..."
	alrb_theFile=`\find -L $alrb_dspath -maxdepth 6 -name $alrb_expectedFile0 2>&1 | \grep -e "$alrb_expectedFile"` 
	if [ $? -ne 0 ]; then
	    \echo "    Error: $alrb_expectedFile not found !"
	    alrb_errorFound="YES"
	    continue
	fi
	alrb_theFile0=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_theFile`
	alrb_actualmd5=`md5sum $alrb_theFile0 | \cut -f 1 -d " "`
	if [ $? -eq 0 ]; then
	    if [ "$alrb_expectedmd5" != "$alrb_actualmd5" ]; then
		\echo "    Error: md5sum does not match for file $alrb_expectedFile"
		\echo "     $alrb_expectedmd5 != $alrb_actualmd5 "
		alrb_errorFound="YES"
	    fi
	else
	    \echo "$alrb_actualmd5" | \sed -e 's/^/   /g'
	    \echo "    Error: failed to get actual md5sum "
	    alrb_errorFound="YES"
	fi    
	if [ "$alrb_expectedDir" != "" ]; then
	    alrb_result=`\echo $alrb_theFile | \grep -e "$alrb_expectedDir"`
	    if [ $? -ne 0 ]; then
		\echo "    Error: file not in expected path $alrb_expectedDir"
		alrb_errorFound="YES"
	    fi
	fi
    done < $alrb_md5file
done

if [ "$alrb_errorFound" = "YES" ]; then
    \echo "                                                        ... Failed"
    exit 64
else
    \echo "                                                        ... OK"
fi

exit 0
