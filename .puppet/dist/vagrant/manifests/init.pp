class vagrant {
  require user

  package { ['virtualbox', 'vagrant']: ensure => installed, } ->

  exec {
    '/usr/bin/vagrant plugin install vagrant-vbguest':
      unless => '/usr/bin/vagrant plugin list | /usr/bin/grep vagrant-vbguest',
      user => $user::user,
      group => $user::group,
      environment => ["HOME=${user::home}"],
  } ->

  file {
    '/etc/modules-load.d/virtualbox.conf':
      source => 'puppet:///modules/vagrant/modules.conf',
      owner => 'root',
      group => 'root',
      ensure => file,
  } ~>

  # This is not really dependent on the modules-load.d file, but changing
  # that file is probably a good indication that we should reload modules.
  exec { '/usr/bin/vboxreload': refreshonly => true, }
}
