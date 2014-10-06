class services {
  require user
  include packages
  include yaourt

  Service {
    enable => true,
    ensure => running,
  }

  service { "syncthing@${user::user}": require => Package['syncthing'], }

  service { "dropbox@${user::user}": require => Package['dropbox'], }

  service { 'rpcbind': require => Package['nfs-utils'], } ->

  service { 'nfs-server': }
}
