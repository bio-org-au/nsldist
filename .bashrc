
PATH=$HOME/Google/bin:$HOME/bin:$HOME/.sdkman/candidates/java/current/bin:$PATH

export EDITOR=em

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


PATH=$PATH:/opt/google-cloud-cli/bin
PATH=$HOME/Google/bin:$HOME/Google/binw:$PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
source /usr/share/nvm/init-nvm.sh


# Load Angular CLI autocompletion.
source <(ng completion script)

PATH="/c/Users/chris/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/c/Users/chris/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/c/Users/chris/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/c/Users/chris/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/c/Users/chris/perl5"; export PERL_MM_OPT;

(deadmansswitch &)
sleep 1
