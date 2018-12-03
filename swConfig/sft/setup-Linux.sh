#!----------------------------------------------------------------------------
#!
#! setup,sh
#!
#! A simple script to setup sft for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_listPackages=()
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	cmt)
	    alrb_sftCmtConfig=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
	pkg)
	    alrb_tmpVal=`\echo $alrb_item | \cut -f 2 -d "="`
	    alrb_listPackages=( ${alrb_listPackages[@]} $alrb_tmpVal )
	    ;;
    esac
done

alrb_result=`python -V 2>&1`
alrb_thisPython=`\echo $alrb_result | \cut -f 2 -d " " | \cut -f 1-2 -d "."`

alrb_abort="NO"
alrb_listPackagesSetup=()
for alrb_item in ${alrb_listPackages[@]}; do
    alrb_result=`$ATLAS_LOCAL_ROOT_BASE/swConfig/sft//navigateSFT.sh $alrb_item $alrb_sftCmtConfig $alrb_thisPython`
    if [ $? -ne 0 ]; then
	\echo "  Error: $alrb_result" 1>&2
	alrb_abort="YES"
    else
	alrb_result="P%$alrb_item|$alrb_result"
	alrb_listPackagesSetup=( ${alrb_listPackagesSetup[@]} "$alrb_result" )
    fi
done
if [ "$alrb_abort" = "YES" ]; then
    return 64
fi

alrb_sftPostPrintAr=() 
for alrb_item in "${alrb_listPackagesSetup[@]}"; do
    alrb_fullPath="error !"
    let alrb_idx=1
    alrb_mySetup=`\echo $alrb_item | \cut -d "|" -f $alrb_idx`
    while [ "$alrb_mySetup" != "" ]; do 
	alrb_action=`\echo $alrb_mySetup | \cut -f 1 -d "%"`
	if [ "$alrb_action" = "P" ]; then
	    alrb_tmpVal=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    alrb_fullPath="$ALRB_SFT_LCG/$alrb_tmpVal/$alrb_sftCmtConfig" 
	elif [ "$alrb_action" = "H" ]; then
	    alrb_name=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    alrb_name2=`\echo $alrb_name | \sed -e 's|\+|P|g'`
	    alrb_version=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    export "SFT_HOME_$alrb_name2"="$alrb_fullPath"
	    if [ "$alrb_Quiet" = "NO" ]; then
		\echo "  Setting up $alrb_name $alrb_version ..."
		alrb_tmpVal="${alrb_name}%The env \$SFT_HOME_$alrb_name2 is the home dir"
		alrb_sftPostPrintAr=( "${alrb_sftPostPrintAr[@]}" "$alrb_tmpVal" ) 
	    fi
	elif [ "$alrb_action" = "IP" ]; then
	    alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    if eval test -z \${$alrb_key}; then
		insertPath $alrb_key "$alrb_fullPath/$alrb_value"    
	    else
		insertPath $alrb_key "$alrb_fullPath/$alrb_value"
	    fi    
	elif [ "$alrb_action" = "EP" ]; then
	    alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    export $alrb_key="$alrb_fullPath/$alrb_value"
	elif [ "$alrb_action" = "EC" ]; then
	    if [ "$alrb_Quiet" = "NO" ]; then
		alrb_value=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
		alrb_tmpVal="${alrb_name}%${alrb_value}"
		alrb_sftPostPrintAr=( "${alrb_sftPostPrintAr[@]}" "$alrb_tmpVal" )
	    fi
	elif [ "$alrb_action" = "S" ]; then    
	    alrb_key=`\echo $alrb_mySetup | \cut -f 2 -d "%"`
	    alrb_value=`\echo $alrb_mySetup | \cut -f 3 -d "%"`
	    if [ "$alrb_key" = "$ALRB_SHELL" ]; then
		source ${alrb_fullPath}/${alrb_value}
	    fi
	else 
	    \echo "  Error: unknown action $alrb_mySetup" 1>&2
	    \echo "   Please report this.  Continuing ..." 1>&2
	fi
	let alrb_idx++
	alrb_mySetup=`\echo $alrb_item | \cut -d "|" -f $alrb_idx`
    done
done


unset alrb_tmpAr alrb_item alrb_sftCmtConfig alrb_thisPython alrb_result alrb_abort alrb_listPackagesSetup alrb_tmpVal alrb_fullPath alrb_idx alrb_mySetup alrb_action alrb_name alrb_name2 alrb_key alrb_value


