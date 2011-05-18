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

  if $is_present {
    python::pip::install {
      "$gunicorn_package in $venv":
        package => $gunicorn_package,
        ensure => $ensure,
        venv => $venv,
        require => Python::Venv::Isolate[$venv],
        before => File["/etc/init.d/gunicorn-${name}"];

      # for --name support in gunicorn:
      "setproctitle in $venv":
        package => "setproctitle",
        ensure => $ensure,
        venv => $venv,
        require => Python::Venv::Isolate[$venv],
        before => File["/etc/init.d/gunicorn-${name}"];
    }
  }

  file { "/etc/init.d/gunicorn-${name}":
    ensure => $ensure,
    content => template("python/gunicorn.init.erb"),
    mode => 744,
  }

  service { "gunicorn-${name}":
    ensure => $is_present,
    enable => $is_present,
    hasstatus => true,
    hasrestart => true,
    subscribe => $ensure ? {
      'present' => File["/etc/init.d/gunicorn-${name}"],
      default => undef,
    },
    require => $ensure ? {
      'present' => File["/etc/init.d/gunicorn-${name}"],
      default => undef,
    },
    before => $ensure ? {
      'absent' => File["/etc/init.d/gunicorn-${name}"],
      default => undef,
    },
  }
}
