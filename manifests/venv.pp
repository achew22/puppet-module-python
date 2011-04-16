class python::venv($ensure=present) {

  package { "python-virtualenv":
    ensure => $ensure,
  }
}

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
      command => "virtualenv -p `which ${python}` ${root}",
      user => $owner,
      group => $group,
      creates => $root,
      require => [File[$root_parent],
                  Package["${python}-dev"]],
    }

    if $requirements {

      file { $requirements:
        ensure => present,
        replace => false,
        owner => $owner,
        group => $group,
        content => "# Puppet will install packages listed here and update
# them if the file contents changes.",
      }

      $requirements_checksum = "$root/requirements.sha1sum"

      # We create a sha1 checksum of the requirements file so that
      # we can detect when it changes:
      exec { "create new checksum of $name requirements":
          command => "sha1sum $requirements > $requirements_checksum",
          unless => "sha1sum -c $requirements_checksum",
          require => File[$requirements],
        }

        exec { "update $name requirements":
          command => "$root/bin/pip install -Ur $requirements",
        cwd => $root,
        subscribe => Exec["create new checksum of $name requirements"],
        refreshonly => true,
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
