alias mem.start="memcached -d -P /var/run/memcached.pid"
alias mem.stop='kill `cat ~/run/memcached.pid`'
alias bam='cd ~/strava/active'
alias vi='vim'
alias java=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands/java
alias ls="ls -G"
alias git=hub
alias redis.start="redis-server /usr/local/etc/redis.conf"
alias db:test:load="RAILS_ENV=test bin/rake db:test:load"

export PATH=/usr/local/bin:$PATH
export EDITOR=vim

# EC2
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin
export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

source ~/.zsh/git-prompt/zshrc.sh
export PROMPT='%{$bold_color$fg[blue]%}$(~/.rvm/bin/rvm-prompt) %{$bold_color$fg[red]%}%~:$(git_super_status) %{$bold_clor$fg[blue]%}%#%{$reset_color%} '

# Use vi command line mode.
set -o vi
