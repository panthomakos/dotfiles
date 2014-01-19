class user($user, $groups, $home) {
  # $home = "/Users/${user}"

  user {
    $user:
      ensure => present,
      home => $home,
      groups => $groups,
  }

  # Exec {
  #   path => [
  #     '/usr/local/bin',
  #     '/usr/bin',
  #     '/bin',
  #     '/usr/sbin',
  #     '/sbin',
  #     "${home}/.rbenv/bin",
  #   ],
  #   environment => [ "HOME=${home}" ],
  #   cwd => $home,
  # }
}
