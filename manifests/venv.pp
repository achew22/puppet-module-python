class python::venv($ensure=present) {

  package { "python-virtualenv":
    ensure => $ensure,
  }
}
