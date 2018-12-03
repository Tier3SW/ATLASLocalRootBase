#! /bin/bash 
#!----------------------------------------------------------------------------
#!
#! getScratch.sh
#!
#! get the dirs to set for scratch and tmp
#!
#! Usage:
#!     getScratch.sh [tmp|scratch]
#!       where tmp is a more volatile dir (like /tmp) ALRB_tmpScratch
#!             scratch is a more stable dir (like $HOME) ALRB_SCRATCH
#!
#! History:
#!    13Sep15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

#!----------------------------------------------------------------------------
alrb_fn_checkTmpDir()
#!----------------------------------------------------------------------------
{    

    \mkdir -p $1 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
	return 64
    fi

    local alrb_result
    alrb_result=`\mktemp $1/testXXXXXX 2>&1`
    if [ $? -ne 0 ]; then
	return 64
    fi
    \rm -f $alrb_result

    return 0
}


alrb_dirType="$1"
alrb_tmpAr=()
alrb_whoami=`whoami`
alrb_currentDir=`pwd`


if [ "$alrb_dirType" = "tmp" ]; then
    alrb_tmpAr=( "$ALRB_tmpScratch" )
    if [ ! -z $TMPDIR ]; then
	alrb_tmpAr=( ${alrb_tmpAr[@]} "$TMPDIR/$alrb_whoami/.alrb" )
    fi
    alrb_tmpAr=( ${alrb_tmpAr[@]} "/tmp/$alrb_whoami/.alrb" )    
    if [ ! -z $ALRB_SCRATCH ]; then
	alrb_tmpAr=( ${alrb_tmpAr[@]} "$ALRB_SCRATCH" )
    fi
    if [ ! -z $HOME ]; then
	alrb_tmpAr=( ${alrb_tmpAr[@]} "$HOME/.alrb" )
    fi
    alrb_tmpAr=( ${alrb_tmpAr[@]} "$alrb_currentDir/.alrb" )

elif [ "$alrb_dirType" = "scratch" ];then
    alrb_tmpAr=( "$ALRB_SCRATCH" )
    if [ ! -z $HOME ]; then
	alrb_tmpAr=( ${alrb_tmpAr[@]} "$HOME/.alrb" )
    fi
    if [ ! -z $TMPDIR ]; then
	alrb_tmpAr=( ${alrb_tmpAr[@]} "$TMPDIR/$alrb_whoami/.alrb" )
    fi
    alrb_tmpAr=( ${alrb_tmpAr[@]} "/tmp/$alrb_whoami/.alrb" "$alrb_currentDir/.alrb" )    


else
    \echo "Error: unknown type specified for getScratch $alrb_dirType"
    exit 64
fi

for alrb_item in ${alrb_tmpAr[@]}; do
    if [ "$alrb_item" = "" ]; then
	continue
    fi
    alrb_fn_checkTmpDir "$alrb_item"
    if [ $? -eq 0 ]; then
	\echo "$alrb_item"
	exit 0
    fi    
done

exit 64

