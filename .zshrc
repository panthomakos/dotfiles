export PATH=/opt/homebrew/bin:$PATH
export CDPATH=$HOME/src # https://linux.101hacks.com/cd-command/cdpath/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export BROWSER=chromium
export EDITOR=nvim
export VISUAL=nvim
# Secret Environment Variables and Configs
source ~/Dropbox/secret.env

# Ruby GC Tuning
export RUBY_HEAP_MIN_SLOTS=2000000 # <= 2.0.0
export RUBY_GC_HEAP_INIT_SLOTS=2000000 # >= 2.1.0

export RUBY_HEAP_FREE_MIN=200000
export RUBY_GC_MALLOC_LIMIT=100000000

# Fast directory switching function for projects (~/src).
function bam() {
  local dest=$(${HOME}/bin/bam -root $HOME/src $1)
  cd $dest
}

# Local BIN
export PATH=$PATH:$HOME/bin

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

RPROMPT='%{$fg[white]%} $(~/bin/git:rprompt)%{$reset_color%}'

# Vi Command Line Mode
set -o vi

# Autocompletion
setopt complete_aliases
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
fpath=(~/.zsh/.completion $fpath)
fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit

# If AWS command line tools are enabled, source the CLI completer.
if [[ -f /usr/local/bin/aws_zsh_completer.sh ]]; then
  source /usr/local/bin/aws_zsh_completer.sh
fi

source $HOME/.zsh/gpg
source $HOME/.zsh/aliases
source $HOME/.zsh/ctrl-z

# ASDF
#   `brew --prefix [PKG]` is slow to compute when a package is provided. This increases
#   time to source this file by over one second. The remainder of the path is hard-coded
#   here instead and can be recomputed if the ASDF install path ever changes.
. $(brew --prefix)/opt/asdf/asdf.sh
