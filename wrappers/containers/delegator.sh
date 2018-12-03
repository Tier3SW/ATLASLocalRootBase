#!/bin/bash
#!----------------------------------------------------------------------------
#!
#! delegator.sh
#!
#! A generic script to send commands to run on the host machne
#!  eg from inside the container to submit batch jobs on the host
#!
#! Usage: (runs in a container)
#!     This is to be sym linked to applications to run on host
#!     It needs to work with the executor.sh script run as background on host
#!
#!
#! History:
#!   01Oct18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_appName=`basename $0`

alrb_sendPipe=$ALRB_CONT_PIPEDIR/hostExecutor
alrb_uuidgen=`uuidgen`
alrb_readPipe=$ALRB_CONT_PIPEDIR/$alrb_uuidgen
alrb_readPipeHost=$ALRB_CONT_PIPEDIRHOST/$alrb_uuidgen

trap "\rm -f $alrb_readPipe" EXIT

if [ ! -p $alrb_sendPipe ]; then
    \echo "Error: sending pipe does not exist"
    exit 64
fi
if [ ! -p $alrb_readPipe ]; then
    mkfifo $alrb_readPipe
    if [ $? -ne 0 ]; then
	\echo "Error: unable to open fifo pipe for reading"
	exit 64
    fi
fi

alrb_myDir=`pwd`
alrb_cmdArg=( "$@" )
if [ "$ALRB_CONT_SED2HOST" != "" ]; then
    alrb_myCmd="\echo $alrb_myDir | \sed $ALRB_CONT_SED2HOST"
    alrb_myDir=`eval $alrb_myCmd`
    for alrb_idx in "${!alrb_cmdArg[@]}"; do 
	alrb_myCmd="\echo ${alrb_cmdArg[$alrb_idx]} | \sed $ALRB_CONT_SED2HOST"
	alrb_cmdArg[$alrb_idx]=`eval $alrb_myCmd`
    done
fi

alrb_cmdArg=( `if [ ${#alrb_cmdArg[@]} -gt 0 ]; then printf "\"%s\"\n" "${alrb_cmdArg[@]}"; fi` )
\echo "$alrb_readPipeHost%cd $alrb_myDir && $alrb_appName ${alrb_cmdArg[@]}" > $alrb_sendPipe

alrb_result=`\cat "$alrb_readPipe"`
\echo "$alrb_result" | \sed -e 's|+=+=+=rc=.*||g'
alrb_rc=`\echo $alrb_result | \sed -e 's|.*+=+=+=rc=||g'`
exit $alrb_rc
