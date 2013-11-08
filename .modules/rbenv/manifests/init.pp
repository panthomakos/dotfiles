class rbenv {
  package {
    ['rbenv', 'ruby-build']:
      ensure => installed,
      provider => brew,
  }
}
