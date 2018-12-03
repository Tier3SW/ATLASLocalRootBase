#!----------------------------------------------------------------------------
#!
#! container.sh
#!
#! container without cvmfs has relocated alrb
#!
#! These need to be defined:
#!
#! Usage: 
#!     source container.sh
#!
#! History:
#!   17Jul18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if [[ -z $ALRB_CONT_HOSTALRBDIR ]] || [[ "$ALRB_CONT_HOSTALRBDIR" = "$ATLAS_LOCAL_ROOT_BASE" ]]; then
    return 0
fi

export ALRB_RELOCATECVMFS="YES"

export VO_ATLAS_SW_DIR="/none"
export ALRB_cvmfs_repo="/none"
export ALRB_cvmfs_condb_repo="/none"
export ALRB_cvmfs_nightly_repo="/none"
export ALRB_cvmfs_sft_repo="/none"


