define python::pip::install($venv, $ensure=present) {

  # Match against whole line if we provide a given version:
  $grep_regex = $name ? {
    /==/ => "^${name}\$",
    default => "^${name}==",
  }

  exec { "pip install $name in $venv":
    command => "$venv/bin/pip install $name",
    unless => "$venv/bin/pip freeze | grep -e $grep_regex"
  }
}
