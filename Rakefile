desc "Install dotfiles and vim"
task :install do
  vim = 'https://raw.github.com/Homebrew/homebrew-dupes/master/vim.rb'

  # Updated submodules.
  system "git submodule update --init"

  # Make ZSH the default.
  system "chsh -s /bin/zsh"

  # Install mercurial, vim and ctags
  system "brew install mercurial"
  system "brew install #{vim}"
  system "brew install ctags-exuberant"

  # Install RBENV
  system "brew install rbenv ; brew install ruby-build"

  # Enable RBENV
  system "rbenv init"

  # Install 1.9.3
  system "rbenv install 1.9.3-p194"

  # Might require some re-configuration to add -lstatic-ruby to the LIBS=
  # in the Makefile.
  system "cd ~/.vim/bundle/command-t && /usr/bin/rake make"

  # Install markdown.
  system "brew install markdown"

  # Install hub
  system "brew install hub"

  # Install tmux
  system 'brew install tmux'
  system 'brew install reattach-to-user-namespace'

  # Unbind the Command+H keybinding so that we can use it for switching view panes.
  system 'defaults write org.vim.MacVim NSUserKeyEquivalents -dict-add "Hide MacVim" "@\$H"'

  # Set the default RBENV
  system "rbenv global 1.9.3-p194"

  # Install bundler
  system 'gem install bundler'

  # Install bundle
  system 'bundle'
end
task :default => :install
