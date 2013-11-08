desc "Install dotfiles and vim"
task :install do
  system "git submodule update --init"
  system "chsh -s /bin/zsh" unless ENV['SHELL'] == '/bin/zsh'
  system 'sudo gem install bundler'
  system 'bundle'
end
task :default => [:install, :puppet]

desc 'Run puppet to ensure the system is up to date'
task :puppet do
  system 'cd .puppet ; librarian-puppet install ; cd ~'
  system 'sudo puppet apply site.pp --modulepath=/Users/pan/.puppet/modules'
end
