#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! printMenu.sh
#!
#! prints out the menu
#!
#! Usage:
#!     source printMenu.sh <tool> <level>
#!  where level =0 means print all or <int> means only print a certail level.
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fn_menuLine()
{
    \printf "${alrb_menuFmtCmd}${alrb_menuFmtField1}${alrb_menuFmtDefault} ${alrb_menuFmtField2}\n" "$1" "$2"
    return 0
}

alrb_fn_toolMenu()
{
    alrb_tool=$1
    let alrb_level=$2
    if [ $# -ge 3 ]; then
	alrb_menuType=$3
    else
	alrb_menuType="."
    fi

    if [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_tool}/printMenu-${ALRB_OSTYPE}.sh" ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_tool}/printMenu-${ALRB_OSTYPE}.sh
    elif [ -e "${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_tool}/printMenu.sh" ]; then
	source ${ATLAS_LOCAL_ROOT_BASE}/swConfig/${alrb_menuType}/${alrb_tool}/printMenu.sh 
    else
	return 0
    fi
    
    alrb_fn_${alrb_tool}PrintMenu "$alrb_level"
    
    return 0
}


if [[ -z $ALRB_menuFmtSkip ]] && [[ -z $ALRB_userMenuFmtSkip ]]; then 
    alrb_menuFmtCmd='\e[7m'
    alrb_menuFmtDefault='\e[0m'
    alrb_menuFmtField1='%-20s'
    alrb_menuFmtField2='%s'
else
    alrb_menuFmtCmd=""
    alrb_menuFmtDefault=""
    alrb_menuFmtField1="%-20s"
    alrb_menuFmtField2="%s"
fi

if [ "$1" = "all" ]; then
    alrb_menuTypeAr=( "Pre" "." "Post" )
    for alrb_menuType in ${alrb_menuTypeAr[@]}; do
	if [ "$alrb_menuType" = "." ]; then
	    alrb_tmpVal=""
	else
	    alrb_tmpVal=$alrb_menuType
	fi
	alrb_result=$(\echo ALRB_availableTools${alrb_tmpVal})
	alrb_tmpAr=( `\echo ${!alrb_result}` )
	for alrb_item in "${alrb_tmpAr[@]}"; do
	    alrb_fn_toolMenu $alrb_item 0 "$alrb_menuType"
	done
    done
else
    alrb_fn_toolMenu $@
fi

exit 0



