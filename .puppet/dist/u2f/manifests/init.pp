class u2f {
  file {
    '/etc/udev/rules.d/70-u2f.rules':
      source => 'puppet:///modules/u2f/u2f.rules',
      ensure => file,
      owner => root,
      group => root,
  }
}
