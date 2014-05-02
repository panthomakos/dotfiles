class services {
  require user
  include packages
  include yaourt

  service {
    "btsync@${user::user}":
      enable => true,
      ensure => running,
      require => Package['btsync'],
  }
}
