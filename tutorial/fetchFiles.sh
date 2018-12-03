#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! fetchFiles.sh
#!
#! fetch the files for the tutorial
#!
#! Usage:
#!     fetchFiles.sh --help
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_downloadServer="http://atlas-tier3-sw.web.cern.ch/atlas-Tier3-SW/repo/tutorial/"
alrb_errorFound="NO"

alrb_progname=fetchFiles.sh 

alrb_fn_fetchFilesHelp()
{
    \cat <<EOF

Usage: fetchFiles [options] <tutorial> <download dir>

    Fetch the files for the tutorial to <download dir>/tutorial/<tutorial>.  

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE.

    If you rerun this, it will refetch data files only if they are incorrect.

    <tutorial> takes the form of <site>-MMMYY 
      eg triumf-sep14 for the tutorial at TRIUMF in Sept 2014

    Note that tutorial attendies can define \$ALRB_TutorialData to point to
     <download dir>/tutorial/<tutorial> for the setMeUp application to run.  
     This will be explained when this application completes.

    Options (to override defaults) are:
     -h  --help                   Print this help message
     --quiet                      Print no output

EOF
}


#!----------------------------------------------------------------------------
function alrb_fn_domd5sumCheck {
#!----------------------------------------------------------------------------

    alrb_retCode=0
    alrb_OLDIFS="$IFS"
    IFS=$'\n'
    while read alrb_line; do
	alrb_expectedmd5=`\echo $alrb_line | \cut -f 1 -d " "`
	alrb_expectedFile=`\echo $alrb_line |\sed -e 's|.* \(.*\)|\1|'`
	if [ ! -e "./$alrb_expectedFile" ]; then
	    \echo "   Error: $alrb_expectedFile not found !"
	    alrb_errorFound="YES"
	    alrb_retCode=64
	    break
	fi
	alrb_actualmd5=`md5sum $alrb_expectedFile | \cut -f 1 -d " "`
	if [ $? -eq 0 ]; then
	    if [ "$alrb_expectedmd5" != "$alrb_actualmd5" ]; then
		\echo "   Error: md5sum does not match for file $alrb_expectedFile"
		\echo "     $alrb_expectedmd5 != $alrb_actualmd5 "
		alrb_errorFound="YES"
	    fi
	else
	    \echo "$alrb_actualmd5" |\sed -e 's/^/   /g'
	    \echo "   Error: failed to get actual md5sum "
	    alrb_errorFound="YES"
	fi	    
    done < $alrb_checksumFile
    IFS="$oldIFS"
    
    return $alrb_retCode
}


alrb_shortopts="h"
alrb_longopts="help,quiet"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    return 64
fi
eval set -- "$alrb_opts"

alrb_quietVal="NO"

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_fetchFilesHelp
            exit 0
            ;;
	--quiet)
	    alrb_quietVal="YES"
	    shift
	    ;;
        --)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 1
            ;;
    esac
done

