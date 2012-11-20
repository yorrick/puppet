
puppet::foreman::config::puppetmaster { 'configure puppetmaster':
    foreman_url => 'http://localhost',
}

puppet::foreman::config::puppetagent { 'configure puppetagent': }

