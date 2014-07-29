define puppet::foreman::config::puppetmaster($foreman_url = undef) {

  include puppet

  if $foreman_url == undef {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be defined")
  }

  if $foreman_url !~ /^https?:\/\/.*$/ {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be a valid URL")
  }

  file { '/usr/lib/ruby/site_ruby/1.8/puppet/reports/foreman.rb' :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/foreman/reports/foreman.rb.erb"),
    notify  => Service['puppet']
  }

  file { '/usr/local/scripts/push_facts_to_foreman.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0750',
    content => template("${module_name}/foreman/facts/push_facts_to_foreman.rb.erb")
  }

  cron { 'push_facts_to_foreman':
    command => '/usr/local/scripts/push_facts_to_foreman.rb',
    user    => root,
    hour    => 2,
    minute  => 0,
    require => File['/usr/local/scripts/push_facts_to_foreman.rb']
  }

}
