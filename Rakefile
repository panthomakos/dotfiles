desc "Install dotfiles and vim"
task :install do
  system "git submodule update --init"
  system "chsh -s /bin/zsh" unless ENV['SHELL'] == '/bin/zsh'
  system 'sudo gem install bundler'
  system 'bundle'
  system 'cd .puppet ; librarian-puppet install ; cd ~'
end
task :default => [:install, :puppet]

desc 'Run puppet to ensure the system is up to date'
task :puppet do
  system 'puppet apply site.pp'
end
