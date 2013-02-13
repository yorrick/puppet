class ztaskd::server () {

    package { "libzmq-dev":
        ensure => "2.2.0+dfsg-2",
    }

    package { "python2.7-dev":
        ensure => "2.7.3~rc2-2.1",
    }

    service { "ztaskd":
        ensure => "running",
        enable => "true",
        require => [Package["libzmq-dev"], File["/var/run/ztask"], File["/var/log/ztask"], File["/etc/init.d/ztaskd"]],
    }

    file {'/etc/init.d/ztaskd':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 755,
        source  => "puppet:///modules/ztaskd/init-script.sh",
        require => Package["libzmq-dev"],
    #    notify  => Service["ztaskd"],
    }

    file { "/var/run/ztask":
        ensure => 'directory',
        mode => '755',
    }

    file { "/var/log/ztask":
        ensure => 'directory',
        mode => '755',
    }

}

