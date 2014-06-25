# == Define: account::useradd
#
# A generic define to add a user account
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
#   The namevar of the defined resource type is the name of the user or username
#
# [*uid*]
#   Is the UID of the username
#
# [*gid*]
#   Is the GID of the users main group
#
# [*home*]
#   The full path of the home directory defaults to /home/$name
#
# [*comment*]
#   The comment field in /etc/passwd usually the users email address
#
# [*shell*]
#   The users login shell usually /bin/bash
#
# [*groups*]
#   An array of supplementary groups which the user is also a member
#
# [*passwd_min*]
#   Set the minimum number of days between password changes to MIN_DAYS.
#   A value of zero for this field indicates that the user may change his/her password at any time
#
# [*passwd_max*]
#   Set the maximum number of days during which a password is valid.
#   When MAX_DAYS plus LAST_DAY is less than the current day,
#   the user will be required to change his/her password before being able to use his/her account.
#
# [*passwd*]
#   The encrypted password hash
#
# [*local*]
#   If this is a local account that we create
#   or it is a remote authenticated account that we only create the files for.
#
# [*managed*]
#   Is the home directory managed.  Files controlled by puppet
#   or just initially created and the user manages.  Files would only be created if they were removed.
#
# [*rsaprivkey*]
#   The private RSA SSH key
#
# [*rsaprivkey*]
#   The public RSA SSH key
#
# [*dsaprivkey*]
#   The private DSA SSH key
#
# [*dsapubkey*]
#   The public DSA SSH key
#
# === Examples
#
# Store the Data in YAML:
#
# users:
#  jwilda:
#    uid:
#                  '327'
#    gid:
#                  '327'
#    groups:
#                  - 'admin'
#    comment:
#                  'jet.wilda@gmail.com'
#    shell:
#                  '/bin/bash'
#    passwd:
#                  'PASSWORD_HASH'
#    local:
#                  true
#
# Then use create_resources to create:
#
# $users = hiera_hash ('users', false)
# if ( $users ) {
#  create_resources( account::useradd, $users)
#}
#
# === Authors
#
# Jet Wilda <jet.wilda@gmail.com>
#
define account::useradd (
  $uid,
  $gid        = '',
  $home       = '',
  $comment    = '',
  $shell      = '',
  $groups     = [],
  $passwd_min = 0,
  $passwd_max = 60,
  $passwd     = '',
  $local      = false,
  $managed    = false,
  $rsaprivkey = '',
  $rsapubkey  = '',
  $dsaprivkey = '',
  $dsapubkey  = '') {
  if ($home == '') {
    $r_home = "/home/${name}"
  } else {
    $r_home = $home
  }

  if ($gid == '') {
    $r_gid = $uid
  } else {
    $r_gid = $gid
  }

  if ($managed == true) {
    $myreplace = true
  } else {
    $myreplace = false
  }

  file { $r_home:
    ensure   => directory,
    path     => $r_home,
    owner    => $uid,
    group    => $r_gid,
    checksum => md5,
    mode     => '0700',
  }

  file { "${r_home}/.ssh":
    ensure   => directory,
    path     => "${r_home}/.ssh",
    owner    => $uid,
    group    => $r_gid,
    checksum => md5,
    mode     => '0700',
    require  => File[$r_home],
  }

  # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
  $myauthorized_keys_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.ssh/authorized_keys")
  # Create and arrry with the default item
  $mydefaultauthorized_keys = ['puppet:///hierafiles/users/default/.ssh/authorized_keys',]
  # Use an inline template to combine the 2 arrarys
  $myauthorized_keys = split(inline_template('<%= (@myauthorized_keys_tmp + @mydefaultauthorized_keys).join(",") %>'), ',')

  # notify { "myauthorized_keys is ${myauthorized_keys}": }

  file { "${r_home}/.ssh/authorized_keys":
    ensure   => present,
    path     => "${r_home}/.ssh/authorized_keys",
    replace  => $myreplace,
    mode     => '0600',
    owner    => $uid,
    group    => $r_gid,
    checksum => md5,
    require  => File["${r_home}/.ssh"],
    # First match for source wins.
    source   => $myauthorized_keys,
  }

  file { "${r_home}/.ssh/authorized_keys2":
    ensure  => link,
    owner   => $uid,
    group   => $r_gid,
    target  => "${r_home}/.ssh/authorized_keys",
    require => User[$name],
  }

  # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
  $mysshconfig_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.ssh/config")
  # Create and arrry with the default item
  $mydefaultsshconfig = ['puppet:///hierafiles/users/default/.ssh/config',]
  # Use an inline template to combine the 2 arrarys
  $mysshconfig = split(inline_template('<%= (@mysshconfig_tmp + @mydefaultsshconfig).join(",") %>'), ',')

  file { "${r_home}/.ssh/config":
    ensure   => present,
    path     => "${r_home}/.ssh/config",
    replace  => $myreplace,
    mode     => '0644',
    owner    => $uid,
    group    => $r_gid,
    checksum => md5,
    require  => File["${r_home}/.ssh"],
    # First match for source wins.
    source   => $mysshconfig,
  }

  if ($rsapubkey != '') {
    file { "${r_home}/.ssh/id_rsa.pub":
      ensure   => present,
      path     => "${r_home}/.ssh/id_rsa.pub",
      replace  => $myreplace,
      mode     => '0600',
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      require  => File["${r_home}/.ssh"],
      content  => template("${module_name}/id_rsa.pub.erb"),
    }
  }

  if ($rsaprivkey != '') {
    file { "${r_home}/.ssh/id_rsa":
      ensure   => present,
      path     => "${r_home}/.ssh/id_rsa",
      replace  => $myreplace,
      mode     => '0600',
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      require  => File["${r_home}/.ssh"],
      content  => template("${module_name}/id_rsa.erb"),
    }
  }

  if ($dsapubkey != '') {
    file { "${r_home}/.ssh/id_dsa.pub":
      ensure   => present,
      path     => "${r_home}/.ssh/id_dsa.pub",
      replace  => $myreplace,
      mode     => '0600',
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      require  => File["${r_home}/.ssh"],
      content  => template("${module_name}/id_dsa.pub.erb"),
    }
  }

  if ($dsaprivkey != '') {
    file { "${r_home}/.ssh/id_dsa":
      ensure   => present,
      path     => "${r_home}/.ssh/id_dsa",
      replace  => $myreplace,
      mode     => '0600',
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      require  => File["${r_home}/.ssh"],
      content  => template("${module_name}/id_dsa.erb"),
    }
  }

  if ($shell == '/bin/tcsh') {
    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mytcshrc_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.tcshrc")
    # Create and arrry with the default item
    $mydefaulttcshrc = ['puppet:///hierafiles/users/default/.tcshrc',]
    # Use an inline template to combine the 2 arrarys
    $mytcshrc = split(inline_template('<%= (@mytcshrc_tmp + @mydefaulttcshrc).join(",") %>'), ',')

    file { "${r_home}/.tcshrc":
      ensure   => present,
      path     => "${r_home}/.tcshrc",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      mode     => '0644',
      require  => File[$r_home],
      # First match for source wins.
      source   => $mytcshrc,
    }

    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mycshrc_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.cshrc")
    # Create and arrry with the default item
    $mydefaultcshrc = ['puppet:///hierafiles/users/default/.cshrc',]
    # Use an inline template to combine the 2 arrarys
    $mycshrc = split(inline_template('<%= (@mycshrc_tmp + @mydefaultcshrc).join(",") %>'), ',')

    file { "${r_home}/.cshrc":
      ensure   => present,
      path     => "${r_home}/.cshrc",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      mode     => '0644',
      require  => File[$r_home],
      # First match for source wins.
      source   => $mycshrc,
    }

    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mylogin_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.login")
    # Create and arrry with the default item
    $mydefaultlogin = ['puppet:///hierafiles/users/default/.login',]
    # Use an inline template to combine the 2 arrarys
    $mylogin = split(inline_template('<%= (@mylogin_tmp + @mydefaultlogin).join(",") %>'), ',')

    file { "${r_home}/.login":
      ensure   => present,
      path     => "${r_home}/.login",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      mode     => '0644',
      require  => File[$r_home],
      # First match for source wins.
      source   => $mylogin,
    }

    # everything else we assume bash
  } else {
    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mybashrc_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.bashrc")
    # Create and arrry with the default item
    $mydefaultbashrc = ['puppet:///hierafiles/users/default/.bashrc',]
    # Use an inline template to combine the 2 arrarys
    $mybashrc = split(inline_template('<%= (@mybashrc_tmp + @mydefaultbashrc).join(",") %>'), ',')

    file { "${r_home}/.bashrc":
      ensure   => present,
      path     => "${r_home}/.bashrc",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      mode     => '0640',
      require  => File[$r_home],
      # First match for source wins.
      source   => $mybashrc,
    }

    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mybash_profile_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.bash_profile")
    # Create and arrry with the default item
    $mydefaultbash_profile = ['puppet:///hierafiles/users/default/.bash_profile',]
    # Use an inline template to combine the 2 arrarys
    $mybash_profile = split(inline_template('<%= (@mybash_profile_tmp + @mydefaultbash_profile).join(",") %>'), ',')

    file { "${r_home}/.bash_profile":
      ensure   => present,
      path     => "${r_home}/.bash_profile",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      checksum => md5,
      mode     => '0640',
      require  => File[$r_home],
      # First match for source wins.
      source   => $mybash_profile,
    }

    # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
    $mybash_aliases_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/.bash_aliases")
    # Create and arrry with the default item
    $mydefaultbash_aliases = ['puppet:///hierafiles/users/default/.bash_aliases',]
    # Use an inline template to combine the 2 arrarys
    $mybash_aliases = split(inline_template('<%= (@mybash_aliases_tmp + @mydefaultbash_aliases).join(",") %>'), ',')

    file { "${r_home}/.bash_aliases":
      ensure   => present,
      path     => "${r_home}/.bash_aliases",
      replace  => $myreplace,
      owner    => $uid,
      group    => $r_gid,
      mode     => '0640',
      checksum => md5,
      require  => File[$r_home],
      # First match for source wins.
      source   => $mybash_aliases,
    }

  }

  # Pull the Hiera lookup search order array 'sourcelookup' and add the path to the front of each item
  $myhomebin_tmp = prefix(hiera_array('sourcelookup'), "puppet:///hierafiles/users/${name}/bin")
  # Create and arrry with the default item
  $mydefaulthomebin = ['puppet:///hierafiles/users/default/bin',]
  # Use an inline template to combine the 2 arrarys
  $myhomebin = split(inline_template('<%= (@myhomebin_tmp + @mydefaulthomebin).join(",") %>'), ',')

  file { "${r_home}/bin":
    ensure   => directory,
    path     => "${r_home}/bin",
    replace  => $myreplace,
    recurse  => true,
    owner    => $uid,
    group    => $r_gid,
    checksum => md5,
    # mode     => 755,
    # First match for source wins.
    source   => $myhomebin,
  }

  if ($local == true) {
    if ($passwd != '') {
      user { $name:
        ensure           => present,
        home             => $r_home,
        managehome       => true,
        uid              => $uid,
        gid              => $r_gid,
        groups           => $groups,
        comment          => $comment,
        shell            => $shell,
        allowdupe        => false,
        password_min_age => $passwd_min,
        password_max_age => $passwd_max,
        notify           => Exec["passwd_set_${name}"]
      }
    } else {
      user { $name:
        ensure           => present,
        home             => $r_home,
        managehome       => true,
        uid              => $uid,
        gid              => $r_gid,
        groups           => $groups,
        comment          => $comment,
        shell            => $shell,
        allowdupe        => false,
        password_min_age => $passwd_min,
        password_max_age => $passwd_max,
      }
    }

    exec { "passwd_set_${name}":
      path        => '/usr/bin:/usr/sbin:/bin',
      refreshonly => true,
      require     => User[$name],
      command     => "usermod -p '${passwd}' ${name}",
    }
  }
}
