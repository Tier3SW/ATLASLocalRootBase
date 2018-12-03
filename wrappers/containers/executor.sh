#!/bin/bash

alrb_readPipe=$ALRB_CONT_PIPEDIRHOST/hostExecutor

trap "\rm -f $alrb_readPipe" EXIT

if [ ! -p $alrb_readPipe ]; then
    mkfifo $alrb_readPipe
    if [ $? -ne 0 ]; then
	\echo "Error: unable to open fifo pipe for hostExecutor"
	exit 64
    fi
fi

while true; do
    if read alrb_line < $alrb_readPipe; then
	alrb_sendPipe=`\echo $alrb_line | \cut -f 1 -d "%"`
	alrb_cmd="`\echo $alrb_line | \cut -f 2- -d "%"`; \echo \"+=+=+=rc=\$?\""

	if [ ! -p $alrb_sendPipe ]; then
	    \echo "Error: sendPipe $alrb_sendPipe not running"
	    \echo "       $alrb_line not processed"
	    continue
	fi

	eval "$alrb_cmd" > $alrb_sendPipe 2>&1
    fi
done

exit 0

