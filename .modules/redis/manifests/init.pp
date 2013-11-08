class redis {
  package {
    'redis':
      ensure => installed,
      provider => brew,
  }

  file {
    '/usr/local/etc/redis.conf':
      ensure => present,
      source => 'puppet:///modules/redis/redis.conf',
      require => Package['redis'],
  }
}
