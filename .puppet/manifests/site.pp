node default {
  include ruby, packages

  include yaourt
  include bitlbee, redis, firewall

  # TODO [add cron task to run puppet]

  # include gems, osx, osx::packages, plist, redis
  # Package { provider => brew }
}
