define puppet::foreman::config::puppetagent {

  include puppet

  augeas { 'configure-foreman-reporting-for-puppetagent':
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    context => '/files/etc/puppet/puppet.conf/agent',
    changes => [
        'set report true'
    ],
    onlyif  => 'match report[.="true"] size == 0',
    require => File['/etc/puppet/puppet.conf'],
    notify  => Service['puppet']
  }

}
