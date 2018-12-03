#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! preim.sh
#!
#! Preliminary message about tutorial and requirements
#!
#! Usage:
#!     premim.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

source $ALRB_SMUDIR/shared.sh

# print title 
\echo -e "\033[1;34m"
\echo "-------------------------------------------------------------------------"
\grep -e "^T:" $ALRB_SMUDIR/config.txt | \sed -e 's/T://'
\grep -e "^URL:" $ALRB_SMUDIR/config.txt | \sed -e 's/URL://'
\echo "-------------------------------------------------------------------------"
\echo -e "\033[0m"
\echo "This is a test to check that the tutorial can run on this computing node."

\echo "
These are the requirements;  please ensure that they are met before you 
continue with this check (they will be verified):
"
let alrb_step=0


let alrb_step+=1
\echo -e "\033[1;36m$alrb_step: ATLAS ready computing node\033[0m"
\echo "
  This node needs to be ATLAS ready and running on a compatible OS with 
  all needed additional software installed and cvmfs available.
"
$ATLAS_LOCAL_ROOT_BASE/tutorial/listOS.sh | \sed -e 's/^/  /g'
\echo "
  You can check that your computer is ATLAS ready by doing
    setupATLAS
    diagnostics
    checkOS
"

let alrb_step+=1
\echo -e "\033[1;36m$alrb_step: Valid and registered grid certificate\033[0m"
\echo "
  You will need a vaild grid certificate registered with LCG and installed 
  in \$HOME/.globus

  You can check that your grid credentials are good by doing:
    setupATLAS
    diagnostics
    gridCert
"

let alrb_step+=1
\echo -e "\033[1;36m$alrb_step: Environment set\033[0m"
\echo "
  You should have the environment variable
    RUCIO_ACCOUNT  (=<your lxplus username>)
  defined in your login scripts so that it is available.
"

let alrb_step+=1
\echo -e "\033[1;36m$alrb_step: SVN Checkout - Kerberos or Public Key\033[0m"
\echo "
  You will need to ensure that you can do password-less svn checkouts.  This can
  be either Kerberos authenticated or using public keys.  To set this up, 
  please see;
    https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Password-lessSsh

  There is a template file \$ATLAS_LOCAL_ROOT_BASE/user/sshConfig; you can
    cp \$ATLAS_LOCAL_ROOT_BASE/user/sshConfig ~/.ssh/config
  and make the appropriate changes in ~/.ssh/config.

  If your site cannot configure kerberos authentication, you can 
   put this in your login scripts after ATLAS_LOCAL_ROOT_BASE is defined:"
if [[ "$ALRB_SHELL" = "bash" ]] || [[ "$ALRB_SHELL" = "zsh" ]]; then
    \echo "     export KRB5_CONFIG=\$ATLAS_LOCAL_ROOT_BASE/user/krb5.conf"
else
    \echo "     setenv KRB5_CONFIG \$ATLAS_LOCAL_ROOT_BASE/user/krb5.conf"
fi
\echo " "


alrb_result=`\grep -e "^FS:" $ALRB_SMUDIR/config.txt 2>&1`
if [ $? -eq 0 ]; then
    let alrb_step+=1
    \echo -e "\033[1;36m$alrb_step: Available disk space\033[0m"
    alrb_result=`\echo $alrb_result | \cut -f 2 -d ":"`
    \echo "
  You will need $alrb_result MB of free space.  It can be \$HOME or any other 
  location - note the location as you will be asked for it.  

  If you are running on lxplus, you can request your home dir quota be 
  increased to 10GB or request up to an additional 100GB of workspace.  To ask 
  for space, go to (use your lxplus username below)
    https://resources.web.cern.ch/resources/Manage/AFS/Settings.aspx?login=<your lxplus username>
  You may need to request repeatedly to get the full quota (it is granted in 
  increments.)

  To check how much quota you have on /afs (eg on lxplus), type fs lq; eg.
    fs lq $HOME
    fs lq /afs/cern.ch/work/d/desilva # for workspace if you have it
"
fi

let alrb_step+=1
\echo -e "\033[1;36m$alrb_step: Input files\033[0m"
\echo "
  You will need these input datasets available.  
  
  If you do not have them, you can fetch them by running
    setupATLAS
    diagnostics
    setMeUpData $alrb_tutorialVersion <download dir>
  and then, define the environment variable \$ALRB_TutorialData to point to
    <download dir>/tutorial/$alrb_tutorialVersion
  
  Do NOT define \$ALRB_TutorialData unless the data was downloaded by 
   setMeUpData.  A certain structure is expected and setMeUpData does this.

  Note that they are already staged at some sites, as indicated below, in 
  which case you do not have to download."

