class python::gunicorn($ensure=present, $owner=undef, $group=undef) {

  $rundir = "/var/run/gunicorn"

  if $ensure == "present" {
    file { $rundir:
      ensure => directory,
      owner => $owner,
      group => $group,
    }

  } elsif $ensure == 'absent' {

    file { $rundir:
      ensure => $ensure,
      owner => $owner,
      group => $group,
      recurse => true,
      purge => true,
      force => true,
    }
  }
}
