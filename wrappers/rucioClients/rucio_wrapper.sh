#!/usr/bin/env bash
#!----------------------------------------------------------------------------
#!
#! rucio_wrapper.sh
#!
#! A generic wrapper script for rucio-clients setups
#!
#! Usage:
#!     This is to be sym linked 
#!
#! History:
#!   16Feb16: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_wrapWorkdir=`\mktemp -d ${ALRB_tmpScratch}/wrapperXXXXXX 2>&1`
if [ $? -ne 0 ]; then
    \echo "Error: unable to create wrapper work dir"
    exit 64
fi

alrb_appName=`basename $0`

env | \grep -e "^ALRB" -e "^ATLAS_LOCAL_" -e "^X509_USER_PROXY" -e "^RUCIO_ACCOUNT" |  env LC_ALL=C \sort | \awk '{print "export "$1""}' | \sed -e 's|=|="|g' -e 's|$|"|g' > $alrb_wrapWorkdir/wrapScript.sh 

\cat <<EOF >> $alrb_wrapWorkdir/wrapScript.sh

eval source \$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet 

eval source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/localSetup.sh rucio --quiet

alrb_cmd="$alrb_appName $@"
eval \$alrb_cmd

EOF

env -i bash -l -c "source $alrb_wrapWorkdir/wrapScript.sh"
alrb_rc=$?

\rm -rf $alrb_wrapWorkdir

exit $alrb_rc

