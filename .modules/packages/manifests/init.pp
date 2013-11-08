class packages inherits user {
  $packages = [
    'git', 'mercurial', 'curl',
    'libxml2', 'ctags',
    'tmux', 'markdown', 'hub',
    'reattach-to-user-namespace',
    'vim', 'mysql', 'zookeeper']

  package {
    $packages:
      ensure => installed,
      provider => brew,
  }
}
