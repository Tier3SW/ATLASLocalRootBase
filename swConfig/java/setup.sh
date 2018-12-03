#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script to setup java for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` ) 
for alrb_item in ${alrb_tmpAr[@]}; do
    alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    case $alrb_tmpVal in
	alrb_javaHome)
	    alrb_javaHome=`\echo $alrb_item | \cut -f 2 -d "="`
	    ;;
    esac
done

export JAVA_HOME=$alrb_javaHome
insertPath PATH $JAVA_HOME/bin

unset alrb_javaHome
