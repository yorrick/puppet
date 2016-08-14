define puppet::master::setting( $ensure = 'present', $value = undef ) {

  Augeas {
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    context => '/files/etc/puppet/puppet.conf/master',
    notify  => Service['puppet'],
  }

  case $ensure {
    'absent': {
      augeas { "puppet::master::${title}":
        onlyif  => "match ${title} size > 0",
        changes => "rm ${title}",
      }
    }
    'present': {
      if ($value == undef) or (! is_string($value)) {
        fail("Puppet::Master::Setting[${title}]: required parameter value must be a non-empty string")
      }
      else {
        augeas { "puppet::master::${title}":
          onlyif  => "match ${title}[. = '${value}'] size == 0",
          changes => "set ${title} '${value}'",
        }
      }
    }
    default: {
      fail("Puppet::Master::Setting[${title}]: parameter ensure must be present or absent")
    }
  }

}
