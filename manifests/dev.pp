class python::dev($ensure=present, $version=latest) {

  $python = $version ? {
    'latest' => "python",
    default => "python${version}",
  }

  package { "${python}-dev":
    ensure => $ensure,
    require => Package[$python],
  }
}
