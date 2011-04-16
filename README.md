Puppet Python Module with Virtualenv and Pip support
====================================================

Module for configuring Python with virtualenvs and installation
of packages inside them with pip.

This module support installing packages specified in a
`requirements.txt` file put inside a virtualenv and updates the
said packages when the file changes. This way you only have to
define your requirements one place: in the VCS of your
application. The means that the same requirements file can be
used for development and production.

If you have more stable requirements which can be installed
straight from PyPi you can also choose to provide them directly
in the Puppet manifest.

Tested on Debian GNU/Linux 6.0 Squeeze. Patches for other
operating systems welcome.

This module is used by my forthcoming Puppet Gunicorn Module
to serve Python WSGI applications.


TODO
----

* Installation of packages with pip from requirements file.
* Uninstallation of packages no longer provided in the
  requirements file.
* Virtualenv aware pip provider.


Installation
------------

Clone this repo to a virtualenv directory under your Puppet
modules directory:

    git clone git://github.com/uggedal/puppet-module-python.git python

If you don't have a Puppet Master you can create a manifest file
based on the notes below and run Puppet in stand-alone mode
providing the module directory you cloned this repo to:

    puppet apply --modulepath=modules test_python.pp


Usage
-----

To install Python with development dependencies simply import the
module:

    import python::dev

You can install a specific version of Python by importing the
module with this special syntax:

    class { "python::dev": version => "2.5" }

Note that classes in Puppet are singletons and not more than one
can be created even if you provide different paramters to them.
This means that the `python` class can only be used to install one
version. If you need more coexising versions you could create a new
class based on the current one prefixed with the actual version.

To install and configure virtualenv, import the module:

    import python::venv

Setting up a virtualenv is done with the `python::venv::isolate`
resource:

    python::venv::isolate { "/var/venv/mediaqueri.es" }

Note that you'll need to define a global search path for the `exec`
resource to make the `python::venv::isolate` resource function
properly. This should ideally be placed in `manifests/site.pp`:

    Exec {
      path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    }

If you have several version of Python installed you can specifiy
which interpreter you'd like the virtualenv to contain:

    python::venv::isolate { "/var/venv/mediaqueri.es":
      version => "2.5",
    }

You can also provide an owner and group which will be the owner
of the virtualenv files:

    python::venv::isolate { "/var/venv/mediaqueri.es":
      owner => "www-mgr",
      group => "www-mgr",
    }


Proposed implementation
-----------------------

There will be support for updating packages based on a requirements.txt
file put in the root of the virtualenv. This was Puppet only runs an update
when the file content changes, but it does not manage the contents.
Proposed implementation follows:

    file { "$name/requirements.txt":
      ensure => present,
      replace => false,
      content => "# Created by Puppet. It will not overwrite changes to this file",
    }

    exec { "update-requirements-for-$name":
      command => "$pip install -Ur requirements.txt",
      cwd => $name,
      refreshonly => true,
      subscribe => File["$name/requirements.txt"],
      require => File["$name/requirements.txt"],
    }

Alternatively you can install stable packages from PyPi without a
requirements file. Proposed implementation follows:

    python::pip::install { $requirements, $virtualenv }

    define python::pip::install($requirement, $virtualenv) {

      exec { "pip install $requirement":
        cwd => "$virtualenv/bin",
        unless => "pip freeze | grep $requirement",
      }
    }

This does not take versions into account. A pip package provider
which supports virtualenvs could be implemented.
