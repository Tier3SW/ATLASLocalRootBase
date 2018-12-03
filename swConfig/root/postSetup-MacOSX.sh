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
    let alrb_clangUsed=`\echo $alrb_rootVirtVersion | \cut -f 4 -d "-" | \sed -e 's/clang//g'`
    let alrb_clangAvailable=`clang --version | \grep version | \cut -f 4 -d " " | \cut -f 1-2 -d "." | \sed -e 's/\.//g'`
        if [ $alrb_clangUsed -gt $alrb_clangAvailable ]; then
	    \echo " root:"
	    \echo "   Warning: clang $alrb_clangAvailable is setup but you need $alrb_clangUsed"
	fi
fi

unset alrb_clangUsed alrb_clangAvailable alrb_rootVirtVersion
