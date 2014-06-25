# == Define: account::groupadd
#
# A generic define to add a group
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
#   The namevar of the defined resource type is the name of the group to be added
#
# [*gid*]
#   Is the GID of the users main group
#
# === Examples
#
# Store the Data in YAML:
#
# groups:
#  wildajet:
#    gid:
#                  '327'
#
# Then use create_resources to create:
#
# $groups = hiera_hash ('groups', false)
# if ( $groups ) {
#  create_resources( account::groupadd, $groups)
#}
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::groupadd ($gid, $ensure = present) {
  group { $name:
    ensure    => $ensure,
    gid       => $gid,
    allowdupe => false,
  }
}
