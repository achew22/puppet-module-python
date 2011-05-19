define python::venv::isolate($ensure=present,
                             $version=latest,
                             $requirements=undef) {
  $root = $name
  $owner = $python::venv::owner
  $group = $python::venv::group

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

    # Does not successfully run as www-data on Debian:
    exec { "python::venv $root":
      command => "virtualenv -p `which ${python}` ${root}",
      creates => $root,
      require => [File[$root_parent],
                  Package["${python}-dev"]],
    }

    # Change ownership of the venv after its created with the default user:
    exec { "python::venv $root chown":
      command => "chown -R $owner:$group",
      require => Exec["python::venv $root"],
    }

    if $requirements {
      python::pip::requirements { $requirements:
        venv => $root,
        owner => $owner,
        group => $group,
        require => Exec["python::venv $root chown"],
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
