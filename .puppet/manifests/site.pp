node default {
  include ruby, packages

  include yaourt
  include bitlbee, redis, firewall
}
