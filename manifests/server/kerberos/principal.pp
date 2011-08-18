define suiteds::server::kerberos::principal (
  $ensure         = $suiteds::config::ensure,
  $user           = $suiteds::config::admin_user,
  $krb_path       = $suiteds::config::krb_path,
  $exec_path      = $suiteds::config::exec_path
) {
  $root_user    = $suiteds::config::root_user
  $root_group   = $suiteds::config::root_group
  $domain       = inline_template( '<%= name.to_s.downcase.strip %>' )
  $realm        = inline_template( '<%= name.to_s.upcase %>' )
  $secret_file  = "${krb_path}/${domain}.secret"

  $exec_principal_add    = "cat '${secret_file}' '${secret_file}' | kadmin.local -q 'addprinc ${admin_user}@${realm}'"
  $exec_principal_exists = "test -n \"`kadmin.local -q 'getprinc ${user}@${realm}' | tail -n +3`\""
  $exec_secret_exists    = "test -f '${secret_file}'"

  Exec{
    path      => $exec_path,
    user      => $root_user,
    group     => $root_group,
    logoutput => 'on_failure',
  }
    
  case $ensure {
    'present': {
      exec{ "principal_add-${realm}":
        command => $exec_principal_add,
        unless  => $exec_principal_exists,
        onlyif  => $exec_secret_exists,
      }
    }
    'absent','purged': {
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
