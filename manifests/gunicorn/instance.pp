define python::gunicorn::instance($venv,
                                  $src,
                                  $ensure=present,
                                  $wsgi_module="",
                                  $django=false,
                                  $version=undef,
                                  $workers=1) {
  $is_present = $ensure == "present"

  $rundir = $python::gunicorn::rundir
  $owner = $python::gunicorn::owner
  $group = $python::gunicorn::group

  $pidfile = "$rundir/$name.pid"
  $socket = "unix:$rundir/$name.sock"

  if $wsgi_module == "" and !$django {
    fail("If you're not using Django you have to define a WSGI module.")
  }

  $gunicorn_package = $version ? {
    undef => "gunicorn",
    default => "gunicorn==${version}",
  }

  python::pip::install {
    $gunicorn_package:
      venv => $venv,
      require => Python::Venv::Isolate[$venv];

    # for --name support in gunicorn:
    "setproctitle":
      venv => $venv,
      require => Python::Venv::Isolate[$venv];
  }

  file { "/etc/init.d/gunicorn-${name}":
    ensure => $ensure,
    content => template("python/gunicorn.init.erb"),
    mode => 744,
    require => Python::Pip::Install[$gunicorn_package],
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
