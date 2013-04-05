define puppet::agent::setting( $ensure = 'present', $value = undef ) {

  Augeas {
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    context => '/files/etc/puppet/puppet.conf/agent',
    notify  => Service['puppet'],
  }

  case $ensure {
    'absent': {
      augeas { "puppet::agent::${title}":
        onlyif  => "match ${title} size > 0",
        changes => "rm ${title}",
      }
    }
    'present': {
      if ! $value {
        fail("Puppet::Agent::Setting[${title}]: required parameter value must be a string")
      }
      else {
        augeas { "puppet::agent::${title}":
          onlyif  => "match ${title}[. = ${value}] size == 0",
          changes => "set ${title} ${value}",
        }
      }
    }
    default: {
      fail("Puppet::Agent::Setting[${title}]: parameter ensure must be present or absent")
    }
  }

}
