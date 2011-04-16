Puppet Python Module with Virtualenv and Pip support
====================================================

Module for configuring Python with virtualenvs and installation
of packages inside them with pip.

This module support installing packages specified in a
`requirements.txt` file and update said packages when the file
changes. This way you only have to define your requirements in
one place: in the VCS for your application code.

Tested on Debian GNU/Linux 6.0 Squeeze. Patches for other
operating systems welcome.

This module is used by my forthcoming Puppet Gunicorn Module
to serve Python WSGI applications.


TODO
----

* Uninstallation of packages no longer provided in the
  requirements file.


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

If you point to a [pip requirements file][requirements.txt] Puppet will
install the specified packages and upgrade them when the file changes:

    python::venv::isolate { "/var/venv/mediaqueri.es":
      requirements => "/var/www/mediaqueri.es/requirements.txt",
    }


[requirements.txt]: http://www.pip-installer.org/en/latest/requirement-format.html
