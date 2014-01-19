class ruby {
  include user

  $version = '2.0.0-p353'

  Exec {
    user => $user::user,
  }

  $rbenv = "${user::home}/.rbenv/bin/rbenv"

  exec {
    "$rbenv init":
      refreshonly => true,
  }

  exec {
    "$rbenv install $version":
      require => Exec["$rbenv init"],
      onlyif => "$rbenv version | grep -v $version";

    "$rbenv global $version":
      refreshonly => true;
  }

  Exec["$rbenv install $version"] ~> Exec["$rbenv global $version"]
}
