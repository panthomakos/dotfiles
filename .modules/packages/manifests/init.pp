class packages inherits user {
  $packages = [
    'git', 'mercurial', 'curl',
    'ec2-api-tools',
    'libxml2', 'ctags',
    'tmux', 'markdown', 'hub',
    'reattach-to-user-namespace',
    'vim', 'mysql', 'zookeeper']

  package {
    $packages:
      ensure => installed,
      provider => brew,
  }

  package {
    'Viscosity':
      provider => appdmg,
      ensure => installed,
      source => 'http://www.thesparklabs.com/downloads/Viscosity.dmg',
  }

  package {
    'Chrome':
      provider => appdmg,
      ensure => installed,
      source => 'https://dl.google.com/chrome/mac/stable/GoogleChrome.dmg',
  }
}
