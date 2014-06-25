# == Define: account::userdel
#
# A generic define to delete a local user
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
#   The username of the account to be deleted
#
# [*keephome*]
#   Whether or not to keep the home directory of the deleted user
#
# === Examples
#
# account::userdel { 'jwilda': }
#
# or using create_resources with data in YAML
#
#dusers:
#  user_name:
#    uname:
#                  'user_name'
#    keephome:
#                  true
# ----------
#  $dusers = hiera_hash('dusers', false)
#  if ($dusers) {
#    create_resources(account::userdel, $dusers)
#  }
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::userdel ($uname, $keephome = true) {
  # notify { "in account::userdel uname is ,${uname}, and keep home is ,${keephome},": }

  # remove the user and his home directory
  if ($keephome == false) {
    user { $uname:
      ensure     => absent,
      managehome => true,
    }
    # remove the user but keep his home directory
  } else {
    user { $uname: ensure => absent, }
  }

}

