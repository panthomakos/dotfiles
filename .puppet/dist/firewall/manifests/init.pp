class firewall {
  $restore = '/usr/bin/iptables-restore < /etc/iptables/iptables.rules'

  file {
    '/etc/iptables/iptables.rules':
      source => 'puppet:///modules/firewall/iptables.rules',
      ensure => file,
      notify => Exec[$restore],
  }

  exec { $restore: refreshonly => true, }

  service {
    'iptables':
      enable => true,
      ensure => running,
  }
}
