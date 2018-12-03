#!----------------------------------------------------------------------------
#!
#! evaluator.csh
#!
#! runs a command, saves output and stdout/err as needed
#!
#! Usage:
#!     evaluator.csh <command> <output file> <verbose=YES/NO>
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------
#
#  1: command to run
#  2: output file
#  3: verbose ?
#  

if ( "$3" == "YES" ) then
    \echo " "    
    printf "cmd: %s\n" "$1"
endif

eval $1 >& $2
if ( $? != 0 ) then
    if ( "$3" != "YES" ) then
	\echo " "    
	printf "cmd: %s\n" "$1"
    endif
    \cat $2
    exit 64
else if ( "$3" == "YES" ) then
    \cat $2
    exit 0
else
    exit 0
endif
