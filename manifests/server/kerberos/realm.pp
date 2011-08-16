define suiteds::server::kerberos::realm (
  $ensure         = $suiteds::config::ensure,
  $user           = $suiteds::config::root_user,
  $group          = $suiteds::config::root_group,
  $krb_ldap_write = $suiteds::config::krb_ldap_write,
  $krb_ldap_read  = $suiteds::config::krb_ldap_read,
  $krb_path       = $suiteds::config::krb_path,
  $admin_password = $suiteds::config::admin_password,
  $exec_path      = $suiteds::config::exec_path
) {

  $temp_krb_path = $suiteds::config::krb_path
  case inline_template( '<%= temp_krb_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $krb_path = $temp_krb_path                }
    default: { $krb_path = "${base_path}/$temp_krb_path" }
  }

  $db_mapping   = $suiteds::config::db_mapping
  $domain       = inline_template( '<%= name.to_s.downcase.strip %>' )
  $base_dn      = inline_template( '<%= domain.split( "." ).map{ |part| part = "dc=" + part }.join( "," ) %>' )
  $admin_ou     = inline_template( '<%= "ou=" + db_mapping.select{ |x| x.split( ":" ).at( 0 ).to_s.strip == "admin" }.at( 0 ).split( ":" ).at( 4 ).to_s.strip %>' )
  $krb_ou       = inline_template( '<%= "ou=" + db_mapping.select{ |x| x.split( ":" ).at( 0 ).to_s.strip == "kerberos" }.at( 0 ).split( ":" ).at( 4 ).to_s.strip %>' )
  $realm        = inline_template( '<%= name.to_s.upcase %>' )
  $krb_write_dn = "cn=${krb_ldap_write},${admin_ou},${base_dn}"
  $secret_file  = "${krb_path}/${domain}.secret"
  $secret       = inline_template( '<%= Array.new( 64 ){ rand( 256 ).chr }.join.unpack( "H*" ).join%>' )

  $exec_krb_init    = "cat '${secret_file}' | kdb5_ldap_util -D '${krb_write_dn}' create -subtrees '${base_dn}' -r '${realm}' -s"
  $exec_krb_is_init = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b '${krb_ou},${base_dn}' '(krbPrincipalName=K/M@${realm})' dn`\""

  File{
    owner => $user,
    group => $group,
    mode  => 0600,
  }
    
  case $ensure {
    'present': {
      $file_ensure = $ensure

      exec{ "krb_init-${realm}":
        command   => $exec_krb_init,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        logoutput => 'on_failure',
        unless    => $exec_krb_is_init,
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
    content => template( 'suiteds/server/kadm5.acl' ),
    before  => Exec[ "krb_init-${realm}" ],
  }

  file{ $secret_file:
    ensure  => $file_ensure,
    content => inline_template( '<%= admin_password + "\n" + secret + "\n" + secret %>' ),
    before  => Exec[ "krb_init-${realm}" ],
  }
}
