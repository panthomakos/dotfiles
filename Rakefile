desc "Install dotfiles and vim"
task :install do
  ruby = '1.9.3-p327'

  brews = %w(git mercurial curl libxml2 rbenv ruby-build ctags ctags-exuberant
    tmux markdown hub reattach-to-user-namespace vim)

  # Updated submodules.
  system "git submodule update --init"

  # Make ZSH the default.
  system "chsh -s /bin/zsh"

  system "brew install #{brews.join(' ')}"

  # Enable RBENV
  system "rbenv init"

  # Install Ruby
  system "rbenv install #{ruby}"
  system "rbenv global #{ruby}"

  # Might require some re-configuration to add -lstatic-ruby to the LIBS=
  # in the Makefile. Make sure you have XCode Installed (xcrun needs it).
  system "cd ~/.vim/bundle/command-t && rbenv local system && /usr/bin/rake make"

  # Install bundler
  system 'gem install bundler'
  system 'rbenv rehash'

  # Install bundle
  system 'bundle'
end
task :default => :install
