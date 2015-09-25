define puppet::main::setting( $ensure = 'present', $value = undef ) {

  Augeas {
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    context => '/files/etc/puppet/puppet.conf/main',
    notify  => Service['puppet'],
  }

  case $ensure {
    'absent': {
      augeas { "puppet::main::${title}":
        onlyif  => "match ${title} size > 0",
        changes => "rm ${title}",
      }
    }
    'present': {
      if ($value == undef) or (! is_integer($value) and ! is_string($value)) {
        fail("Puppet::Main::Setting[${title}]: required parameter value must be a non-empty string or integer")
      }
      else {
        augeas { "puppet::main::${title}":
          onlyif  => "match ${title}[. = '${value}'] size == 0",
          changes => "set ${title} '${value}'",
        }
      }
    }
    default: {
      fail("Puppet::Main::Setting[${title}]: parameter ensure must be present or absent")
    }
  }

}
