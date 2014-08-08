class puppet::config::puppetmaster {

  cron { 'clean_puppet_reports' :
    command => "find ${settings::vardir}/reports/ -name \"*.yaml\" -mtime +5 -exec rm -f {} \\;",
    user    => 'root',
    hour    => 1,
    minute  => 0
  }

  file { '/etc/puppet/rack':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { '/etc/puppet/rack/config.ru':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/config.ru",
    require => File['/etc/puppet/rack']
  }

}
