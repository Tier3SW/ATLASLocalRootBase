#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script lcgenv for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   09Oct15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ALRB_lcgenvVersion $1

if (( $#argv >= 2 ) && ( "$2" != "" )) then
    shift
    source $1
    exit $?    
endif

exit 0


