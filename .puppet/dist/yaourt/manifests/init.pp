class yaourt($packages) {
  ini_setting {
    'yaourt SigLevel':
      ensure => present,
      path => '/etc/pacman.conf',
      section => 'archlinuxfr',
      setting => 'SigLevel',
      value => 'Never',
  }

  ini_setting {
    'yaourt Server':
      ensure => present,
      path => '/etc/pacman.conf',
      section => 'archlinuxfr',
      setting => 'Server',
      value => "http://repo.archlinux.fr/$architecture",
  }

  package {
    'yaourt':
      ensure => installed,
      require => [
        Ini_setting['yaourt SigLevel'],
        Ini_setting['yaourt Server'],
      ],
  }

  package {
    $packages:
      ensure => installed,
      require => Package['yaourt'],
  }
}
