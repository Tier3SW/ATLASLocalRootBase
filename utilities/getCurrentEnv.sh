#!----------------------------------------------------------------------------
#!
#!  getCurrentEnv.sh
#!
#!    Print out a comma delimited string of compiler and python versions
#!     format will be compiler/python:arch:version
#!
#!  Usage:
#!    source getCurrentEnv.sh
#!
#!  History:
#!    21Jan2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

alrb_currentEnv=""

# python format: python:ver=version::arch=arch:
alrb_version=`python -V 2>&1 | \awk '{print $2}'`
alrb_exe=`which python`
alrb_exe=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_exe`
alrb_exeArch=`\file $alrb_exe | \sed -e 's/.*ELF \(.*\)-bit.*/\1/'`
if [ "$alrb_exeArch" = "32" ]; then
    alrb_exeArch="i686"
else
    alrb_exeArch="x86_64"
fi
alrb_currentEnv="${alrb_currentEnv};python:ver=${alrb_version}:arch=${alrb_exeArch}:"

if [ "$ALRB_OSTYPE" = "MacOSX" ]; then
# nothing needed for MacOSX yet; using defaults
    alrb_currentEnv="$alrb_currentEnv"
else    
# gcc format: gcc:ver=version:
    alrb_version=`gcc -dumpversion 2>&1`
    if [ $? -eq 0 ]; then
	alrb_currentEnv="${alrb_currentEnv};gcc:ver=${alrb_version}:"
    else
	alrb_currentEnv="${alrb_currentEnv};gcc:ver=0.0:"
    fi
fi


\echo "$alrb_currentEnv;"
unset alrb_version alrb_exe alrb_exeArch alrb_currentEnv
return 0

