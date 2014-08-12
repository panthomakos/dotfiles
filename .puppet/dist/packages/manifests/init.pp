class packages($packages, $bundles) {
  package { $packages: ensure => installed, }
  pacman{ $bundles: }
}
