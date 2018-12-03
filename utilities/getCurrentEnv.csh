#!----------------------------------------------------------------------------
#!
#!  getCurrentEnv.csh
#!
#!    Print out a comma delimited string of compiler and python versions
#!     format will be compiler/python:arch:version
#!
#!  Usage:
#!    source getCurrentEnv.csh
#!
#!  History:
#!    21Jan2015: A. De Silva, first version.
#!
#!----------------------------------------------------------------------------

set alrb_currentEnv=""

# python format: python:ver=version:arch=arch:
set alrb_version=`(python -V > /dev/tty) |& \awk '{print $2}'`
set alrb_exe=`which python`
set alrb_exe=`$ATLAS_LOCAL_ROOT_BASE/utilities/wrapper_readlink.sh $alrb_exe`
set alrb_exeArch=`\file $alrb_exe | \sed -e 's/.*ELF \(.*\)-bit.*/\1/'`
if ( "$alrb_exeArch" == "32" ) then
    set alrb_exeArch="i686"
else
    set alrb_exeArch="x86_64"
endif
set alrb_currentEnv="$alrb_currentEnv;python:ver=${alrb_version}:arch=${alrb_exeArch}:"

if ( "$ALRB_OSTYPE" == "MacOSX" ) then
# nothing needed for MacOSX yet; using defaults
    set alrb_currentEnv="$alrb_currentEnv"
else    
# gcc format: gcc:ver=version:
    gcc -dumpversion >& /dev/null
    if ( $? == 0 ) then
	set alrb_version=`gcc -dumpversion`
	set alrb_currentEnv="$alrb_currentEnv;gcc:ver=${alrb_version}:"
    else
	set alrb_currentEnv="$alrb_currentEnv;gcc:ver=0.0:"
    endif
endif

\echo "$alrb_currentEnv;"
unset alrb_version alrb_exe alrb_exeArch alrb_currentEnv
exit 0

