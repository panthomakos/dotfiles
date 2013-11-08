class ruby inherits user {
  $version = '1.9.3-p448'

  package {
    ['rbenv', 'ruby-build']:
      ensure => present,
      provider => brew,
  }

  Package['rbenv'] ~> Exec['rbenv init']

  exec {
    'rbenv init':
      refreshonly => true,
  }

  exec {
    'install ruby':
      command => "rbenv install ${version}",
      require => Exec['rbenv init'],
      onlyif => "rbenv version | grep -v ${version}";

    'set ruby':
      command => "rbenv global ${version}",
      refreshonly => true;
  }

  Exec['install ruby'] ~> Exec['set ruby']
}
