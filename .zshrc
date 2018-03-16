source $HOME/.zsh/gpg
source $HOME/.zsh/aliases
source $HOME/.zsh/ctrl-z

export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export GOPATH=$HOME/Projects/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export BROWSER=chromium
export EDITOR=vim
export VISUAL=vim
# Tell Java that XMonad is non-reparenting. This fixes some issues with
# maximizing java windows.
export _JAVA_AWT_WM_NONREPARENTING=1
# If java_home is available, set the environment variable.
[[ -f /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home)"
# Temporary AWS Credentials
source ~/.aws/token_profile
export SSH_AUTH_SOCK=~/.config/ssh-agent.socket

# Ruby GC Tuning

export RUBY_HEAP_MIN_SLOTS=2000000 # <= 2.0.0
export RUBY_GC_HEAP_INIT_SLOTS=2000000 # >= 2.1.0

export RUBY_HEAP_FREE_MIN=200000
export RUBY_GC_MALLOC_LIMIT=100000000

# Fast directory switching function for Projects.
function bam() {
  local dest=$(${HOME}/bin/bam $1)
  cd $dest
}

# I use ~/.env to store my secret environment variables. If it exists, source it.
[[ -f .env ]] && source .env

# Local BIN
export PATH=$PATH:$HOME/bin

# Yarn/NPM BIN
export PATH="$PATH:/$HOME/.node_modules/bin"
export npm_config_prefix=~/.node_modules

# RBENV
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
function rbenv_prompt_info() {
  local ruby_version
  ruby_version=$(rbenv version 2> /dev/null) || return
  echo "$ruby_version" | sed 's/[ \t].*$//'
}

# Prompt
autoload -U colors
colors
setopt PROMPT_SUBST

# Command Line Edit
autoload edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey -M vicmd v edit-command-line

# History Searching in VI Mode
bindkey -M vicmd 'j' down-line-or-search
bindkey -M vicmd 'k' up-line-or-search
bindkey -M vicmd '?' history-incremental-search-backward

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

# If AWS command line tools are enabled, source the CLI completer.
if [[ -f /usr/local/bin/aws_zsh_completer.sh ]]; then
  source /usr/local/bin/aws_zsh_completer.sh
fi

# ASDF
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
