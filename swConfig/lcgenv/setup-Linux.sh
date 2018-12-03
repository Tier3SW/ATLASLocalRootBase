#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script lcgenv for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   09Oct15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ALRB_lcgenvVersion=$1

if [[ "$#" -ge 2 ]] && [[ "$2" != "" ]]; then
    shift
    source $1
    return $?    
fi

return 0


