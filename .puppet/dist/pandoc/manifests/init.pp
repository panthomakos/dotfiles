class pandoc {
  ini_setting {
    'haskell Server':
      ensure => present,
      path => '/etc/pacman.conf',
      section => 'haskell-core',
      setting => 'Server',
      value => "http://www.kiwilight.com/haskell/core/$architecture",
  }

  ini_setting {
    'haskell SigLevel':
      ensure => present,
      path => '/etc/pacman.conf',
      section => 'haskell-core',
      setting => 'SigLevel',
      value => 'Never',
  }

  Ini_setting['haskell Server'] ~> Exec['/usr/bin/pacman -Syy']
  Ini_setting['haskell SigLevel'] ~> Exec['/usr/bin/pacman -Syy']

  exec {
    '/usr/bin/pacman -Syy':
      refreshonly => true,
  }

  package {
    'haskell-pandoc':
      ensure => installed,
      require => [
        Exec['/usr/bin/pacman -Syy'],
      ],
  }
}
