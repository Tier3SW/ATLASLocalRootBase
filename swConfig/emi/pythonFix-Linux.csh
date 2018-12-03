#!----------------------------------------------------------------------------
#!
#! pythonFix-Linux.csh
#!
#! Fixes issues for python setups
#!
#! Usage:
#!     source pythonFix-Linux.csh
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_version=`(python -V > /dev/tty) |& \awk '{print $2}'`
set alrb_versionN=`$ATLAS_LOCAL_ROOT_BASE/swConfig/versionConvert.sh python $alrb_version`

# fix : python 2.7.5 and newer needs SSL_CERT_DIR defined if not already
if ( ( "$alrb_versionN" >= "20705" ) && ( ! $?SSL_CERT_DIR )) then
    setenv SSL_CERT_DIR $ATLAS_LOCAL_ROOT_BASE/etc/grid-security-emi/certificates
endif

unset alrb_version alrb_versionN

exit 0
