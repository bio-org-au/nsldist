
PATH=$HOME/bin:$HOME/Google/bin:$HOME/Google/bin:$HOME/.sdkman/candidates/java/current/bin:$PATH

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#stty intr ^g

export PGPASSWORD=Nb47mLK4R49GNzna

PATH=$PATH:/opt/google-cloud-cli/bin
PATH=$HOME/Google/bin:$HOME/Google/binw:$PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
source /usr/share/nvm/init-nvm.sh

#source /etc/profile.d/vte.sh

# Load Angular CLI autocompletion.
#source <(ng completion script)

deadmansswitch >/dev/null & disown $!
