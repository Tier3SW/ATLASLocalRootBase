#!----------------------------------------------------------------------------
#!
#! checkShell.zsh
#!
#! check zsh shell for various things
#!
#! History:
#!   28Mar12: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fixed=""
alrb_first=""

setopt | \grep extendedglob | \egrep -v off >& /dev/null
if [ $? -eq 0 ]; then
  alrb_fixed="Yes"
  if [ "$alrb_first" = "" ]; then
    alrb_first="No"
    \echo ' '
  fi
  \echo ' Your shell is zsh and extendedglob was set ...'
  \echo '  Now doing unsetopt extendedglob ...'
  unsetopt extendedglob
fi

setopt | \grep braceccl >& /dev/null
if [ $? -eq 0 ]; then
  alrb_fixed="Yes"
  if [ "$alrb_first" = "" ]; then
    alrb_first="No"
    \echo ' '
  fi
  \echo ' Your shell is zsh and braceccl was set ...'
  \echo '  Now doing unsetopt braceccl ...'
  unsetopt braceccl  
fi

if [ "$alrb_fixed" != "" ]; then
  \echo ' '
fi
 
unset alrb_first alrb_fixed
