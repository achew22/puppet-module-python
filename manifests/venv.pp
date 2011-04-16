class python::venv($ensure=present, $version=latest) {

  class { python::dev: version => $version }

  package { $python_dev_package:
    ensure => $ensure,
  }
}
