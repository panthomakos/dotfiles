define pacman($package=$title){
  exec {
    "/usr/bin/pacman -S ${package}":
      unless => "/usr/bin/pacman -Qs ${package}",
  }
}
