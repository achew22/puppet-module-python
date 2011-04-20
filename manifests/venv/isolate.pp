define python::venv::isolate($ensure=present,
                             $version=latest,
                             $owner=undef,
                             $group=undef,
                             $requirements=undef) {
  $root = $name

  if $ensure == 'present' {
    # Parent directory of root directory. /var/www for /var/www/blog
    $root_parent = inline_template("<%= root.match(%r!(.+)/.+!)[1] %>")

    if !defined(File[$root_parent]) {
      file { $root_parent:
        ensure => directory,
        owner => $owner,
        group => $group,
      }
    }

    $python = $version ? {
      'latest' => "python",
      default => "python${version}",
    }

    exec { "python::venv $root":
      # TODO: does not work when executed from puppet:
      command => "virtualenv -p `which ${python}` ${root}",
      user => $owner,
      group => $group,
      creates => $root,
      require => [File[$root_parent],
                  Package["${python}-dev"]],
    }

    if $requirements {
      python::pip::requirements { $requirements:
        venv => $root,
        owner => $owner,
        group => $group,
      }
    }

  } elsif $ensure == 'absent' {

    file { $root:
      ensure => $ensure,
      owner => $owner,
      group => $group,
      recurse => true,
      purge => true,
      force => true,
    }
  }
}
