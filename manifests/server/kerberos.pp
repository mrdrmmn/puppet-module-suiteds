define suiteds::server::kerberos (
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
  $search_timelimit      = $suiteds::config::search_timelimit,
  $bind_timelimit        = $suiteds::config::bind_timelimit,
  $idle_timelimit        = $suiteds::config::idle_timelimit,

  $ssl_mode              = $suiteds::config::ssl_mode,
  $ssl_minimum           = $suiteds::config::ssl_minimum,
  $ssl_verify_certs      = $suiteds::config::ssl_verify_certs,

  $krb5_port             = $suiteds::config::krb5_port,
  $krb5adm_port          = $suiteds::config::krb5adm_port,
  $krb4_port             = $suiteds::config::krb4_port
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Suiteds::Dummy[ 'suiteds::server::kerberos' ] ) ) {
    fail( 'The "suiteds::server::kerberos" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::server::kerberos': }

  # Make sure our paths are fully qualified.
  $temp_krb_path = $suiteds::config::krb_path
  case inline_template( '<%= temp_krb_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $krb_path = $temp_krb_path                       }
    default: { $krb_path = "${base_path}/$temp_krb_path" }
  }

  # Include our config.
  include suiteds::config

  $packages       = $suiteds::config::krb_server_packages
  $services       = $suiteds::config::krb_server_services
  $configs        = $suiteds::config::krb_server_configs
  $root_user      = $suiteds::config::root_user
  $root_group     = $suiteds::config::root_group
  $ldap_map       = $suiteds::config::ldap_map
  $krb_read_user  = $suiteds::config::krb_read_user
  $krb_write_user = $suiteds::config::krb_write_user

  directory{ $krb_path:
    ensure  => $ensure,
    recurse => 'true',
    owner   => $root_user,
    group   => $root_group,
    mode    => 0700,
  }

  package{ $packages:
    ensure  => $ensure,
    require => Directory[ $krb_path ],
  }

  suiteds::toggle{ $configs:
    ensure  => $ensure,
    require => Package[ $packages ],
    before  => Suiteds::Server::Kerberos::Realm[ $domains ],
  }

  suiteds::server::kerberos::realm{ $domains:
    ensure         => $ensure,
    user           => $root_user,
    group          => $root_group,
    krb_path       => $krb_path,
    admin_password => $admin_password,
    exec_path      => $exec_path
  }

  suiteds::server::kerberos::principal{ $domains:
    ensure    => $ensure,
    user      => $admin_user,
    krb_path  => $krb_path,
    exec_path => $exec_path,
  }


  case $ensure {
    'present': {
      service{ $services:
        ensure  => 'running',
        enable  => 'true',
        require => Suiteds::Server::Kerberos::Realm[ $domains ],
        before  => Suiteds::Server::Kerberos::Principal[ $domains ],
      }
    }
    'absent','purged': {
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
