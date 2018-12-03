#!----------------------------------------------------------------------------
#!
#!  postSetup.csh
#!
#!    post setup script
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if ( "$alrb_Quiet" == "NO" ) then    
    if (( -e $ATLAS_LOCAL_GIT_PATH/setup.sh ) && ( ! -e $ATLAS_LOCAL_GIT_PATH/setup.csh )) then
	\echo " git:"
	\echo "   This is a guess of the best setup for tcsh."
	\echo "    you are advised to move to bash / zsh"
    endif
endif
	

