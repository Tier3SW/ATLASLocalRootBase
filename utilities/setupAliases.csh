#!----------------------------------------------------------------------------
#!
#! setupAliases.csh
#!
#! A simple script to setup aliases
#!
#! Usage:
#!     source setupAliases.csh
#!
#! History:
#!   29Nov07: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

  # add to end of path
  # copied from BaBar
alias appendPath 'if ( $\!:1 != \!:2 && $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 ) setenv \!:1 ${\!:1}\:\!:2'

  # add to front of path
  # copied from BaBar
alias insertPath 'if ( $\!:1 != \!:2 && $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 ) setenv \!:1 \!:2\:${\!:1}; if ( $\!:1 != \!:2 && $\!:1 !~ \!:2\:* ) setenv \!:1 \!:2\:`\echo ${\!:1} | \sed -e s%^\!:2\:%% -e s%:\!:2\:%:%g -e s%:\!:2\$%%`'

  # delete from path
  # copied from BaBar
alias deletePath 'setenv \!:1 `\echo ${\!:1} | \sed -e s%^\!:2\$%% -e s%^\!:2\:%% -e s%:\!:2\:%:%g -e s%:\!:2\$%%`'

