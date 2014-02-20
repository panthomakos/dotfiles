node default {
  include ruby, packages

  include yaourt, cabal
  include bitlbee, redis

  # TODO [add cron task to run puppet]

  # include gems, osx, osx::packages, plist, redis
  # Package { provider => brew }
}
