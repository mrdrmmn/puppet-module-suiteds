define suiteds::server::kerberos::realm (
  $ensure         = $suiteds::config::ensure,
  $user           = $suiteds::config::root_user,
  $group          = $suiteds::config::root_group,
  $krb_path       = $suiteds::config::krb_path,
  $admin_user     = $suiteds::config::admin_user,
  $admin_password = $suiteds::config::admin_password,
  $exec_path      = $suiteds::config::exec_path
) {
  $ldap_map       = $suiteds::config::ldap_map
  $domain         = inline_template( '<%= name.to_s.downcase.strip %>' )
  $base_dn        = inline_template( '<%= domain.split( "." ).map{ |part| part = "dc=" + part }.join( "," ) %>' )
  $admin_ou       = inline_template( '<%= "ou=" + ldap_map.select{ |x| x.split( ":" ).at( 0 ).to_s.strip == "roles" }.at( 0 ).split( ":" ).at( 1 ).to_s.strip %>' )
  $krb_ou         = inline_template( '<%= "ou=" + ldap_map.select{ |x| x.split( ":" ).at( 0 ).to_s.strip == "kerberos" }.at( 0 ).split( ":" ).at( 1 ).to_s.strip %>' )
  $realm          = inline_template( '<%= name.to_s.upcase %>' )
  $krb_write_user = $suiteds::config::krb_write_user
  $krb_read_user  = $suiteds::config::krb_read_user
  $krb_write_dn   = "cn=${krb_write_user},${admin_ou},${base_dn}"
  $krb_read_dn    = "cn=${krb_read_user},${admin_ou},${base_dn}"
  $secret_file    = "${krb_path}/${domain}.secret"
  $keyfile        = "${krb_path}/${domain}.keyfile"

  $exec_krb_init    = "cat '${secret_file}' '${secret_file}' '${secret_file}' | kdb5_ldap_util -D '${krb_write_dn}' create -subtrees '${base_dn}' -r '${realm}' -s"
  $exec_krb_is_init = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b '${krb_ou},${base_dn}' '(krbPrincipalName=K/M@${realm})' dn`\""

  $exec_key_add_write = "cat '${secret_file}' '${secret_file}' '${secret_file}' | kdb5_ldap_util -D '${krb_write_dn}' stashsrvpw -f $keyfile '${krb_write_dn}'"
  $exec_key_add_read  = "cat '${secret_file}' '${secret_file}' '${secret_file}' | kdb5_ldap_util -D '${krb_write_dn}' stashsrvpw -f $keyfile '${krb_read_dn}'"
  $exec_key_exists    = "test -f ${keyfile}"

  File{
    owner => $user,
    group => $group,
    mode  => 0600,
  }
  Exec{
    path      => $exec_path,
    user      => $user,
    group     => $group,
    logoutput => 'on_failure',
  }
    
  case $ensure {
    'present': {
      $file_ensure = $ensure

      exec{ "krb_init-${realm}":
        command   => $exec_krb_init,
        unless    => $exec_krb_is_init,
        require   => File[ "${krb_path}/${domain}.acl", $secret_file ],
      }

      exec{ "key_add_write-${realm}":
        command     => $exec_key_add_write,
        unless      => $exec_key_exists,
        subscribe   => Exec[ "krb_init-${realm}" ],
        notify      => Exec[ "key_add_read-${realm}" ],
        refreshonly => 'true',
      }

      exec{ "key_add_read-${realm}":
        command     => $exec_key_add_read,
        refreshonly => 'true',
      }
    }
    'absent','purged': {
      $file_ensure = 'absent'
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }

  file{ "${krb_path}/${domain}.acl":
    ensure  => $file_ensure,
    content => template( 'suiteds/kerberos/server/kadm5.acl' ),
  }

  file{ $secret_file:
    ensure  => $file_ensure,
    content => inline_template( '<%= admin_password + "\n" %>' ),
  }
}
