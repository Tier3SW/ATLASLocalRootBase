#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup Atlantis for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

export ATLAS_LOCAL_ATLANTIS_VERSION=$1
export ATLAS_LOCAL_ATLANTIS_PATH=${ATLAS_LOCAL_ROOT}/Atlantis/${ATLAS_LOCAL_ATLANTIS_VERSION}/AtlantisJava

alrb_javaAtlantis="java"
alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	alrb_javaHome)
	    alrb_javaAtlantis=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

if [ "$ALRB_OSTYPE" = "MacOSX" ]; then
    alias runAtlantis='$alrb_javaAtlantis -Dapple.awt.graphics.UseQuartz=false -jar $ATLAS_LOCAL_ATLANTIS_PATH/atlantis.jar'
else
    alias runAtlantis='$alrb_javaAtlantis -jar $ATLAS_LOCAL_ATLANTIS_PATH/atlantis.jar'
fi

unset alrb_tmpAr alrb_tmpVal alrb_item
