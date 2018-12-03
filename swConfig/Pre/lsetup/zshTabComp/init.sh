# credit: https://askql.wordpress.com/2011/01/11/zsh-writing-own-completion/

if [ -z $alrb_zshTabComp ]; then

    alrb_zshTabComp="YES"

# COMPLETION SETTINGS
# add custom completion scripts
    fpath=(${ATLAS_LOCAL_ROOT_BASE}/swConfig/Pre/lsetup/zshTabComp $fpath) 
    
# compsys initialization
    autoload -U compinit
    compinit -u
    
# show completion menu when number of options is at least 2
    zstyle ':completion:*' menu select=2
fi