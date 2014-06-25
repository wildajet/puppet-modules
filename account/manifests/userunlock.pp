# == Define: account::userunlock
#
# A generic define to unlock a local user
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
#   The username of the account to be unlocked
#
# === Examples
#
# account::userunlock { 'wildajet': }
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::userunlock ($uname) {
  exec { "/usr/bin/passwd -u ${uname}":
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ["/usr/bin/id ${uname}", "/usr/bin/passwd -S ${uname} | grep LK"],
    command => "/usr/bin/passwd -u ${uname}",
  }

  # change the shell to be a nologin shell
  # exec { "/usr/bin/chsh -s /sbin/nologin ${uname}":
  #  path => '/usr/bin:/usr/sbin:/bin',
  #  unless => "grep ${uname} /etc/passwd | cut -f 7 -d : | grep nologin",
  #  command => "/usr/bin/chsh -s /sbin/nologin ${uname}",
  #}
}
