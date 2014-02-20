define cabal::install {
  exec {
    "/usr/bin/cabal install --global ${name}":
      user => root,
      group => root,
      timeout => 3000,
      environment => ['HOME=/root'],
      unless => "/usr/bin/test -d /root/.cabal/packages/hackage.haskell.org/${name}",
  }
}
