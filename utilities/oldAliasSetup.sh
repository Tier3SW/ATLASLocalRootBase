#!----------------------------------------------------------------------------
#!
#!  oldAliasSetup.sh
#!
#! A bridge between alrbV1 and alrbV2
#!
#! History:
#!   31Aug15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_tmpVal=""

while [ $# -gt 0 ]; do
    case $1 in
        --)
            shift
            ;;
	*)
	    alrb_tmpVal="$alrb_tmpVal $1" 
	    shift
	    ;;
    esac
done

eval source $ATLAS_LOCAL_ROOT_BASE/packageSetups/localSetup.sh \"$alrb_tmpVal\"
return $?
