define suiteds::server::freeradius (
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
  if( defined( Suiteds::Dummy[ 'suiteds::server::freeradius' ] ) ) {
    fail( 'The "suiteds::server::freeradius" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::server::freeradius': }

  # Include our config.
  include suiteds::config

  $packages        = $suiteds::config::radius_server_packages
  $services        = $suiteds::config::radius_server_services
  $configs         = $suiteds::config::radius_server_configs
  $root_user       = $suiteds::config::root_user
  $root_group      = $suiteds::config::root_group
  $radius_user     = $suiteds::config::radius_user
  $radius_group    = $suiteds::config::radius_group
  $ldap_map        = $suiteds::config::ldap_map
  $ldap_admin_user = $suiteds::config::ldap_admin_user
  $ldap_bind_user  = $suiteds::config::ldap_bind_user
  $ldap_roles      = $suiteds::config::ldap_roles

  # Make sure our paths are fully qualified.
  $temp_radius_path = $suiteds::config::radius_path
  case inline_template( '<%= temp_radius_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $radius_path = $temp_radius_path                       }
    default: { $radius_path = "${base_path}/$temp_radius_path" }
  }

  directory{ $radius_path:
    ensure  => $ensure,
    recurse => 'true',
    owner   => $radius_user,
    group   => $radius_group,
    mode    => 0700,
    before  => Package[ $packages ],
  }

  package{ $packages:
    ensure  => $ensure,
  }

  suiteds::toggle{ $configs:
    ensure  => $ensure,
    path    => $radius_path,
    require => Package[ $packages ],
  }

  suiteds::server::freeradius::site{ $domains:
    ensure   => $ensure,
    path     => $radius_path,
    template => 'suiteds/freeradius/server/site',
    suffix   => 'site',
    owner    => $radius_user,
    group    => $radius_group,
    mode     => 0600,
    require => Package[ $packages ],
  }

  case $ensure {
    'present': {
      #service{ $services:
      #  ensure  => 'running',
      #  enable  => 'true',
      #  require => Package[ $packages ]
      #}
    }
    'absent','purged': {
      #service{ $services:
      #  ensure  => 'stopped',
      #  enable  => 'false',
      #  require => Package[ $packages ],
      #}
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
