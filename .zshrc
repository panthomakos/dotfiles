source $HOME/.zsh/gpg
source $HOME/.zsh/aliases

export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:$PATH
export BROWSER=google-chrome-stable
export EDITOR=vim
export VISUAL=vim
# Tell Java that XMonad is non-reparenting. This fixes some issues with
# maximizing java windows.
export _JAVA_AWT_WM_NONREPARENTING=1
# If java_home is available, set the environment variable.
[[ -f /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home)"
# Credential file for the Ruby AWS SDK.
export AWS_CREDENTIAL_FILE=~/.aws/credentials
export SSH_AUTH_SOCK=~/.config/ssh-agent.socket

# I use ~/.env to store my secret environment variables. If it exists, source it.
[[ -f .env ]] && source .env

# RBENV
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
function rbenv_prompt_info() {
  local ruby_version
  ruby_version=$(rbenv version 2> /dev/null) || return
  echo "$ruby_version" | sed 's/[ \t].*$//'
}

# Copy TMUX Buffers to Clipboard on Mac
if [[ "$(uname)" == "Darwin" ]]; then
  ruby ~/bin/tmux-copy.rb
fi

# Prompt
autoload -U colors
colors
setopt PROMPT_SUBST

# Command Line Edit
autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
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
