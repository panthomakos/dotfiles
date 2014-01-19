class packages($packages) {
  package { $packages: ensure => installed, }
}
