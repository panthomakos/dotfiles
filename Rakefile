desc "Install dotfiles and vim"
task :install do
  system "git submodule update --init"

  # Make the commandT plugin.
  system "rvm system"
  # Might require some re-configuration to add -lstatic-ruby to the LIBS=
  # in the Makefile.
  system "cd ~/.vim/bundle/command-t && rake make"

  # Make the textobj plugin.
  system "cd ~/.vim/bundle/textobj-user && git submodule init && git submodule update && make"

  # Install markdown.
  system "brew install markdown"

  # Unbind the Command+H keybinding so that we can use it for switching view panes.
  system 'defaults write org.vim.MacVim NSUserKeyEquivalents -dict-add "Hide MacVim" "@\$H"'
end
task :default => :install
