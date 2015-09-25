# Class: puppet
#
# This module manages puppet
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet {

  file { '/etc/puppet/puppet.conf':
    ensure => present,
    owner  => 'puppet',
    group  => 'puppet',
    notify => Service['puppet'],
  }

  service { 'puppet':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true;
  }

}
