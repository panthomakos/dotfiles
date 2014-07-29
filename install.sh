#!/bin/sh

declare user=$USER
declare zsh='/bin/zsh'

# Determine the current shell.
declare shell=`getent passwd $user | awk -F: '{ print $7}'`

# Update all submodules.
git submodule update --init

# Install ZSH if it's missing.
if [[ !(-f $zsh) ]]; then
  sudo pacman -S --noconfirm zsh
fi

# Change the default shell.
[[ $shell != $zsh ]] && chsh -s $zsh

# Ensure .rbenv is configured. This also happens in .zshrc.
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install ruby-build.
if [[ !( $(which ruby-build) ) ]]; then
  cd ruby-build && sudo ./install.sh
fi

# Install bundler.
if [[ !( $(gem list | grep bundler) ) ]]; then
  gem install bundler
  rbenv rehash
fi

bundle

# Configure Dropbox symlink.
ln -s $HOME/Dropbox/config/ssh.config $HOME/.ssh/config

# Ensure puppet is symlinked.
if [[ !( -d /etc/puppet ) ]]; then
  sudo ln -s $HOME/.puppet /etc/puppet
fi

cd /etc/puppet
  librarian-puppet install
  source $HOME/.puppet/puppy
  puppy:site
