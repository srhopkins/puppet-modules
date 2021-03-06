# == Class: graphite_centos7
#
# Full description of class graphite_centos7 here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the function of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'graphite_centos7':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#

class graphite inherits graphite::params {

  package { "epel-release": ensure => "installed", }

  $packages = $graphite::params::packages
  package { $packages:
    ensure  => "installed",
    require => Package["epel-release"],
  }
  
  # Issue with not finding pip command.
  # https://github.com/evenup/evenup-curator/issues/24
  file { '/usr/bin/pip-python':
    ensure  => 'link',
    target  => '/usr/bin/pip',
    replace => false,
    require => Package[$packages],
  }

  $pip_packages = $graphite::params::pip_packages
  package { $pip_packages:
    ensure   => "installed",
    provider => "pip",
    require  => Package[$packages],
  }
  
  file { "/etc/httpd/conf.d/graphite.conf":
    source  => "puppet:///modules/graphite/example-graphite-vhost.conf",
    require => Package[$pip_packages],
  }

  file { "/opt/graphite/conf":
    source  => "puppet:///modules/graphite/conf",
    recurse => true,
    require => Package[$pip_packages],
  }

  file { "/opt/graphite/storage/":
    ensure  => directory,
    recurse => true,
    owner   => "apache",
    group   => "apache",
    mode    => 0755,
    require => Package[$pip_packages],
  }

}
