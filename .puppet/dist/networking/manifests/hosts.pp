class networking::hosts($hostname = $title) {
  file {
    '/etc/hosts':
      ensure => file,
      content => template('networking/hosts.erb'),
  }
}
