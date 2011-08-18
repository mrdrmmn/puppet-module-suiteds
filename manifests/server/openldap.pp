define suiteds::server::openldap (
  $ensure                = $suiteds::config::ensure,
  $servers               = $suiteds::config::servers,
  $domains               = $suiteds::config::domains,
  $default_domain        = $suiteds::config::default_domain,
  $admin_user            = $suiteds::config::admin_user,
  $admin_password        = $suiteds::config::admin_password,
  $base_path             = $suiteds::config::base_path,
  $config_path           = $suiteds::config::config_path,
  $misc_path             = $suiteds::config::misc_path,
  $exec_path             = $suiteds::config::exec_path,
  $pam_min_uid           = $suiteds::config::pam_min_uid,
  $pam_max_uid           = $suiteds::config::pam_max_uid,
  $log_level             = $suiteds::config::log_level,

  $ldap_protocols        = $suiteds::config::ldap_protocols,
  $ldap_default_protocol = $suiteds::config::ldap_default_protocol,
  $ldap_version          = $suiteds::config::ldap_version,
  $ldap_port             = $suiteds::config::ldap_port,
  $ldaps_port            = $suiteds::config::ldaps_port,
  $bind_policy           = $suiteds::config::bind_policy,
  $search_timelimit      = $suiteds::config::search_timelimit,
  $bind_timelimit        = $suiteds::config::bind_timelimit,
  $idle_timelimit        = $suiteds::config::idle_timelimit,
  $sasl_minssf           = $suiteds::config::sasl_minssf,
  $sasl_maxssf           = $suiteds::config::sasl_maxssf,

  $ssl_mode              = $suiteds::config::ssl_mode,
  $ssl_minimum           = $suiteds::config::ssl_minimum,
  $ssl_verify_certs      = $suiteds::config::ssl_verify_certs,
  $ssl_cacert_file       = $suiteds::config::ssl_cacert_file,
  $ssl_cacert_path       = $suiteds::config::ssl_cacert_path,
  $ssl_cert_file         = $suiteds::config::ssl_cert_file,
  $ssl_key_file          = $suiteds::config::ssl_key_file,
  $ssl_cipher_suite      = $suiteds::config::ssl_cipher_suite
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Suiteds::Dummy[ 'suiteds::server::openldap' ] ) ) {
    fail( 'The "suiteds::server::openldap" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::server::openldap': }

  # Include our config.
  include suiteds::config

  # Make sure our paths are fully qualified.
  $temp_ldap_path = $suiteds::config::ldap_path
  case inline_template( '<%= temp_ldap_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $ldap_path = $temp_ldap_path                       }
    default: { $ldap_path = "${config_base_path}/$temp_ldap_path" }
  }
  $temp_ldap_pid_file = $suiteds::config::ldap_pid_file
  case inline_template( '<%= temp_ldap_pid_file.to_s.start_with?( "/" ) %>' ) {
    'true':  { $ldap_pid_file = $temp_ldap_pid_file               }
    default: { $ldap_pid_file = "${ldap_path}/${temp_ldap_pid_file}" }
  }

  $packages        = $suiteds::config::ldap_server_packages
  $services        = $suiteds::config::ldap_server_services
  $ldap_user       = $suiteds::config::ldap_user
  $ldap_group      = $suiteds::config::ldap_group
  $root_user       = $suiteds::config::root_user
  $root_group      = $suiteds::config::root_group
  $ldap_schemas    = $suiteds::config::ldap_schemas
  $db_mapping      = $suiteds::config::db_mapping
  $ldap_map        = $suiteds::config::ldap_map
  $krb_read_user   = $suiteds::config::krb_read_user
  $krb_write_user  = $suiteds::config::krb_write_user
  $ldap_admin_user = $suiteds::config::ldap_admin_user

  $ldap_srv_init_file = "${misc_path}/server-init.ldif"
  $ldap_srv_pop_file  = "${misc_path}/server-populate.ldif"
  $ldap_dir_init_file = "${misc_path}/directory-init.ldif"
  $ldap_dir_pop_file  = "${misc_path}/directory-populate.ldif"
  $configs = [
    $suiteds::config::ldap_server_configs,
    "present:absent:${ldap_user}:${ldap_group}:0600:server/server-init.ldif       :${ldap_srv_init_file}",
    "present:absent:${ldap_user}:${ldap_group}:0600:server/server-populate.ldif   :${ldap_srv_pop_file} ",
    "present:absent:${ldap_user}:${ldap_group}:0600:server/directory-init.ldif    :${ldap_dir_init_file}",
    "present:absent:${ldap_user}:${ldap_group}:0600:server/directory-populate.ldif:${ldap_dir_pop_file} ",
  ]
  $base_dn      = inline_template( '<%= domain.to_s.downcase.split( "." ).map{ |part| part = "dc=" + part }.join( "," ) %>' )

  $exec_kill_slapd       = 'killall slapd || true'
  $exec_ldap_srv_init    = "slapadd -F '${ldap_path}/config' -d1 -n 0 -l '${ldap_srv_init_file}' 2>&1"
  $exec_ldap_srv_is_init = "slapcat -F '${ldap_path}/config' -H ldap:///cn=schema,cn=config"

  $exec_ldap_srv_pop     = "slapadd -F '${ldap_path}/config' -d1 -n 0 -l '${ldap_srv_pop_file}' 2>&1"
  $exec_ldap_srv_is_pop  = "test -n \"`slapcat -F '${ldap_path}/config' -H ldap:///cn=schema,cn=config??one 2>/dev/null`\""

  $exec_ldap_dir_init    = "ldapadd -Y EXTERNAL -H ldapi:/// -d1 -f '${ldap_dir_init_file}' 2>&1"
  $exec_ldap_dir_is_init = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b cn=config '(&(objectClass=olcDatabaseConfig)(olcSuffix=*))' dn`\""
 
  $exec_ldap_dir_pop     = "ldapadd -Y EXTERNAL -H ldapi:/// -d1 -f '${ldap_dir_pop_file}' 2>&1"
  $exec_ldap_dir_is_pop  = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b '${base_dn}' '(ou=${base_dn})' dn`\""

  # Set up some resource defaults.
  Exec{
    user      => $root_user,
    group     => $root_group,
    path      => $exec_path,
    logoutput => 'on_failure',
  }

  directory{ $ldap_path:
    ensure  => $ensure,
    recurse => 'true',
    owner   => $ldap_user,
    group   => $ldap_group,
    mode    => 0700,
  }

  case $ensure {
    'present': {
      suiteds::server::mk_ldap_dir_paths{ [ 'config', $domains ]:
        ensure    => $ensure,
        user      => $ldap_user,
        group     => $ldap_group,
        mode      => 0700,
        base_path => $ldap_path,
        require   => Directory[ $ldap_path ],
      }
      package{ $packages:
        ensure  => $ensure,
        require => Suiteds::Server::Mk_ldap_dir_paths[ 'config', $domains ],
        notify  => Exec[ $exec_kill_slapd ],
      }
      suiteds::toggle{ $configs:
        ensure  => $ensure,
        require => Package[ $packages ],
        before  => Exec[ 'ldap-srv-init' ],
        notify  => Exec[ $exec_kill_slapd ],
      }

      exec{ $exec_kill_slapd:
        before      => Exec[ 'ldap-srv-init' ],
        refreshonly => 'true'
      }
      exec{ 'ldap-srv-init':
        user      => $ldap_user,
        group     => $ldap_group,
        command   => $exec_ldap_srv_init,
        require   => Package[ $packages ],
        before    => Exec[ 'ldap-srv-pop' ],
        unless    => $exec_ldap_srv_is_init,
      }
      exec{ 'ldap-srv-pop':
        user      => $ldap_user,
        group     => $ldap_group,
        command   => $exec_ldap_srv_pop,
        unless    => $exec_ldap_srv_is_pop,
        notify    => Service[ $services ],
      }

      service{ $services:
        ensure  => 'running',
        enable  => 'true',
      }

      exec{ 'ldap-dir-init':
        command     => $exec_ldap_dir_init,
        require     => Service[ $services ],
        unless      => $exec_ldap_dir_is_init,
      }
      exec{ 'ldap-dir-pop':
        command     => $exec_ldap_dir_pop,
        require     => Exec[ 'ldap-dir-init' ],
        unless      => $exec_ldap_dir_is_pop,
      }

    }
    'absent','purged': {
      package{ $packages:
        ensure  => $ensure,
        before  => Directory[ $ldap_path ],
      }
      exec{ 'killall slapd || true':
        before      => Service[ $services ],
      }
      service{ $services:
        ensure  => 'stopped',
        enable  => 'false',
        before  => Package[ $packages ],
      }
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