alrb_dsList=( `\grep -e "^DS:" $ALRB_SMUDIR/config.txt` )
for alrb_ds in ${alrb_dsList[@]}; do
    alrb_idx=`\echo $alrb_ds | \cut -f 2 -d ":"`
    alrb_dsname=`\echo $alrb_ds | \cut -f 3 -d ":"`
    
    alrb_expectedPath=`\grep -e "^DSEL:$alrb_idx" $ALRB_SMUDIR/config.txt | \cut -f 3 -d ":"`
    if [ $? -ne 0 ]; then
	alrb_expectedPath=""
	alrb_expectedPath0=""
    else
	alrb_expectedPath0=`\echo $alrb_expectedPath | \sed 's/\_DDM//g'`
    fi
    \echo " "
    \echo "  Dataset : $alrb_dsname"
    if [ "$alrb_expectedPath0" != "" ]; then
	\echo "   Expected Path: $alrb_expectedPath0"
    fi
    \echo "   Files : "
    \grep -e "^DSF:$alrb_idx" $ALRB_SMUDIR/config.txt | \cut -f 3 -d ":" | \sed 's/^/    /'
    alrb_dspath=""
    alrb_result=`\grep -e "DSL:${alrb_idx}:${domain}" $ALRB_SMUDIR/config.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_dspath=`\echo $alrb_result | \cut -d ":" -f 4`
	if [ ! -d $alrb_dspath ]; then
	    \echo "   Note:"
	    \echo "    $alrb_dspath does not exist on this node for defined domain $domain."
	    \echo "    You will need to specify the path for this dataset."
	    alrb_dspath=""
	fi
    fi
done

alrb_rList=( `\grep -e "^RDID:" $ALRB_SMUDIR/config.txt` )
alrb_expectedPath0="none"
for alrb_theFile in ${alrb_rList[@]}; do
    alrb_did=`\echo $alrb_theFile | \cut -f 2-3 -d ":"`
    alrb_pathFlag=`\echo $alrb_theFile | \cut -f 4 -d ":"`
    alrb_expectedPath=`\echo $alrb_theFile | \cut -f 5 -d ":"`
    if [ "$alrb_expectedPath0" != "$alrb_expectedPath" ]; then
	\echo " "
	\echo "  DIDs:"
	alrb_expectedPath0=$alrb_expectedPath
	if [ "$alrb_expectedPath" != "" ]; then
	    if [ "$alrb_pathFlag" = "A" ]; then
		\echo "   Expected Path: $alrb_expectedPath0"  
	    else
		\echo "   Expected Path: relative to $alrb_expectedPath0"  
	    fi
	else
	    \echo "   Expected Path: (set by rucio)"  
	fi
    fi
    \echo "   $alrb_did"
done

alrb_fList=( `\grep -e "^FWGET:" $ALRB_SMUDIR/config.txt` )
for alrb_theFile in ${alrb_fList[@]}; do
    alrb_idx=`\echo $alrb_theFile | \cut -f 2 -d ":"`
    alrb_actualfile=`\echo $alrb_theFile | \cut -f 3 -d ":"`
    alrb_installDir=`\echo $alrb_theFile | \cut -f 4 -d ":"`
    \echo " "
    \echo "  File : $alrb_actualfile"

    alrb_dspath=""
    alrb_result=`\grep -e "FWGETL:${alrb_idx}:${domain}" $ALRB_SMUDIR/config.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_dspath=`\echo $alrb_result | \cut -d ":" -f 4`
	if [ ! -d $alrb_dspath ]; then
	    \echo "   Note:"
	    \echo "    $alrb_dspath does not exist on this node for defined domain $domain."
	    \echo "    You will need to specify the path for this file."
	    alrb_dspath=""
	fi
    fi

done


if [ ! -z $ALRB_TutorialData ]; then
    \echo "
  You already have \$ALRB_TutorialData defined :
    ALRB_TutorialData=$ALRB_TutorialData
  and this will be used in setMeUp.
"
else
    alrb_result=`\grep -e "ALRBTD:${alrb_domain}" $ALRB_SMUDIR/config.txt 2>&1`
    if [ $? -eq 0 ]; then
	alrb_tmpVal=`\echo $alrb_result | \cut -d ":" -f 3`
	if [ -d $alrb_tmpVal ]; then
	    \echo "
  ALRB_TutorialData=$alrb_tmpVal 
    is present and will be used in setMeUp.
"
	    if [[ "$ALRB_SHELL" = "bash" ]] || [[ "$ALRB_SHELL" = "zsh" ]]; then
		alrb_myMessage="export ALRB_TutorialData=$alrb_tmpVal"
	    else
		alrb_myMessage="setenv ALRB_TutorialData $alrb_tmpVal"
	    fi
	    \echo -e '\033[1;34m'"
You must do this for the tutorial:
   $alrb_myMessage
Please set this in your login file so that it is avaiable.
"'\033[0m'
	else
	    \echo -e '\033[1;34m'"
Could not find or determine what the environment \$ALRB_TutorialData should be.
Please ask the person who ran setMeUpData for the site or first run setMeUpData.
"'\033[0m'
	fi
    fi
fi

