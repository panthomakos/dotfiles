class user($user, $groups, $home) {
  user {
    $user:
      ensure => present,
      home => $home,
      groups => $groups,
  }
}
