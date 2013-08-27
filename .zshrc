alias mem.start="memcached -d -P /var/run/memcached.pid"
alias mem.stop='kill `cat ~/run/memcached.pid`'
alias bam='cd ~/Projects'
alias bam.strava='cd ~/Projects/strava'
alias mux='~/bin/mux'
alias vi='vim'
alias v='vim'
alias java=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands/java
alias ls="ls -G"
alias git=hub
alias redis.start="redis-server /usr/local/etc/redis.conf"
alias db:test:load="RAILS_ENV=test bundle exec rake db:schema:load"
alias guard.start="guard start >&log/guard.log &"
alias zk.start="zkServer start"
alias zk.stop="zkServer stop"
alias pg="pg_ctl -D /usr/local/var/postgres"
alias pg.start="pg -l /usr/local/var/postgres/server.log start"
alias pg.stop="pg stop -s -m fast"
alias psf="ps -ef | grep "
alias h="history"
alias b="bundle"
alias be="bundle exec"
alias k="be rake"
alias known="vim ~/.ssh/known_hosts"
alias git:clean="ruby ~/bin/git:clean"
alias ctags="`brew --prefix`/bin/ctags"
alias fingerprint="ssh-keygen -lf"

alias specs="find spec/**/*_spec.rb"
alias rspecnr="specs | xargs grep -sL 'spec_helper' | xargs bundle exec rspec -c"
alias rspecr="specs | xargs grep -sl 'spec_helper' | xargs bundle exec rspec -c"

alias sr="screen -r"
alias ss="screen -S"
alias sl="screen -ls"

export PATH=/usr/local/bin:/usr/local/share/npm/bin:$PATH
export EDITOR=vim
export VISUAL=vim

# RBENV
eval "$(rbenv init -)"
function rbenv_prompt_info() {
  local ruby_version
  ruby_version=$(rbenv version 2> /dev/null) || return
  echo "$ruby_version" | sed 's/[ \t].*$//'
}

# Copy TMUX Buffers to Clipboard
ruby ~/bin/tmux-copy.rb

# Prompt
autoload -U colors
colors
setopt PROMPT_SUBST

# Command Line Edit
autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

# History Searching in VI Mode
bindkey -M vicmd 'j' down-line-or-search
bindkey -M vicmd 'k' up-line-or-search

local smiley="%(?,%{$fg[green]%}☺%{$reset_color%},%{$fg[red]%}☹%{$reset_color%})"

PROMPT='
%~
${smiley}  %{$reset_color%}'

RPROMPT='%{$fg[white]%} $(rbenv_prompt_info)$(~/bin/git-cwd-info.rb)%{$reset_color%}'

# Vi Command Line Mode
set -o vi

# Autocompletion
setopt complete_aliases
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
fpath=(~/.zsh/.completion $fpath)
autoload -Uz compinit
compinit
