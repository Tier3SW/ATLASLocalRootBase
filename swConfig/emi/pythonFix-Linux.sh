#!----------------------------------------------------------------------------
#!
#! pythonFix-Linux.sh
#!
#! Fixes issues for python setups
#!
#! Usage:
#!     source pythonFix-Linux.sh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_version=`python -V 2>&1 | \awk '{print $2}'`
let alrb_versionN=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $alrb_version`

# fix : python 2.7.5 and newer needs SSL_CERT_DIR defined if not already
if [[ "$alrb_versionN" -ge "20705" ]] && [[ -z $SSL_CERT_DIR ]]; then
    export SSL_CERT_DIR=$ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
fi

unset alrb_version alrb_versionN

return 0
