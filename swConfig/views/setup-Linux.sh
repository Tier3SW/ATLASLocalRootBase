#!----------------------------------------------------------------------------
#!
#! setup.sh
#!
#! A simple script views for local Atlas users
#!
#! Usage:
#!     source setup.sh <version>
#!
#! History:
#!   09Oct15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_tmpVal=`\echo $@ | \sed -e 's/:/ /g'`
eval source $VIEWSDIR/setupViews.sh $alrb_tmpVal
return $?    


