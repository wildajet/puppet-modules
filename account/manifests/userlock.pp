# == Define: account::userlock
#
# A generic define to lock a local user
#
# === Requirement/Dependencies:
#
# Currently doesn't require or depend on anything
#
# === Parameters
#
# Document parameters here
#
# [*uname*]
#   The username of the account to be locked
#
# === Examples
#
# account::userlock { 'wildajet': }
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::userlock ($uname) {
  exec { "/usr/bin/passwd -l ${uname}":
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ["/usr/bin/id ${uname}", "/usr/bin/passwd -S ${uname} | grep PS"],
    command => "/usr/bin/passwd -l ${uname}",
  }

  # change the shell to be a nologin shell
  # exec { "/usr/bin/chsh -s /sbin/nologin ${uname}":
  #  path => '/usr/bin:/usr/sbin:/bin',
  #  unless => "grep ${uname} /etc/passwd | cut -f 7 -d : | grep nologin",
  #  command => "/usr/bin/chsh -s /sbin/nologin ${uname}",
  #}
}
