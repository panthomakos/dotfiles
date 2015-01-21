node default {
  include ruby, packages

  include yaourt
  include firewall
  include time

  include services
  include vagrant

  include power
}
