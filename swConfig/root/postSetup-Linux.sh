#!----------------------------------------------------------------------------
#!
#!  postSetup.sh
#!
#!    post setup script
#!
#!  History:
#!    19Mar2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

if [ "$alrb_Quiet" = "NO" ]; then
    alrb_tmpVal=`$ROOTSYS/bin/root-config --version`
# for non-standard versions (eg Higgs)
    alrb_result=`\echo $alrb_rootVirtVersion | \sed -e "s/-$rootCmtConfig//g"`
    alrb_tmpVal2=`\echo $alrb_tmpVal | \sed -e 's|/|\.|g'`
    if [ "$alrb_result" != "$alrb_tmpVal2" ]; then
	alrb_tmpVal=$alrb_result
    fi
    \echo " root:"
    \echo "   Tip for _this_ standalone ROOT and grid (ie prun) submission:"
    \echo "    avoid --athenaTag if you do not need athena"
    \echo "    use --rootVer=$alrb_tmpVal --cmtConfig=${rootCmtConfig}"

    if [ ! -z $AtlasVersion ]; then
	alrb_currPy=`$ATLAS_LOCAL_ROOT_BASE/utilities/getCurrentEnvVal.sh $alrb_postSetupEnv python:ver | \cut -d "." -f 1-2`
	alrb_result=`\echo $CMTCONFIG | \grep $rootCmtConfig`
	alrb_rc=$?
	alrb_tmpVal=`\echo $PythonVERS | \cut -d "." -f 1-2`
	if [[ $alrb_rc -ne 0 ]] || [[ "$alrb_tmpVal" != "$alrb_currPy" ]]; then
	    \echo " root:"
            \echo "   Warning: Athena was setup: $CMTCONFIG, python $alrb_tmpVal"
            \echo "            ROOT was setup: $rootCmtConfig, python $alrb_currPy"
	fi
    fi
fi
unset alrb_tmpVal alrb_rc alrb_result altb_currPy alrb_rootVirtVersion alrb_tmpVal2