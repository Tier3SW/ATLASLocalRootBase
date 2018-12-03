#!----------------------------------------------------------------------------
#!
#! parseVersionVar.sh
#!
#! set variables based on results of the argument which is a version value
#!
#! Usage:
#!     alrb_fn_parseVersionVar <version>
#!
#! History:
#!   23Mar15: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fn_parseVersionVar() 
{

# these are the variables that will be set
    alrb_python=""
    alrb_gcc=""
    alrb_arch=""
    alrb_slc=""
    alrb_boost=""
    alrb_firstVer=""
    
    local alrb_tmpVal=$1
    
# fix for gcc versions
    local alrb_tmpVal1
    alrb_tmpVal1=`\echo $alrb_tmpVal | \grep -e "^gcc" 2>&1`
    if [ $? -eq 0 ]; then
	alrb_tmpVal=`\echo $alrb_tmpVal1 | \sed -e "s/_/-/g" | \sed -e "s/x86-64/x86_64/g"`
    fi
    
# always return the first field
    alrb_firstVer=`\echo $alrb_tmpVal | \cut -f 1 -d "-" | \sed -e 's/^\([a-zA-Z]*\)\([\.0-9]*\)/\2 \1/g'`
    
    local alrb_tmpAr=( `\echo $alrb_tmpVal | \sed 's/-/ /g'` )
    for alrb_tmpVal in "${alrb_tmpAr[@]}"; do
	\echo $alrb_tmpVal | \grep "gcc" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
	    alrb_gcc=`\echo $alrb_tmpVal | \sed 's/\.//'`
	    continue
	fi
	\echo $alrb_tmpVal | \grep "slc" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
	    alrb_slc=$alrb_tmpVal
	    continue
	fi
	\echo $alrb_tmpVal | \grep "i686" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
            alrb_arch="i686"
	    continue
	fi
	\echo $alrb_tmpVal | \grep "x86_64" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
            alrb_arch="x86_64"
	    continue
	fi
	\echo $alrb_tmpVal | \grep "python" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
            alrb_python=`\echo $alrb_tmpVal | \sed -e 's/python//g'`
	    continue
	fi
	\echo $alrb_tmpVal | \grep "boost" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
            alrb_boost=$alrb_tmpVal
	    continue
	fi
    done
}


