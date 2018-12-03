#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup art for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_ART_VERSION=$1

alrb_tmpVal=`\find $ATLAS_LOCAL_ROOT/art/$ATLAS_LOCAL_ART_VERSION -type d -name share`

if [ "$ALRB_SHELL" = "zsh" ]; then
    source $alrb_tmpVal/localSetupART.zsh
else
    source $alrb_tmpVal/localSetupART.sh
fi
return $?

