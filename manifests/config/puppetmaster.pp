class puppet::config::puppetmaster {

  cron { 'clean_puppet_reports' :
    command => "find ${::vardir}/reports/ -name \"*.yaml\" -mtime +5 -exec rm -f {} \\;",
    user    => root,
    hour    => 1,
    minute  => 0
  }

}
