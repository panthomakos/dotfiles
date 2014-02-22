node default {
  include ruby, packages

  include yaourt
  include bitlbee, redis, pandoc

  # TODO [add cron task to run puppet]

  # include gems, osx, osx::packages, plist, redis
  # Package { provider => brew }
}
