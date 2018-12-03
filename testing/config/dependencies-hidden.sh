#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! dependencies-hidden.sh
#!
#! A simple script to account for hidden dependencies
#!
#! Usage:
#!     dependencies-hidden.sh <dir>
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ $# -ne 1 ]; then
    \echo "Error: dependencies-hidden.sh requires dir argument"
    exit 64
fi

alrb_depDir=$1

\echo "emi" >> $1/panda


exit 0
