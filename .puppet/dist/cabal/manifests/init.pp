class cabal($packages) {
  $update = '/usr/bin/cabal update'

  package { 'cabal-install': ensure => installed, }

  exec {
    $update:
      user => root,
      group => root,
      environment => ['HOME=/root'],
      require => Package['cabal-install'],
      unless => '/usr/bin/test -f /root/.cabal/packages/hackage.haskell.org/00-index.tar.gz',
  }

  cabal::install { $packages: require => Exec[$update], }
}
