desc "Install dotfiles and vim"
task :install do
  ruby = '1.9.3-p429'

  brews = %w(git mercurial curl libxml2 rbenv ruby-build ctags ctags-exuberant
    tmux markdown hub reattach-to-user-namespace vim)

  # Updated submodules.
  system "git submodule update --init"

  # Make ZSH the default.
  system "chsh -s /bin/zsh" unless ENV['SHELL'] == '/bin/zsh'

  system "brew update"
  system "brew install #{brews.join(' ')}"

  # Enable RBENV
  system "rbenv init"

  # Install Ruby
  if `rbenv versions | grep #{ruby}`.empty?
    system "rbenv install #{ruby}"
  end
  system "rbenv global #{ruby}"

  # Install bundler
  system 'gem install bundler'
  system 'rbenv rehash'

  # Install bundle
  system 'bundle'
end
task :default => :install
