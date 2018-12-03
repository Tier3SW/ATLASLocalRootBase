#!----------------------------------------------------------------------------
#!
#! wrapUp.sh
#!
#! tarball the work dir for user support
#!
#! Usage:
#!     wrapUp.sh
#!
#! History:
#!   07Aug14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

cd $ALRB_SMUDIR

source $ALRB_SMUDIR/shared.sh

\rm -f $ALRB_SMUDIR/summary.txt
touch $ALRB_SMUDIR/summary.txt

alrb_testResult=`\echo $alrb_testResult | \sed -e 's/^,//' -e 's/,$//'`

\echo " "
\echo "Tutorial : $alrb_tutorialVersion"
\echo "Domain   : $alrb_domain"
\echo "Nickname : $alrb_nickname"
\echo "Identity : $alrb_identity"

\echo "Tutorial : $alrb_tutorialVersion" >> $ALRB_SMUDIR/summary.txt
\echo "Domain   : $alrb_domain" >> $ALRB_SMUDIR/summary.txt
\echo "Nickname : $alrb_nickname" >> $ALRB_SMUDIR/summary.txt
\echo "Identity : $alrb_identity" >> $ALRB_SMUDIR/summary.txt
 
alrb_testAr=( `\echo $alrb_testResult | \sed -e 's/True/OK/g' -e 's/False/Failed/g' -e 's/,/ /g'` )
for alrb_item in ${alrb_testAr[@]}; do
    alrb_key=`\echo $alrb_item | \cut -d "=" -f 1`
    alrb_value=`\echo $alrb_item | \cut -d "=" -f 2`
    printf "  %-20s %10s\n" $alrb_key $alrb_value
    printf "  %-20s %10s\n" $alrb_key $alrb_value >> $ALRB_SMUDIR/summary.txt
done

\rm -f $ALRB_SCRATCH/smu.tar.gz
tar zcf $ALRB_SCRATCH/smu.tar.gz *
\mv $ALRB_SCRATCH/smu.tar.gz $ALRB_SMUDIR/smu.tar.gz

\echo " "
\echo "Tarball of results is $ALRB_SMUDIR/smu.tar.gz"
alrb_result=`\echo $alrb_testResult | \grep False 2>&1`
if [ $? -eq 0 ]; then
    \echo "Please also send $ALRB_SMUDIR/smu.tar.gz to user support."
    \echo -e "Some checks have failed and this node is NOT ready for the tutorial.    "'[\033[31mFAILED\033[0m]'
else
    \echo -e "All checks are passing and this node is ready for the tutorial.         "'[\033[32m  OK  \033[0m]'
fi

#alrb_ts=`\date +%s`
#alrb_tsms="${alrb_ts}000"
#alrb_testToDoList=( `\grep -e "^TEST:" $ALRB_SMUDIR/config.txt | \cut -f 2 -d ":" | \sed -e 's/,/ /g'`  ) 
#alrb_reportStr=$alrb_testResult
#for alrb_item in ${alrb_testToDoList[@]}; do
#    alrb_result=`\echo $alrb_reportStr | \grep $alrb_item 2>&1`
#    if [ $? -ne 0 ]; then
#	alrb_reportStr="$alrb_reportStr,$alrb_item=False"
#    fi
#done
#
#alrb_reportStr=`\echo $alrb_reportStr | \sed -e 's/=/:/g'`
#
#alrb_reportIdentity="$alrb_identity"
#if [ "$alrb_reportIdentity" = "unknown" ]; then
#    alrb_reportIdentity="`whoami` at `hostname -f`"
#fi
#
#alrb_reportStr="project:'$alrb_tutorialVersion',date:$alrb_tsms,identity:'$alrb_reportIdentity',domain:'$alrb_domain',$alrb_reportStr"
#
#\curl -d alrb_result="{$alrb_reportStr}" "http://setmeup-atlas.appspot.com/repeater"

unset alrb_key alrb_result alrb_testAr alrb_testResult alrb_value