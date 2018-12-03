#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! createUserASetup.sh
#!
#! Checks for existence $HOME/.asetup and creates if it is missing.
#!
#! Usage: 
#!     createUserASetup.sh
#!
#! History:
#!   23Aug10: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [ -z $HOME ]; then
    exit 0
fi

alrb_localAsetup="$HOME/.asetup"

if [ ! -e $alrb_localAsetup ]; then
#    \echo -e "\033[1;34mCreated $alrb_localAsetup.  Please look and (optional) edit it.\033[0m"
    \echo "
# See https://twiki.cern.ch/twiki/bin/view/Atlas/AtlasSetup for details
# To recreate this file, simply delete it and do setupATLAS

# This is an example to automatically create a \$TestArea for each release 
#  with the release and project name
#  eg. asetup 16.6.7 would result in 
#        \$TestArea = \$HOME/athena/AtlasOffline-16.6.7 

[defaults]

# your test area directory
#testarea = $HOME/athena

# each release has its own directory
#multi = True

# the release dir name has the project prepended
#projtest = True

" > $alrb_localAsetup
fi

