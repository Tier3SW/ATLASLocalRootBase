#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! createGccSlc5Wrapper.sh
#!
#!    creates a wrapper for slc5 releases
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

source $ATLAS_LOCAL_ROOT_BASE/utilities/checkAtlasLocalRoot.sh
source $ATLAS_LOCAL_ROOT_BASE/swConfig/functions.sh
alrb_ToolDir=`alrb_fn_getInstallDir gcc 2>&1`
if [ $? -ne 0 ]; then
    exit 0
fi

# need this wrapper for slc5 releaes
alrb_scriptVersionGPP=2
\mkdir -p $alrb_ToolDir/.bin
alrb_wrapFile="$alrb_ToolDir/.bin/g++"
\rm -f $alrb_wrapFile.new
\cat <<EOF > $alrb_wrapFile.new
#!/bin/bash
#!
#! ScriptVersion=$alrb_scriptVersionGPP

if [ -e \$ALRB_GPPBINPATH/g++ ]; then
  \$ALRB_GPPBINPATH/g++ -D__USE_XOPEN2K8 \$*
  alrb_rc=\$?
else
  \echo "Error: g++ not found in \$ALRB_GPPBINPATH"  
  alrb_rc=64
fi 

exit \$alrb_rc

EOF

if [ -e $alrb_wrapFile ]; then
    alrb_result=`diff $alrb_wrapFile $alrb_wrapFile.new`
    if [ $? -ne 0 ]; then
	mv $alrb_wrapFile.new $alrb_wrapFile
    fi
else
    mv $alrb_wrapFile.new $alrb_wrapFile
fi
chmod +x $alrb_wrapFile

exit 0
}