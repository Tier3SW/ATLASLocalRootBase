#!----------------------------------------------------------------------------
#!
#! evaluator.sh
#!
#! runs a command, saves output and stdout/err as needed
#!
#! Usage:
#!     evaluator.sh <command> <output file> <verbose=YES/NO>
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

if [ "$3" = "YES" ]; then
    \echo " "     
    printf "cmd: %s\n" "$1"
fi

eval $1 > $2 2>&1
if [ $? -ne 0 ]; then
    if [ "$3" != "YES" ]; then
	\echo " "     
	printf "cmd: %s\n" "$1"
    fi
    \cat $2
    return 64
elif [ "$3" = "YES" ]; then
    \cat $2
    return 0
else
    return 0
fi
