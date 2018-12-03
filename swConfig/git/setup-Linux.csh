#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup git for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

setenv ATLAS_LOCAL_GIT_VERSION $1
setenv ATLAS_LOCAL_GIT_PATH ${ATLAS_LOCAL_ROOT}/git/${ATLAS_LOCAL_GIT_VERSION}

if ( -e $ATLAS_LOCAL_GIT_PATH/setup.csh ) then
    source $ATLAS_LOCAL_GIT_PATH/setup.csh
else

    insertPath PATH $ATLAS_LOCAL_GIT_PATH/bin
    if ( $?LD_LIBRARY_PATH ) then
	insertPath LD_LIBRARY_PATH $ATLAS_LOCAL_GIT_PATH/lib64
    else
	setenv LD_LIBRARY_PATH $ATLAS_LOCAL_GIT_PATH/lib64
    endif

    if ( $?MANPATH ) then
	insertPath MANPATH $ATLAS_LOCAL_GIT_PATH/share/man
    else
	setenv MANPATH $ATLAS_LOCAL_GIT_PATH/share/man
    endif

    setenv GIT_EXEC_PATH $ATLAS_LOCAL_GIT_PATH/libexec/git-core
endif