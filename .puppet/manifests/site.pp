node default {
  include ruby, packages

  include yaourt
  include redis, firewall
  include time

  include services
  include vagrant
}
