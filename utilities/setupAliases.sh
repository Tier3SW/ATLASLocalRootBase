#!----------------------------------------------------------------------------
#!
#! setupAliases.sh
#!
#! A simple script to setup aliases
#!
#! Usage:
#!     source setupAliases.sh
#!
#! History:
#!   29Nov07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


# Utilities

  # add to end of path
  # copied from BaBar
appendPath()
{
    if eval test -z \${$1}; then
	eval "$1=$2"
	export $1
    elif ! eval test -z \"\${$1##$2}\" -o -z \"\${$1##\*:$2:\*}\" -o -z \"\${$1%%\*:$2}\" -o -z \"\${$1##$2:\*}\" ; then
	local alrb_thePath=$1
	local alrb_cmd="\echo \$$alrb_thePath"    
	local alrb_thePathVal=`eval $alrb_cmd`
	eval "$alrb_thePath=$alrb_thePathVal:$2"
	export $alrb_thePath
    fi
}

  # add to front of path
  # copied from BaBar
insertPath()
{
    if eval test -z \${$1}; then
	eval "$1=$2"
	export $1
    elif ! eval test -z \"\${$1##$2}\" -o -z \"\${$1##\*:$2:\*}\" -o -z \"\${$1%%\*:$2}\" -o -z \"\${$1##$2:\*}\" ; then
	local alrb_thePath=$1
	local alrb_cmd="\echo \$$alrb_thePath"    
	local alrb_thePathVal=`eval $alrb_cmd`
	eval "$alrb_thePath=$2:$alrb_thePathVal"
	export $alrb_thePath
    fi
}

  # delete from path
  # copied from BaBar
deletePath()
{
    eval "$1=\$(\echo \$$1 | \sed -e s%\^$2\$%% -e s%\^$2\:%% -e s%:$2\:%:%g -e s%:$2\\\$%%)"
    export $1
}

