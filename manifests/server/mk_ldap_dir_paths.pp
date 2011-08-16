define suiteds::server::mk_ldap_dir_paths (
  $ensure         = $suiteds::config::ensure,
  $user           = $suiteds::config::ldap_user,
  $group          = $suiteds::config::ldap_group,
  $mode           = 0700,
  $base_path      = $suiteds::config::ldap_path
) {
  directory{ "${base_path}/${name}":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    recurse => 'true',
  }
}