if [ $# -ne 2 ]; then
    \echo "Error: incorrect arguments"
    alrb_fn_fetchFilesHelp
    exit 64
fi

alrb_tutorialVersion="none"
if [ "$*" != "" ]; then
    alrb_tutorialVersion=`\echo $* | \cut -f 1 -d " "`
fi

alrb_downloadDir="none"
if [ "$*" != "" ]; then
    alrb_downloadDir=`\echo $* | \cut -f 2 -d " "`
fi

source ${ATLAS_LOCAL_ROOT_BASE}/utilities/checkAtlasLocalRoot.sh

if [ "$alrb_tutorialVersion" = "none" ]; then
    alrb_fn_fetchFilesHelp
    \echo -e "Error: you need to specify the tutorial name.                           "'[\033[31mFAILED\033[0m]'
    exit 64
fi

if [ "$alrb_downloadDir" = "none" ]; then
    alrb_fn_fetchFilesHelp
    \echo -e "Error: you need to specify the download dir location                    "'[\033[31mFAILED\033[0m]'
    exit 64
fi

\mkdir -p $alrb_downloadDir
if [ $? -eq 0 ]; then
    alrb_downloadDir=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_downloadDir`
else
    \echo -e "Error: failed to create download dir.                                   "'[\033[31mFAILED\033[0m]'
    exit 64
fi

touch $alrb_downloadDir/deleteIt.txt
if [ $? -ne 0 ]; then
    \echo "Error: unable to create files in $alrb_downloadDir."
    \echo -e "Error: aborting now ...                                                 "'[\033[31mFAILED\033[0m]'
    exit 64
fi
\rm -f $alrb_downloadDir/deleteIt.txt

ALRB_tutorialFetch="$ALRB_SCRATCH/tutorialFetch"
\mkdir -p $ALRB_tutorialFetch
if [ $? -ne 0 ]; then
    \echo -e "Error: cannot create the workdir.                                       "'[\033[31mFAILED\033[0m]'
    exit 64    
fi
\rm -rf $ALRB_tutorialFetch/*

# fetch the tutorial cfg
alrb_oldDir=`pwd`
cd $ALRB_tutorialFetch
alrb_downloadURLVal="${alrb_downloadServer}/${alrb_tutorialVersion}/config.txt"
$ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadURLVal > $ALRB_tutorialFetch/wget_tutorial.out 2>&1
alrb_rc=$?
cd $alrb_oldDir
if [ $alrb_rc -ne 0 ]; then    
    \cat $ALRB_tutorialFetch/wget_tutorial.out
    \echo "Could not fetch configuration for $alrb_tutorialVersion         "
    \echo -e " Please check if the name is correct.                                   "'[\033[31mFAILED\033[0m]'
    exit 64
fi

# check if this requires dq2; if it does, mark it as obsolete
alrb_result=`\grep -e "^DS:" $ALRB_tutorialFetch/config.txt`
if [ $? -eq 0 ]; then
    \echo "Old tutorial needing dq2 for dataset downloads ... "
    \echo "  DQ2 is obsolete but is needed to download the $alrb_tutorialVersion data;"
    \echo "   If you cannot move to a newer tutorial and need these datafiles,"
    \echo "   scp it from one of these places (or run it there):"
    \grep -e "^ALRBTD:" $ALRB_tutorialFetch/config.txt | \cut -f 2- -d ":" | \sed -e 's|^|    |g'
    \echo -e "Error: Failed to fetch datafiles                                        "'[\033[31mFAILED\033[0m]'
    exit 64
fi

alrb_downloadDir="$alrb_downloadDir/tutorial/$alrb_tutorialVersion"
\mkdir -p $alrb_downloadDir

alrb_result=`\grep -e "^RDID:" $ALRB_tutorialFetch/config.txt`
if [ $? -eq 0 ]; then
    \echo " " 
    \echo "Will now setup rucio-clients and a proxy if needed ..."
    source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet
    lsetup rucio
    
    alrb_result=`voms-proxy-info --timeleft 2>&1`
    if [[ $? -ne 0 ]] || [[ $alrb_result -lt 7200 ]]; then
	stty -echo
	voms-proxy-init -voms atlas 
	alrb_rc=$?
	stty echo
	if [ $alrb_rc -ne 0 ]; then
	    \echo -e "Error: Unable to get proxy                                              "'[\033[31mFAILED\033[0m]'
	    exit 64
	fi
    fi
fi

\echo " "
\echo "Will now download all required files to $alrb_downloadDir ..."


alrb_rList=( `\grep -e "^RDID:" $ALRB_tutorialFetch/config.txt` )
alrb_expectedPath0="none"
for alrb_theFile in ${alrb_rList[@]}; do
    alrb_scope=`\echo $alrb_theFile | \cut -f 2 -d ":"`
    alrb_file=`\echo $alrb_theFile | \cut -f 3 -d ":"`
    \echo " "
    \echo "  Fetching rucio did : $alrb_scope:$alrb_file ..."
    alrb_pathFlag=`\echo $alrb_theFile | \cut -f 4 -d ":"`
    alrb_expectedPath=`\echo $alrb_theFile | \cut -f 5 -d ":"`
#    alrb_checksumType=`\echo $alrb_theFile | \cut -f 6 -d ":"`
    alrb_checksum=`\echo $alrb_theFile | \cut -f 7 -d ":"`

    if [ "alrb_expectedPath" != "" ]; then
	alrb_dspath="$alrb_downloadDir/$alrb_expectedPath"
	\mkdir -p $alrb_dspath
    else
	alrb_dspath="$alrb_downloadDir"
    fi
    cd $alrb_dspath

    alrb_expectedFile="$alrb_dspath"
   if [ "$alrb_pathFlag" = "A" ]; then
	alrb_expectedFile="$alrb_dspath/$alrb_file"
    else
	alrb_expectedFile="$alrb_dspath/$alrb_scope/$alrb_file"
    fi

    if [ -e "$alrb_expectedFile" ]; then
	alrb_tmpVal=`gfal-sum $alrb_expectedFile ADLER32 2>&1 | \cut -f 2 -d " "`
	if [ "$alrb_tmpVal" != "$alrb_checksum" ]; then
	    \echo "   $alrb_scope:$alrb_file found; incorrect checksum; deleting ..."
	    \rm -rf $alrb_expectedFile
	else
	    \echo "   $alrb_scope:$alrb_file found; skipping ..."
	    continue
	fi
    fi

    rucio get --dir $alrb_dspath $alrb_scope:$alrb_file
    if [ $? -ne 0 ]; then
	\echo "    Error: failed to fetch $alrb_scope:$alrb_file"
	alrb_errorFound="YES"
    else
	if [ ! -e $alrb_expectedFile ]; then
	    \mv $alrb_dspath/$alrb_scope/$alrb_file $alrb_expectedFile 
	fi
    fi
done


alrb_fList=( `\grep -e "^FWGET:" $ALRB_tutorialFetch/config.txt` )
for alrb_theFile in ${alrb_fList[@]}; do
    \echo " "
    alrb_actualfile=`\echo $alrb_theFile | \cut -f 3 -d ":"`
    alrb_installDir=`\echo $alrb_theFile | \cut -f 4 -d ":"`
    alrb_md5file="${alrb_actualfile}.md5sum"
    alrb_idx=`\echo $alrb_theFile | \cut -f 2 -d ":"`
    \mkdir -p $alrb_downloadDir/$alrb_installDir/.smu
    cd $alrb_downloadDir/$alrb_installDir
    \echo "  Fetching $alrb_actualfile ..."

    alrb_result=`\echo $alrb_actualfile | \grep -e "\.tar\.gz$" -e "\.tgz$"`
    if [ $? -eq 0 ]; then
	alrb_isTarbell="YES"
	alrb_contentsmd5file="${alrb_actualfile}.contents.md5sum"
    else
	alrb_isTarbell="NO"
	alrb_contentsmd5file=""
    fi

# file's md5sum
    \rm -f ${alrb_md5file}
    alrb_downloadItem="${alrb_downloadServer}/${alrb_tutorialVersion}/${alrb_md5file}"
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadItem >>  $ALRB_tutorialFetch/wget_tutorial-$alrb_idx-md5sum.out 2>&1
    if [ $? -ne 0 ]; then    
	\cat $ALRB_tutorialFetch/wget_tutorial-$alrb_idx-md5sum.out
	\echo "    Error: Could not fetch $alrb_md5file"
	alrb_errorFound="YES"
	continue
    fi      
    if [ -e "./.smu/$alrb_md5file" ]; then
	alrb_result=`diff ./.smu/$alrb_md5file ./$alrb_md5file`
	if [ $? -eq 0 ]; then
	    \echo "    $alrb_actualfile was installed and md5sum unchanged.  Skip."
	    continue
	else
	    \echo "    Cleaning up old installation ..."
	    \rm -f ./.smu/${alrb_md5file}
	    if [ -e ./.smu/${alrb_contentsmd5file} ]; then
		\echo "    Cleaning up unpacked tarall ..."
		alrb_OLDIFS="$IFS"
		IFS=$'\n'
		while read alrb_line; do
		    alrb_expectedFile=`\echo $alrb_line |\sed -e 's|.* \(.*\)|\1|'`
		    \rm -f $alrb_expectedFile
		done < ./.smu/${alrb_contentsmd5file}
		IFS="$oldIFS"
		\rm -f ./.smu/${alrb_contentsmd5file}
	    fi
	fi
    fi

# file itself
    \rm -f $alrb_actualfile
    alrb_downloadItem="${alrb_downloadServer}/${alrb_tutorialVersion}/${alrb_actualfile}"
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadItem >>  $ALRB_tutorialFetch/wget_tutorial-$alrb_idx.out 2>&1
    if [ $? -ne 0 ]; then    
	\cat $ALRB_tutorialFetch/wget_tutorial-$alrb_idx.out
	\echo "    Error: Could not fetch $alrb_actualfile"
	alrb_errorFound="YES"
	continue
    fi      
    alrb_checksumFile=$alrb_md5file
    alrb_fn_domd5sumCheck
    if [ $? -ne 0 ]; then
	continue
    fi
    \mv ./$alrb_md5file ./.smu/$alrb_md5file 

# file is a tarball and needs post-processing
    if [ "$alrb_isTarbell" = "YES" ]; then
	\echo "   Unpacking tarball and checking contents ..."
	\tar zxf $alrb_actualfile
	\rm -f $alrb_actualfile
	\rm -f $alrb_contentsmd5file
	alrb_downloadItem="${alrb_downloadServer}/${alrb_tutorialVersion}/${alrb_contentsmd5file}"
	$ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh $alrb_downloadItem >>  $ALRB_tutorialFetch/wget_tutorial-$alrb_idx-conmd5.out 2>&1
	if [ $? -ne 0 ]; then    
	    \cat $ALRB_tutorialFetch/wget_tutorial-$alrb_idx-conmd5.out
	    \echo "    Error: Could not fetch $alrb_contentsmd5file"
	    alrb_errorFound="YES"
	    continue
	fi      
	alrb_checksumFile=$alrb_contentsmd5file
	alrb_fn_domd5sumCheck
	if [ $? -ne 0 ]; then
	    contunue
	fi
	\mv ./$alrb_contentsmd5file ./.smu/$alrb_contentsmd5file	
    fi

done

\echo " "
\echo "************************************************************************"
\echo "NOTE:"
\echo "You can ask the tutorial attendies to define this env variable, "
\echo " or define it for all logins, and setMeUp will automatically use it."
\echo " "
\echo " bash/zsh shells: "
\echo "  export ALRB_TutorialData=$alrb_downloadDir"
\echo " tcsh shell: "
\echo "  setenv ALRB_TutorialData $alrb_downloadDir"  
alrb_tmpVal=`hostname -f | \cut -d "." -f 2-`
\echo -e '\033[1;34m'"
Important: site admins (or if you are doing this for a major site) :
  Please report this next line to desilva@triumf.ca
    $alrb_tutorialVersion ALRBTD:$alrb_tmpVal:$alrb_downloadDir
  if you want users to find this data automatically at your site. 
"'\033[0m'
\echo "************************************************************************"
\echo " "
if [ "$alrb_errorFound" = "YES" ]; then
    \echo -e "Error: Some files were not fetched.                                     "'[\033[31mFAILED\033[0m]'
    exit 64
else
    \echo -e "Fetched files  ...                                                      "'[\033[32m  OK  \033[0m]'
fi
