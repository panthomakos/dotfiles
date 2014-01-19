class gems inherits user {
  require ruby

  $gems = [ 'boom', 'lunchy', 'powder', 'pry', 'zeus' ]

  package {
    $gems:
      ensure => present,
      provider => gem,
  }

  exec {
    'rbenv rehash':
      refreshonly => true,
  }

  Package[$gems] ~> Exec['rbenv rehash']
}
