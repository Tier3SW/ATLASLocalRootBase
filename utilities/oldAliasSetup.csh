#!----------------------------------------------------------------------------
#!
#!  oldAliasSetup.csh
#!
#! A bridge between alrbV1 and alrbV2
#!
#! History:
#!   31Aug15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_tmpVal=""

while ( $# > 0 )
    switch ($1)
    case --:
        shift
        breaksw
    default:
	set alrb_tmpVal="$alrb_tmpVal $1"
        shift
        breaksw
    endsw
end

eval source $ATLAS_LOCAL_ROOT_BASE/packageSetups/localSetup.csh \"$alrb_tmpVal\"
exit $?

