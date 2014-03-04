class firewall {
  file {
    '/etc/iptables/iptables.rules':
      source => 'puppet:///modules/firewall/iptables.rules',
      ensure => file,
      notify => Service['iptables'],
  }

  service {
    'iptables':
      enable => true,
      ensure => running,
  }
}
