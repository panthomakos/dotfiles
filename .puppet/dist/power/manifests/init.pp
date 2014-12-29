class power {
  file {
    '/etc/udev/rules.d/90-xhc_sleep.rules':
      source => 'puppet:///modules/power/xhc.rules',
      ensure => file,
      owner => root,
      group => root,
  }
}
