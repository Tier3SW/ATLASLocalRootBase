#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! fixKnownHosts.sh
#!
#! adds the correct hosts into known_host file
#!
#! Usage:
#!     fixKnownHosts.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

\rm -f $ALRB_SMUDIR/known_hosts

if [ ! -d $HOME/.ssh ]; then
    \mkdir $HOME/.ssh
fi

ssh-keyscan -t rsa,dsa svn.cern.ch > $ALRB_SMUDIR/known_hosts 2>&1
if [ $? -ne 0 ]; then
    \cat $ALRB_SMUDIR/svnHosts.txt
    \echo "ssh-keyscan failed ..."
    exit 64
else
    if [ -e $HOME/.ssh/known_hosts ]; then
	\mv $HOME/.ssh/known_hosts $HOME/.ssh/known_hosts.original
	\cp $ALRB_SMUDIR/known_hosts $HOME/.ssh/known_hosts    
	\cat $HOME/.ssh/known_hosts.original | \sed -e 's/.*svn\.cern\.ch.*//g' >> $HOME/.ssh/known_hosts
    else
	\cp $ALRB_SMUDIR/known_hosts $HOME/.ssh/known_hosts    
    fi

fi

\sed -e 's/.*svn\.cern\.ch.*//g' $HOME/.ssh/known_hosts  >> $ALRB_SMUDIR/known_hosts

exit 0


