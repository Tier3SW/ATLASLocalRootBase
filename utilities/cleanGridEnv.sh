#! /bin/bash
#!----------------------------------------------------------------------------
#! 
#! cleanGridEnv.sh
#!
#! Undo whatever grid setup has done
#!   We need this because the gLite/EMi generated script has many issues
#!     - deletes /bin from PATH, does not work for zsh and tcsh
#!
#! Usage (mandatory): 
#!     cleanGridEnv.sh <GRIDTYPE> <SHELL> <GRID_ENV_LOCATION>
#!
#! History:
#!   09Oct12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ $# -ne 3 ]; then
    \echo "Error: incorrect arguments ..."
    \echo "Usage: `basename $0` <GRIDTYPE> <SHELL> <GRID_ENV_LOCATION>"
    exit 64
fi

alrb_gridType=$1
# future check whether gLite or emi - they are the same for now ...

GRID_ENV_LOCATION=$3
if [ ! -e $GRID_ENV_LOCATION/grid-clean-env.sh ]; then
    \echo "Error: missing $GRID_ENV_LOCATION/grid-clean-env.sh"
    exit 64
fi

alrb_myShell=$2
alrb_unsetenvCmd=""
if [[ "$alrb_myShell" =~ "bash" ]]; then
  alrb_unsetenvCmd="unset"  
  alrb_setCmd=""
elif [[ "$alrb_myShell" =~ "zsh" ]]; then
  alrb_unsetenvCmd="unset"  
  alrb_setCmd=""
elif  [[ "$alrb_myShell" =~ "tcsh" ]]; then
  alrb_unsetenvCmd="unsetenv" 
  alrb_setCmd="set"
else
    \echo "Error: unsupported shell $alrb_myShell"
    exit 64
fi

source $GRID_ENV_LOCATION/grid-env.sh --
    
if [ ! -z $arch_dir ]; then
    \echo "$alrb_setCmd  arch_dir=$arch_dir" 
fi
if [ ! -z $python ]; then    
    \echo "$alrb_setCmd  python=$python"
fi
if [ ! -z $python2_4 ]; then    
    \echo "$alrb_setCmd  python2_4=$python2_4"
fi
if [ ! -z $python2_5 ]; then    
    \echo "$alrb_setCmd  python2_5=$python2_5"
fi
if [ ! -z $python2_6 ]; then    
    \echo "$alrb_setCmd  python2_6=$python2_6"
fi

alrb_myCmd="\grep -e gridpath -e gridenv \$GRID_ENV_LOCATION/grid-env.sh | \sed -e 's/gridpath_.*pend/deletePath/g' -e 's/gridenv.* \"\(.*\)\" .*/$alrb_unsetenvCmd \1/g' -e 's/.*\"\/bin\"//g' | \sed -e 's/\"//g'" 

eval $alrb_myCmd 
alrb_rc=$?

exit $alrb_rc


