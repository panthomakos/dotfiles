desc "Install dotfiles and vim"
task :install do
  ruby = '1.9.3-p429'

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

  # Install bundler
  system 'gem install bundler'
  system 'rbenv rehash'

  # Install bundle
  system 'bundle'
end
task :default => :install
