#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! installCheck.sh
#!
#! Checks that the platform has the required setups for ATLAS
#!
#! Usage: 
#!     installCheck.sh
#!
#! History:
#!   12Mar10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=installCheck.sh

#!----------------------------------------------------------------------------
# configurations
alrb_NameAr=( "sw" "groups" "SELinux" )
alrb_ErrorCodeAr=( "1" "2" "4" )
alrb_CheckAr=( "YES" "YES" "YES" )
alrb_ExitCodeAr=( "NO" "NO" "NO" )
#!----------------------------------------------------------------------------
let alrb_ExitCode=0
alrb_ValidNames=`\echo ${alrb_NameAr[@]} | \sed -e 's| |,|g'`


#!----------------------------------------------------------------------------
alrb_st_installCheckHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: checkOS [options]

    This application will check the platform for required system software

    Options (to override defaults) are:
     -h  --help               Print this help message
     -c --checkOnly=<string>  Comma delimited list to check; values are:
                               all,$alrb_ValidNames
                               default : all
     -e --exitCodeFor=<string> Comma delimited list for which checks will 
                               return an exit code for failures; values are:
                               all,none,$alrb_ValidNames 
                               default : none

Note that, by default, the exit code will be 0 unless requested by the 
 --exitCodeFor option.
exit codes:
0 : OK
other: check return code bits
 bit 1 : missing required software 
 bit 2 : missing yum groups (redhat only)
 bit 3 : SELinux not disabled 
 bit 7 : (exit code 64) other errors which will always be checked and flagged
   
EOF
}


alrb_shortopts="h,e:,c:" 
alrb_longopts="help,exitCodeFor:,checkOnly:"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"


alrb_checkOnly=",all,"
alrb_exitCodeFor=",none,"
while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_st_installCheckHelp
            exit 0
            ;;
        -c|--checkOnly)
            alrb_checkOnly=",$2,"    
	    shift 2
            ;;
        -e|--exitCodeFor)
	    alrb_exitCodeFor=",$2,"
	    shift 2
            ;;
	--)
            shift
            break
            ;;
        *)
            \echo "Internal Error: option processing error: $1" 1>&2
            exit 64
            ;;
    esac
done

