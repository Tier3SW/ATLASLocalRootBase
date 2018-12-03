#!----------------------------------------------------------------------------
#!
#! container.csh
#!
#! container without cvmfs has relocated alrb
#!
#! These need to be defined:
#!
#! Usage: 
#!     source container.csh
#!
#! History:
#!   17Jul18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

if ( $?ALRB_CONT_HOSTALRBDIR ) then
    if ( "$ALRB_CONT_HOSTALRBDIR" == "$ATLAS_LOCAL_ROOT_BASE" ) then
	exit 0
    endif
    
    setenv VO_ATLAS_SW_DIR "/none"
    setenv ALRB_cvmfs_repo "/none"
    setenv ALRB_cvmfs_condb_repo "/none"
    setenv ALRB_cvmfs_nightly_repo "/none"
    setenv ALRB_cvmfs_sft_repo "/none"
    
endif

