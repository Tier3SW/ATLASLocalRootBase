#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script to setup java for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   27Apr15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_tmpAr=( `\echo $2 | \sed -e 's/,/ /g'` )
foreach alrb_item ($alrb_tmpAr)
    set alrb_tmpVal=`\echo $alrb_item | \cut -f 1 -d "="`
    switch ($alrb_tmpVal)
        case alrb_javaHome:
	    set alrb_javaHome=`\echo $alrb_item | \cut -f 2 -d "="`
	    breaksw
        default:
	    breaksw
    endsw
end

setenv JAVA_HOME $alrb_javaHome
insertPath PATH $JAVA_HOME/bin

unset alrb_javaHome

