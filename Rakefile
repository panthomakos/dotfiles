desc "Install dotfiles and vim"
task :install do
  system "git submodule update --init"

  # Install RVM
  system "curl -L get.rvm.io | bash -s stable"

  # Enable RVM
  system "source ~/.rvm/scripts/rvm"

  # Install 1.9.3
  system "rvm install 1.9.3"

  # Make the commandT plugin.
  system "rvm use system"

  # Might require some re-configuration to add -lstatic-ruby to the LIBS=
  # in the Makefile.
  system "cd ~/.vim/bundle/command-t && /usr/bin/rake make"

  # Install markdown.
  system "brew install markdown"

  # Install hub
  system "brew install hub"

  # Unbind the Command+H keybinding so that we can use it for switching view panes.
  system 'defaults write org.vim.MacVim NSUserKeyEquivalents -dict-add "Hide MacVim" "@\$H"'

  # Use the default RVM
  system 'rvm use --default 1.9.3'

  # Install bundler
  system 'gem install bundler'

  # Install bundle
  system 'bundle'
end
task :default => :install
