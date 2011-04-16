class python::dev($ensure=present, $version=latest) {

  $python_dev_package = $version ? {
    'latest' => "python-dev",
    default => "python${version}-dev",
  }

  class { python: version => $version }

  package { $python_dev_package:
    ensure => $ensure,
  }
}
