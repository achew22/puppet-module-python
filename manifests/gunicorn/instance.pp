define python::gunicorn::instance($venv,
                                  $src,
                                  $ensure=present,
                                  $wsgi_module=undef,
                                  $django=false,
                                  $workers=1) {
  $is_present = $ensure == "present"

  $rundir = $python::gunicorn::rundir
  $owner = $python::gunicorn::owner
  $group = $python::gunicorn::group

  $pidfile = "$rundir/$name.pid"
  $socket = "unix:$rundir/$name.sock"

  if !$wsgi_module and !$django {
    fail("If you're not using Django you have to define a WSGI module.")
  }

  file { "/etc/init.d/gunicorn-${name}":
    ensure => $ensure,
    content => template("python/gunicorn.init.erb"),
    mode => 744,
  }

  service { "gunicorn-${name}":
    ensure => $is_present,
    enable => $is_present,
    hasstatus => $is_present,
    hasrestart => $is_present,
    subscribe => File["/etc/init.d/gunicorn-${name}"],
    require => File["/etc/init.d/gunicorn-${name}"],
  }
}
