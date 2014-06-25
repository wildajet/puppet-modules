# == Define: account::groupdel
#
# A generic define to delete a group
#
# === Requirement/Dependencies:
#
# Currently doesn't require or depend on anything
#
# === Parameters
#
# Document parameters here
#
# [*name*]
#   The namevar of the defined resource type is the name of the group to be deleted
#
# === Examples
#
# account::groupdel { 'jwilda': }
#
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::groupdel {
  group { $name: ensure => absent, }

}

