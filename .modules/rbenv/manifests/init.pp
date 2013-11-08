class rbenv inherits user {
  package {
    ['rbenv', 'ruby-build']:
      ensure => installed,
      provider => brew,
  }
}
