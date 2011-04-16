class python($ensure=present, $version=latest) {

  $python_package = $version ? {
    'latest' => "python",
    default => "python${version}",
  }

  package { $python_package:
    ensure => $ensure,
  }
}
