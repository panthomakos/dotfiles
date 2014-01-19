class redis {
  package { 'redis': ensure => installed, }

  file {
    '/etc/redis.conf':
      ensure => file,
      source => 'puppet:///modules/redis/redis.conf',
      require => Package['redis'],
  }
}
