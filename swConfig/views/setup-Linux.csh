#!----------------------------------------------------------------------------
#!
#! setup.csh
#!
#! A simple script views for local Atlas users
#!
#! Usage:
#!     source setup.csh <version>
#!
#! History:
#!   09Oct15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

set alrb_tmpVal=`\echo $* | \sed -e 's/:/ /g'`
source $VIEWSDIR/setupViews.csh $alrb_tmpVal
exit $?    

