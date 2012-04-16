desc "Install dotfiles and vim"
task :install do
  system "git submodule update --init"

  # Make the commandT plugin.
  system "rvm use system"
  # Might require some re-configuration to add -lstatic-ruby to the LIBS=
  # in the Makefile.
  system "cd ~/.vim/bundle/command-t && /usr/bin/rake make"

  # Install markdown.
  system "brew install markdown"

  # Unbind the Command+H keybinding so that we can use it for switching view panes.
  system 'defaults write org.vim.MacVim NSUserKeyEquivalents -dict-add "Hide MacVim" "@\$H"'

  # Use the default RVM
  system 'rvm use default'

  # Install bundler
  system 'gem install bundler'

  # Install bundle
  system 'bundle'
end
task :default => :install
