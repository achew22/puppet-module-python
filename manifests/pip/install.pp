define python::pip::install($package, $venv, $ensure=present) {

  # Match against whole line if we provide a given version:
  $grep_regex = $package ? {
    /==/ => "^${package}\$",
    default => "^${package}==",
  }

  exec { "pip install $name":
    command => "$venv/bin/pip install $package",
    unless => "$venv/bin/pip freeze | grep -e $grep_regex"
  }
}
