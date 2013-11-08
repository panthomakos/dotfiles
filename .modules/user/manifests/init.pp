class user {
  $user = 'pan'
  $group = 'staff'
  $home = "/Users/${user}"

  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin', '/usr/sbin', '/sbin' ],
    environment => [ "HOME=${home}" ],
    cwd => $home,
  }

}