# verify input option checkOnly
if [ "$alrb_checkOnly" != "" ]; then
    alrb_tmpVal=$alrb_checkOnly
    let alrb_idx=0
    for alrb_item in "${alrb_NameAr[@]}"; do
	if [ "$alrb_tmpVal" = ",all," ]; then
            alrb_CheckAr[$alrb_idx]="YES"
	else    
            alrb_CheckAr[$alrb_idx]="NO"
	    alrb_result=`\echo $alrb_checkOnly | \grep ",$alrb_item," >/dev/null 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_CheckAr[$alrb_idx]="YES"
		alrb_myCmd="\echo $alrb_tmpVal | \sed 's/$alrb_item//g'"
		alrb_tmpVal=`eval $alrb_myCmd`
	    fi
	fi
	let alrb_idx++
    done
    alrb_tmpVal=`\echo $alrb_tmpVal | \sed -e 's/all//g' -e 's/none//g' -e 's/[ ,]*//g'`
    if [ "$alrb_tmpVal" != "" ]; then
	\echo "Error: checkOnly unknown values $alrb_tmpVal"
	exit 64
    fi
fi

# verify input option exitCodeFor
if [ "$alrb_exitCodeFor" != "" ]; then
    alrb_tmpVal=$alrb_exitCodeFor
    let alrb_idx=0
    for alrb_item in "${alrb_NameAr[@]}"; do
	if [ "$alrb_tmpVal" = ",all," ]; then
            alrb_ExitCodeAr[$alrb_idx]="YES"
	elif [ "$alrb_tmpVal" = ",none," ]; then
            alrb_ExitCodeAr[$alrb_idx]="NO"
	else
            alrb_ExitCodeAr[$alrb_idx]="NO"
	    alrb_result=`\echo $alrb_exitCodeFor | \grep ",$alrb_item," >/dev/null 2>&1`
	    if [ $? -eq 0 ]; then
		alrb_ExitCodeAr[$alrb_idx]="YES"
		alrb_myCmd="\echo $alrb_tmpVal | \sed 's/$alrb_item//g'"
		alrb_tmpVal=`eval $alrb_myCmd`
	    fi
	fi
	let alrb_idx++
    done
    alrb_tmpVal=`\echo $alrb_tmpVal | \sed -e 's/all//g' -e 's/none//g' -e 's/[ ,]*//g'`
    if [ "$alrb_tmpVal" != "" ]; then
	\echo "Error: exitCodeFor unknown values $alrb_tmpVal"
	exit 64
    fi
fi


#!----------------------------------------------------------------------------
alrb_fn_checkRH6()
#!----------------------------------------------------------------------------
{
    
    \echo "Checking RedHat 6 derived OS ..."
    
    local let alrb_exitCode0=0

    cd $alrb_Workdir
    \rm -f index.html
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh http://linuxsoft.cern.ch/wlcg/sl6/x86_64/ >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	\echo "Error: unable to obtain index file for HEP_OSLib versions"
	exit 64
    fi

    local alrb_rpmFileList=( `\grep -e "HEP_OSlibs_SL6-.*.el6.x86_64.rpm" index.html | \sed -e 's/.*href="\(\HEP_OSlibs_SL6-.*\.el6\.x86_64\.rpm\)".*/\1/g' | env LC_ALL=C  \sort` )
    \rm -f $alrb_Workdir/listfile.txt
    touch $alrb_Workdir/listfile.txt
    local alrb_item
    for alrb_item in ${alrb_rpmFileList[@]}; do
	local alrb_tmpVal=`\echo $alrb_item | \sed -e 's/HEP_OSlibs_SL6-//g' -e 's/.el6.x86_64.rpm//g' -e 's/-/./g'`
	local alrb_tmpValM=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 4`
	\echo "$alrb_tmpValM|$alrb_item" >> $alrb_Workdir/listfile.txt
    done

    local alrb_rpmFile=`env LC_ALL=C \sort -n -k 1 $alrb_Workdir/listfile.txt | \tail -n 1 | \cut -f 2 -d "|"`
    if [ "$alrb_rpmFile" = "" ]; then
	\echo "Error: unsbale to obtain latest rpm version of HEP_OSLibs"
	exit 64
    fi

    local alrb_metarpm="http://linuxsoft.cern.ch/wlcg/sl6/x86_64/$alrb_rpmFile"
    local alrb_metarpmName=`\echo $alrb_metarpm | rev | \cut -f 1 -d "/" | rev`

    local alrb_tmpRpmFile="$alrb_Workdir/checkRH.txt"
    \rm -f $alrb_tmpRpmFile
    rpm -qa --qf "%{n}-%{arch}\n" > $alrb_tmpRpmFile

    
    local alrb_result
    
    local alrb_rpmAr=(
#	subversion
    )
    
    if [ ${alrb_CheckAr[0]} = "YES" ]; then	

	if [ ${#alrb_rpmAr[@]} -gt 0 ]; then
	    # do checks of missing installations (standalone rpms)
	    local alrb_rpmList=( `\echo ${alrb_rpmAr[@]} | tr ' ' '\n' | env LC_ALL=C  \sort -u` )
	    \echo ". Checking for missing rpms ..."
	    local alrb_missingRpmList=()
	    local alrb_rpmpkg
	    for alrb_rpmpkg in ${alrb_rpmList[@]}; do
		alrb_result=`\grep $alrb_rpmpkg $alrb_tmpRpmFile`
		if [ $? -ne 0 ]; then
		    alrb_missingRpmList=( ${alrb_missingRpmList[@]} $alrb_rpmpkg ) 
		fi	
	    done
	
	    if [ ${#alrb_missingRpmList[@]} -ne 0 ]; then
		if [ ${alrb_ExitCodeAr[0]} = "YES" ]; then
		    let alrb_rc=${alrb_ErrorCodeAr[0]}
		    alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
		fi
		\echo -e '\033[31m.. Missing rpms:\033[0m'
		for missingRpm in ${alrb_missingRpmList[@]}; do
		    \echo "    $missingRpm"
		done
		local alrb_tmpStr=`\echo ${alrb_missingRpmList[@]} | \sed -e 's/-i686/.i686/g' -e 's/-i386/.i386/g' -e 's/-x86_64/.x86_64/g'`
		\echo "... Fix: yum install $alrb_tmpStr"
	    fi
	fi

	\echo ". Checking for missing rpms ($alrb_metarpmName) ..."
	alrb_result=`rpm -qa | \grep HEP_OSlibs 2>&1`
	if [ $? -eq 0 ]; then
	    \echo ".. Site has $alrb_result"
	fi
	local alrb_metarpmFile="$alrb_Workdir/HEP_OSLibs_X.rpm"
	\rm -f $alrb_metarpmFile
	wget -q -O $alrb_metarpmFile $alrb_metarpm 
	if [ $? -ne 0 ]; then
	    \echo "Error: could not successfully download $alrb_metarpm"
	    exit 64
	else
	    local alrb_rpmList=( `rpm -q -R -p $alrb_metarpmFile  2>/dev/null | \egrep -v rpmlib | \cut -f 1 -d "("` ) 
	    alrb_missingRpmList=( )
	    for alrb_rpmpkg in ${alrb_rpmList[@]}; do
		alrb_result=`\grep $alrb_rpmpkg $alrb_tmpRpmFile`
		if [ $? -ne 0 ]; then
		    alrb_missingRpmList=( ${alrb_missingRpmList[@]} $alrb_rpmpkg ) 
		fi
	    done
	fi
	
	if [ ${#alrb_missingRpmList[@]} -ne 0 ]; then
	    if [ ${alrb_ExitCodeAr[0]} = "YES" ]; then
		let alrb_rc=${alrb_ErrorCodeAr[0]}
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	    \echo -e '\033[31m.. Missing rpms:\033[0m'
	    for missingRpm in ${alrb_missingRpmList[@]}; do
		\echo "    $missingRpm"
	    done
	    local alrb_tmpStr=`\echo ${alrb_missingRpmList[@]} | \sed -e 's/-i686/.i686/g' -e 's/-i386/.i386/g' -e 's/-x86_64/.x86_64/g'`
	    \echo "... Fix: yum install $alrb_tmpStr"
	    \echo "         or install / update the HEPOS_libs metarpm, see" 
	    \echo "         https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Install_Scientific_Linux6"
	fi

    fi
    
    if [ ${alrb_CheckAr[2]} = "YES" ]; then
	# check that SELinux is disabled
	\echo ". Checking that SELinuz is disabled ..."
	alrb_result=`\cat /etc/selinux/config | \grep -e "^SELINUX=disabled"`
	if [ $? -ne 0 ]; then
	    if [ ${alrb_ExitCodeAr[2]} = "YES" ]; then
		let alrb_rc=${alrb_ErrorCodeAr[2]}
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	    \echo -e '\033[31m.. SELinux is not disabled.\033[0m'
	    \echo "..  You can disable it /etc/selinux/config and reboot"
	fi
    fi
    	    
    return $alrb_exitCode0
}


#!----------------------------------------------------------------------------
alrb_fn_checkRH7()
#!----------------------------------------------------------------------------
{
    
    \echo "Checking RedHat 7 derived OS ..."
    
    local let alrb_exitCode0=0

    cd $alrb_Workdir
    \rm -f index.html
    $ATLAS_LOCAL_ROOT_BASE/utilities/wgetFile.sh http://linuxsoft.cern.ch/wlcg/centos7/x86_64/ >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	\echo "Error: unable to obtain index file for HEP_OSLib versions"
	exit 64
    fi

    local alrb_rpmFileList=( `\grep -e "HEP_OSlibs-.*.el7.cern.x86_64.rpm" index.html  | \sed -e 's/.*href="\(\HEP_OSlibs-.*.el7\.cern\.x86_64\.rpm\)".*/\1/g' | env LC_ALL=C  \sort` )
    \rm -f $alrb_Workdir/listfile.txt
    touch $alrb_Workdir/listfile.txt
    local alrb_item
    for alrb_item in ${alrb_rpmFileList[@]}; do
	local alrb_tmpVal=`\echo $alrb_item | \sed -e 's/HEP_OSlibs-//g' -e 's/.el7.cern.x86_64.rpm//g' -e 's/-/./g'`
	local alrb_tmpValM=`$ATLAS_LOCAL_ROOT_BASE/utilities/convertToDecimal.sh $alrb_tmpVal 4`
	\echo "$alrb_tmpValM|$alrb_item" >> $alrb_Workdir/listfile.txt
    done

    local alrb_rpmFile=`env LC_ALL=C \sort -n -k 1 $alrb_Workdir/listfile.txt | \tail -n 1 | \cut -f 2 -d "|"`
    if [ "$alrb_rpmFile" = "" ]; then
	\echo "Error: unsbale to obtain latest rpm version of HEP_OSLibs"
	exit 64
    fi

    local alrb_metarpm="http://linuxsoft.cern.ch/wlcg/centos7/x86_64/$alrb_rpmFile"
    local alrb_metarpmName=`\echo $alrb_metarpm | rev | \cut -f 1 -d "/" | rev`

    local alrb_tmpRpmFile="$alrb_Workdir/checkRH.txt"
    \rm -f $alrb_tmpRpmFile
    rpm -qa --qf "%{n}-%{arch}\n" > $alrb_tmpRpmFile

    
    local alrb_result
    
    local alrb_rpmAr=(
#	subversion
    )
 
    
    local alrb_rpmList=( `\echo ${alrb_rpmAr[@]} | tr ' ' '\n' | env LC_ALL=C  \sort -u` )
    if [ ${alrb_CheckAr[0]} = "YES" ]; then
	
	if [ ${#alrb_rpmAr[@]} -gt 0 ]; then   
	    # do checks of missing installations (standalone rpms)
	    \echo ". Checking for missing rpms ..."
	    local alrb_missingRpmList=()
	    local alrb_rpmpkg
	    for alrb_rpmpkg in ${alrb_rpmList[@]}; do
		alrb_result=`\grep $alrb_rpmpkg $alrb_tmpRpmFile`
		if [ $? -ne 0 ]; then
		    alrb_missingRpmList=( ${alrb_missingRpmList[@]} $alrb_rpmpkg ) 
		fi	
	    done
	    
	    if [ ${#alrb_missingRpmList[@]} -ne 0 ]; then
		if [ ${alrb_ExitCodeAr[0]} = "YES" ]; then
		    let alrb_rc=${alrb_ErrorCodeAr[0]}
		    alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
		fi
		\echo -e '\033[31m.. Missing rpms:\033[0m'
		for missingRpm in ${alrb_missingRpmList[@]}; do
		    \echo "    $missingRpm"
		done
		local alrb_tmpStr=`\echo ${alrb_missingRpmList[@]} | \sed -e 's/-i686/.i686/g' -e 's/-i386/.i386/g' -e 's/-x86_64/.x86_64/g'`
		\echo "... Fix: yum install $alrb_tmpStr"
	    fi
	fi


	\echo ". Checking for missing rpms ($alrb_metarpmName) ..."
	alrb_result=`rpm -qa | \grep HEP_OSlibs 2>&1`
	if [ $? -eq 0 ]; then
	    \echo ".. Site has $alrb_result"
	fi
	local alrb_metarpmFile="$alrb_Workdir/HEP_OSLibs_X.rpm"
	\rm -f $alrb_metarpmFile
	wget -q -O $alrb_metarpmFile $alrb_metarpm 
	if [ $? -ne 0 ]; then
	    \echo "Error: could not successfully download $alrb_metarpm"
	    exit 64
	else
	    local alrb_rpmList=( `rpm -q -R -p $alrb_metarpmFile  2>/dev/null | \egrep -v rpmlib | \cut -f 1 -d "("` ) 
	    alrb_missingRpmList=( )
	    for alrb_rpmpkg in ${alrb_rpmList[@]}; do
		alrb_result=`\grep $alrb_rpmpkg $alrb_tmpRpmFile`
		if [ $? -ne 0 ]; then
		    alrb_missingRpmList=( ${alrb_missingRpmList[@]} $alrb_rpmpkg ) 
		fi
	    done
	fi

	if [ ${#alrb_missingRpmList[@]} -ne 0 ]; then
	    if [ ${alrb_ExitCodeAr[0]} = "YES" ]; then
		let alrb_rc=${alrb_ErrorCodeAr[0]}
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	    \echo -e '\033[31m.. Missing rpms:\033[0m'
	    for missingRpm in ${alrb_missingRpmList[@]}; do
		\echo "    $missingRpm"
	    done
	    local alrb_tmpStr=`\echo ${alrb_missingRpmList[@]} | \sed -e 's/-i686/.i686/g' -e 's/-i386/.i386/g' -e 's/-x86_64/.x86_64/g'`
	    \echo "... Fix: yum install $alrb_tmpStr"
	    \echo "         or install / update the HEPOS_libs metarpm, see" 
	    \echo "         https://twiki.atlas-canada.ca/bin/view/AtlasCanada/Install_Scientific_Linux7"
	fi
	
    fi

    if [ ${alrb_CheckAr[2]} = "YES" ]; then
	# check that SELinux is disabled
	\echo ". Checking that SELinuz is disabled ..."
	alrb_result=`\cat /etc/selinux/config | \grep -e "^SELINUX=disabled"`
	if [ $? -ne 0 ]; then
	    if [ ${alrb_ExitCodeAr[2]} = "YES" ]; then
		let alrb_rc=${alrb_ErrorCodeAr[2]}
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	    \echo -e '\033[31m.. SELinux is not disabled.\033[0m'
	    \echo "..  You can disable it /etc/selinux/config and reboot"
	fi
    fi
    	    
    return $alrb_exitCode0
}


#!----------------------------------------------------------------------------
alrb_fn_checkMacOSX()
#!----------------------------------------------------------------------------
{

\echo "Checking MacOSX ..."
\echo " "
\echo " ** MacOSX is supported on a best effort basis. **"

let alrb_exitCode0=0

\echo " "
\echo "- XCode version : "
xcodebuild -version

local alrb_pkgsList=( "afs" "xquartz" )
if [ ${alrb_CheckAr[0]} = "YES" ]; then
    local pkg
    for alrb_pkg in ${alrb_pkgsList[@]}; do
	\echo " "
	\echo "- $alrb_pkg version : "
	alrb_tmpVal=`pkgutil --pkgs | \grep -i $alrb_pkg | \tail -n 1`
	if [ "$alrb_tmpVal" != "" ]; then
	    \echo -n "  "
	    pkgutil --pkg-info $alrb_tmpVal  | \grep version
	else
	    if [ ${alrb_ExitCodeAr[0]} = "YES" ]; then
		let alrb_rc=${alrb_ErrorCodeAr[0]}
		alrb_exitCode0=$((alrb_exitCode0 | alrb_rc ))
	    fi
	    \echo "  $alrb_pkg does not seem to be installed."
	fi
    done
fi

\echo " "
\echo "Completed check."

return $alrb_exitCode0
}


#initialize
alrb_OSFlavor=""
alrb_OSVersion=""
alrb_OSVersionMajor=""
alrb_OSVersionMinor=""

alrb_Proc=`uname -m`
if [[ "$alrb_Proc" != "i686" ]] && [[ "$alrb_Proc" != "x86_64" ]]; then
    \echo "unable to determine 32/64 bit architecture."
    exit 64
fi

if [ -z $ALRB_tmpScratch ]; then
    alrb_tmpVal=`$ATLAS_LOCAL_ROOT_BASE/utilities/getScratch.sh tmp`
    if [ $? -eq 0 ]; then
	export ALRB_tmpScratch=$alrb_tmpVal
    else
	\echo "Error: unable to define ALRB_tmpScratch"
	exit 64
    fi
fi

alrb_Workdir=`\mktemp -d $ALRB_tmpScratch/installCheckXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "Error: unable to create a dir in $ALRB_tmpScratch"
    return 64
fi    

# do CernVM first since it can be either redhat-based or rPath Linux
alrb_isCernVM="no"
if [ -e /etc/issue ]; then
    alrb_result=`\grep "CERN Virtual Machine" /etc/issue`
    if [ $? -eq 0 ]; then
	alrb_isCernVM="yes"
    fi
fi

# get platform type and run checks
if [[ -e /etc/distro-release ]] && [[ "$alrb_isCernVM" = "yes" ]]; then
    \echo "--------------------------------------------------------------------"
    \echo "CernVM OS:"
    \echo "checks unavailable for this OS / platform."
    \echo "--------------------------------------------------------------------"
elif [ -e /etc/redhat-release ]; then
    \echo "--------------------------------------------------------------------"
    \echo "RedHat derived OS:"
    \cat /etc/redhat-release
    if [[ ! -z "$ALRB_CONT_IMAGE" ]] && [[ "$ALRB_CONT_IMAGE" != "" ]]; then
	\echo "Container image : $ALRB_CONT_IMAGE"
    fi
    \echo "--------------------------------------------------------------------"
    alrb_OSFlavor="RedHat"
    alrb_OSVersion=`\cat /etc/redhat-release | \sed -e 's/[[:alpha:]*\(\)\ ]//g'`    
    alrb_OSVersionMajor=`\echo $alrb_OSVersion |  \cut -d "." -f 1`
    alrb_OSVersionMinor=`\echo $alrb_OSVersion |  \cut -d "." -f 2`
    if [ "$alrb_OSVersionMajor" == "6" ]; then
	alrb_fn_checkRH6
	let alrb_ExitCode=$?
    elif [ "$alrb_OSVersionMajor" == "7" ]; then
	alrb_fn_checkRH7
	let alrb_ExitCode=$?
    else
	\echo "The OS needs to be RHEL 6 compatible (production)."
	\echo " Or the OS needs to be RHEL 7 compatible (testing)."
	\echo " Please upgrade."
	return 64
    fi
elif [ -e /etc/lsb-release ]; then
    \echo "--------------------------------------------------------------------"
    \echo "Ubuntu OS:"
    \cat /etc/lsb-release    
    \echo "--------------------------------------------------------------------"
    \echo "checks unavailable for this OS / platform."
elif [ "$ALRB_OSTYPE" = "MacOSX" ]; then
    \echo "--------------------------------------------------------------------"
    \echo -n "Mac OSX "
    sw_vers -productVersion 
    \echo "--------------------------------------------------------------------"
    alrb_fn_checkMacOSX
    let alrb_ExitCode=$?
else
    \echo "--------------------------------------------------------------------"
    \echo -n "OS Type is: "
    $ATLAS_LOCAL_ROOT_BASE/utilities/getOSType.sh
    \echo "--------------------------------------------------------------------"
    \echo "Platform is unknown or unsuported.  Pleae contact user support."
    exit 64
fi


\echo "
*******************************************************************************
What to expect if there are no problems:
  No missing rpms. (You can ignore strace64 if it shows up.)
  SELinux disabling is only a recommendation if you have problems.
*******************************************************************************
"

\rm -rf $alrb_Workdir

exit $alrb_ExitCode


