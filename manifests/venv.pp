class python::venv($ensure=present, $version=latest) {

  class { "python::dev": version => $version }

  package { "python-virtualenv":
    ensure => $ensure,
  }
}
