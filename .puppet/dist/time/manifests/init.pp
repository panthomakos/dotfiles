class time {
  package { 'ntp': ensure => installed, }
  service{ 'ntpd': ensure => running, enable => true, }
}
