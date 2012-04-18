alias mem.start="memcached -d -P /var/run/memcached.pid"
alias mem.stop='kill `cat ~/run/memcached.pid`'
alias bam='cd ~/Projects'
alias bam.strava='cd ~/Projects/strava/active'
alias vi='vim'
alias java=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands/java
alias ls="ls -G"
alias git=hub
alias redis.start="redis-server /usr/local/etc/redis.conf"
alias db:test:load="RAILS_ENV=test bundle exec rake db:schema:load"
alias guard.start="guard start >&log/guard.log &"
alias psf="ps -ef | grep "
alias clear="echo 'Use <C-l> instead'"
alias h="history"
alias b="bundle"
alias be="bundle exec"
alias k="bundle exec rake"
alias known="vim ~/.ssh/known_hosts"
alias powenv="rvm env > .powenv"

alias specs="find spec/**/*_spec.rb"
alias rspecnr="specs | xargs grep -sL 'spec_helper' | xargs bundle exec rspec -c"
alias rspecr="specs | xargs grep -sl 'spec_helper' | xargs bundle exec rspec -c"

alias sr="screen -r"
alias ss="screen -S"
alias sl="screen -ls"

export PATH=/usr/local/bin:$PATH
export EDITOR=vim
export VISUAL=vim

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH=$PATH:$HOME/.rvm/bin

# Prompt
autoload -U colors
colors
setopt PROMPT_SUBST

local smiley="%(?,%{$fg[green]%}☺%{$reset_color%},%{$fg[red]%}☹%{$reset_color%})"

PROMPT='
%~
${smiley}  %{$reset_color%}'

RPROMPT='%{$fg[white]%} $(~/.rvm/bin/rvm-prompt)$(~/bin/git-cwd-info.rb)%{$reset_color%}'

# Vi Command Line Mode
set -o vi

# Autocompletion
setopt complete_aliases
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
fpath=(~/.zsh/.completion $fpath)
autoload -Uz compinit
compinit
