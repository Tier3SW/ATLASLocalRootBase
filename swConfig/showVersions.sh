#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! showVersions.sh
#!
#! show versions of various tools
#!
#! Usage:
#!     showVersions.sh --help
#!
#! History:
#!   09May16: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_progname=showVersions.sh

alrb_allPackages="$ALRB_availableTools"

alrb_result=`\echo $ALRB_availableTools | \grep asetup`
if [ $? -eq 0 ]; then
    alrb_secondaryPackages="dbrelease athena"
else
    alrb_secondaryPackages=""
fi

#!----------------------------------------------------------------------------
alrb_fn_showVersionsHelp()
#!----------------------------------------------------------------------------
{
    \cat <<EOF

Usage: showVersions.sh [options] [packages]

   where packages are one or more (comma delimited) values of:
    $alrb_allPackages $alrb_secondaryPackages

    This application will display details on what is installed in the
    ATLASLocalRootBase package.

    You need to set the environment variable ATLAS_LOCAL_ROOT_BASE first.

    Options (to override defaults) are:
     -h  --help               Print this help message
     --cmtConfig=STRING       List only for these cmtconfig value 
                               used only for sft at the moment
                               (=showAll will show cmtconfig values too)

EOF
}


#!----------------------------------------------------------------------------
alrb_fn_athenaShowVersions()
#!----------------------------------------------------------------------------
{
    
    \echo "
athena versions:"
    if [ -e $ALRB_cvmfs_repo/sw/tags ]; then
	\cat $ALRB_cvmfs_repo/sw/tags | \sed -e 's/VO-atlas-/  /' | \grep -e "[[:alnum:]]*-[0-9\.]*[[:alnum:]]*-" | env LC_ALL=C \sort -uf    
if [ -e $ALRB_cvmfs_nightly_repo/sw/nightlies_tags ]; then
    \echo " " 
    \sed -e 's/^/  /' $ALRB_cvmfs_nightly_repo/sw/nightlies_tags | env LC_ALL=C \sort 
fi
    fi

    return 0
}


#!----------------------------------------------------------------------------
alrb_fn_dbreleaseShowVersions()
#!----------------------------------------------------------------------------
{

    \echo "
dbrelease versions:"
    if [ -e $ALRB_cvmfs_repo/sw/tags ]; then
	\cat $ALRB_cvmfs_repo/sw/tags | \sed -e 's/VO-atlas-/  /' | \grep dbrelease | \sed -e 's/dbrelease-//' | env LC_ALL=C  \sort -uf
    fi

    return 0
}


#!----------------------------------------------------------------------------
# main
#!----------------------------------------------------------------------------
 
alrb_shortopts="h" 
alrb_longopts="help,show:,cmtConfig:"
alrb_opts=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_parseOptions.sh bash $alrb_shortopts $alrb_longopts $alrb_progname "$@"`
if [ $? -ne 0 ]; then
    \echo " If it is an option for a tool, you need to put it in double quotes." 1>&2
    exit 64
fi
eval set -- "$alrb_opts"

alrb_cmtConfig=""
alrb_ListPackages=""

while [ $# -gt 0 ]; do
    : debug: $1
    case $1 in
        -h|--help)
            alrb_fn_showVersionsHelp
            exit 0
            ;;
	--show)
	    alrb_ListPackages=`\echo $2 | \tr '[:upper:]' '[:lower:]'`
	    shift 2
	    ;;
	--cmtConfig)
	    alrb_cmtConfig=$2
	    shift 2
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

if [ "$*" != "" ]; then
    alrb_ListPackages=`\echo $* | tr '[:upper:]' '[:lower:]'`
fi

if [ "$alrb_ListPackages" = "" ]; then
    alrb_listPackagesAr=( `\echo $ALRB_availableTools` $alrb_secondaryPackages )
else
    alrb_listPackagesAr=( `\echo $alrb_ListPackages` )
fi

source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/functions.sh

for alrb_requestedTool in ${alrb_listPackagesAr[@]}; do
    alrb_tool=`alrb_fn_getSynonymInfo $alrb_requestedTool tool 2>&1`
    if [ $? -ne 0 ]; then
	if [ "$alrb_secondaryPackages" != "" ]; then
	    alrb_result=`\echo $alrb_secondaryPackages | \grep $alrb_requestedTool`
	    if [ $? -eq 0 ]; then
		alrb_result=`type -t alrb_fn_${alrb_requestedTool}ShowVersions`
		if [ $? -eq 0 ]; then
		    alrb_fn_${alrb_requestedTool}ShowVersions
		fi
		continue
	    fi
	fi
	\echo "Error: unknown tool $alrb_requestedTool"
	continue
    fi
    alrb_fn_sourceFunctions $alrb_tool
    alrb_result=`type -t alrb_fn_${alrb_tool}ShowVersions`
    if [ $? -eq 0 ]; then
	alrb_fn_${alrb_tool}ShowVersions
	continue
    fi
    alrb_toolDir=`alrb_fn_getInstallDir $alrb_tool`
    if [ -e $alrb_toolDir/.alrb/mapfile.txt ]; then
	\echo "
$alrb_tool versions;"
	\cat $alrb_toolDir/.alrb/mapfile.txt | \cut -f 4-  -d "|" | \column -t -s "|" | \sed -e 's/^/ --> /g' -e 's/\([[:space:]]\)current/\1default/g' | env LC_ALL=C \sort
	\echo "Type lsetup \"$alrb_tool <value>\" to use $alrb_tool"
    fi
done
