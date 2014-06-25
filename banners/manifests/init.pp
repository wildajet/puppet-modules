# == Class: banners
#
# This class creates 3 files: issue, issue.net, and motd
#  The issue.net is set to be the banner in sshd_config
#
# === Parameters
#
# N/A
#
# === Variables
#
# N/A
#
# === Examples
#
#  include banners
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
class banners {
  # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
  $myissue = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/${module_name}/issue")

  file { 'issue':
    path     => '/etc/issue',
    mode     => '0644',
    owner    => root,
    group    => root,
    checksum => md5,
    # First match for source wins.
    source   => $myissue
  }

  # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
  $myissuenet = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/${module_name}/issue.net")

  file { 'issue.net':
    path     => '/etc/issue.net',
    mode     => '0644',
    owner    => root,
    group    => root,
    checksum => md5,
    # First match for source wins.
    source   => $myissuenet
  }

  # notify { "hostname is ${::hostname}": }
  # Run figlet on the Puppet master with the hostname of the node
  $host_art = figlet_magic($::hostname)

  # notify { "host_art is ${host_art}": }

  file { 'motd':
    path     => '/etc/motd',
    mode     => '0644',
    owner    => root,
    group    => root,
    checksum => md5,
    content  => template("${module_name}/motd.erb")
  }

}
