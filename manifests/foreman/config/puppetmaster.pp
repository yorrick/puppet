define puppet::foreman::config::puppetmaster(
  $foreman_url = undef,
  $puppet_home = '/var/lib/puppet',
  $puppet_user = 'puppet',
  $facts = true) {

  include puppet

  if $foreman_url == undef {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be defined")
  }

  if $foreman_url !~ /^https?:\/\/.*$/ {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be a valid URL")
  }

  file { '/etc/foreman':
    ensure => directory
  }

  file { '/etc/foreman/puppet.yaml':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/foreman/etc/puppet.yaml.erb"),
    require => File['/etc/foreman']
  }

  file { '/usr/lib/ruby/site_ruby/1.8/puppet/reports/foreman.rb' :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/foreman.rb",
    notify  => Service['puppet']
  }

  file { '/usr/local/scripts/push_facts_to_foreman.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/push_facts_to_foreman.rb"
  }

  cron { 'push_facts_to_foreman':
    command => 'sudo -u puppet /usr/local/scripts/push_facts_to_foreman.rb --push-facts',
    user    => root,
    hour    => '*',
    minute  => '0,30',
    require => File['/usr/local/scripts/push_facts_to_foreman.rb']
  }

}
