class bitlbee {
  package { 'bitlbee': ensure => installed, }

  file {
    '/etc/bitlbee/bitlbee.conf':
      ensure => file,
      source => 'puppet:///modules/bitlbee/bitlbee.conf',
      require => Package['bitlbee'],
  }

  file {
    '/var/lib/bitlbee':
      ensure => directory,
      owner => bitlbee,
      group => bitlbee,
      require => Package['bitlbee'],
  }

  service {
    'bitlbee':
      ensure => running,
      enable => true,
      require => Package['bitlbee'],
  }
}
