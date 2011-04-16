class python($ensure=present, $version=latest) {

  $python = $version ? {
    'latest' => "python",
    default => "python${version}",
  }

  package { $python:
    ensure => $ensure,
  }
}
