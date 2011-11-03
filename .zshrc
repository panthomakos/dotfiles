alias mem.start="memcached -d -P /var/run/memcached.pid"
alias mem.stop='kill `cat ~/run/memcached.pid`'
alias bam='cd ~/strava/active'
alias vi='vim'
alias java=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands/java
alias ls="ls -G"
alias git=hub
alias redis.start="redis-server /usr/local/etc/redis.conf"
alias db:test:load="RAILS_ENV=test bin/rake db:test:load"
alias guard.start="guard start >&log/guard.log &"

alias specs="find spec/**/*_spec.rb"
alias rspecnr="specs | xargs grep -sL 'spec_helper' | xargs bin/rspec -c"
alias rspecr="specs | xargs grep -sl 'spec_helper' | xargs bin/rspec -X -c"

alias sr="screen -r"
alias ss="screen -S"
alias sl="screen -ls"

export PATH=/usr/local/bin:$PATH
export EDITOR=vim
export VISUAL=vim

# EC2
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin
export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

autoload -Uz compinit
compinit

autoload -U colors
colors

setopt PROMPT_SUBST

fpath=(~/.zsh/functions $fpath)
autoload -U ~/.zsh/functions/*(:t)
update_current_git_vars

typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

preexec_functions+='preexec_update_git_vars'
precmd_functions+='precmd_update_git_vars'
chpwd_functions+='chpwd_update_git_vars'

export PROMPT='%{$bold_color$fg[blue]%}$(~/.rvm/bin/rvm-prompt) %{$bold_color$fg[red]%}%~:$(prompt_git_info) %{$bold_clor$fg[blue]%}%#%{$reset_color%} '

# Use vi command line mode.
set -o vi
