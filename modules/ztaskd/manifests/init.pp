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
        require => [Package["libzmq-dev"], File["/var/log/ztask"], File["/etc/init.d/ztaskd"]],
    }

    file {'/usr/local/bin/ztaskd':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 755,
        source  => "puppet:///modules/ztaskd/ztaskd.sh",
    }

    # TODO add dep on lsb-base (>= 3.0-6)
    file {'/etc/init.d/ztaskd':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 755,
        source  => "puppet:///modules/ztaskd/init-script.sh",
        require => Package["libzmq-dev"],
        notify  => Service["ztaskd"],
    }

    file { "/var/log/ztask":
        ensure => 'directory',
        mode => '777',
    }

    # TODO add dependency to virtualenv and home-automation application

}

