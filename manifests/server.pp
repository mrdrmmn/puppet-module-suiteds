define suiteds::server (
  $ensure                = $suiteds::config::ensure,
  $servers               = $suiteds::config::servers,
  $domains               = $suiteds::config::domains,
  $default_domain        = $suiteds::config::default_domain,
  $admin_user            = $suiteds::config::admin_user,
  $admin_password        = $suiteds::config::admin_password,
  $base_path             = $suiteds::config::base_path,
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
  $ssl_cipher_suite      = $suiteds::config::ssl_cipher_suite,
  $ssl_cert_country      = $suiteds::config::ssl_cert_country,
  $ssl_cert_state        = $suiteds::config::ssl_cert_state,
  $ssl_cert_city         = $suiteds::config::ssl_cert_city,
  $ssl_cert_organization = $suiteds::config::ssl_cert_organization,
  $ssl_cert_department   = $suiteds::config::ssl_cert_department,
  $ssl_cert_domain       = $suiteds::config::ssl_cert_domain,
  $ssl_cert_email        = $suiteds::config::ssl_cert_email,

  $krb5_port             = $suiteds::config::krb5_port,
  $krb5adm_port          = $suiteds::config::krb5adm_port,
  $krb4_port             = $suiteds::config::krb4_port
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Suiteds::Dummy[ 'suiteds::server' ] ) ) {
    fail( 'The "suiteds::server" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::server': }

  # Include our config.
  include suiteds::config

  # Make sure our paths are fully qualified.
  $temp_config_path = $suiteds::config::config_path
  case inline_template( '<%= temp_config_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_path = $temp_config_path                       }
    default: { $config_path = "${base_path}/${temp_config_path}" }
  }
  $temp_misc_path = $suiteds::config::misc_path
  case inline_template( '<%= temp_misc_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $misc_path = $temp_misc_path                       }
    default: { $misc_path = "${base_path}/$temp_misc_path" }
  }

  $paths          = [ $base_path, $config_path, $misc_path ]
  $root_user      = $suiteds::config::root_user
  $root_group     = $suiteds::config::root_group

  suiteds::certificate{ 'suiteds::server':
    ensure       => $ensure,
    owner        => $suiteds::config::ldap_user,
    group        => $suiteds::config::ldap_group,
    cert_file    => $ssl_cert_file,
    key_file     => $ssl_key_file,
    country      => $ssl_cert_country,
    state        => $ssl_cert_state,
    city         => $ssl_cert_city,
    organization => $ssl_cert_organization,
    department   => $ssl_cert_department,
    domain       => $ssl_cert_domain,
    email        => $ssl_cert_email,
    exec_path    => $exec_path,
    require      => Directory[ $paths ],
  }

  suiteds::server::openldap{ 'suiteds::server::openldap':
    ensure                => $ensure,
    servers               => $servers,
    domains               => $domains,
    default_domain        => $default_domain,
    admin_user            => $admin_user,
    admin_password        => $admin_password,
    base_path             => $base_path,
    config_path           => $config_path,
    misc_path             => $misc_path,
    exec_path             => $exec_path,
    pam_min_uid           => $pam_min_uid,
    pam_max_uid           => $pam_max_uid,
    log_level             => $log_level,

    ldap_protocols        => $ldap_protocols,
    ldap_default_protocol => $ldap_default_protocol,
    ldap_version          => $ldap_version,
    ldap_port             => $ldap_port,
    ldaps_port            => $ldaps_port,
    bind_policy           => $bind_policy,
    search_timelimit      => $search_timelimit,
    bind_timelimit        => $bind_timelimit,
    idle_timelimit        => $idle_timelimit,
    sasl_minssf           => $sasl_minssf,
    sasl_maxssf           => $sasl_maxssf,

    ssl_mode              => $ssl_mode,
    ssl_minimum           => $ssl_minimum,
    ssl_verify_certs      => $ssl_verify_certs,
    ssl_cacert_file       => $ssl_cacert_file,
    ssl_cacert_path       => $ssl_cacert_path,
    ssl_cert_file         => $ssl_cert_file,
    ssl_key_file          => $ssl_key_file,
    ssl_cipher_suite      => $ssl_cipher_suite,
    require               => Suiteds::Certificate[ 'suiteds::server' ],
  }

  suiteds::server::kerberos{ 'suiteds::server::kerberos':
    ensure                => $ensure,
    servers               => $servers,
    domains               => $domains,
    default_domain        => $default_domain,
    admin_user            => $admin_user,
    admin_password        => $admin_password,
    base_path             => $base_path,
    config_path           => $config_path,
    misc_path             => $misc_path,
    exec_path             => $exec_path,
    pam_min_uid           => $pam_min_uid,
    pam_max_uid           => $pam_max_uid,
    log_level             => $log_level,

    ldap_protocols        => $ldap_protocols,
    ldap_default_protocol => $ldap_default_protocol,
    ldap_version          => $ldap_version,
    ldap_port             => $ldap_port,
    ldaps_port            => $ldaps_port,
    search_timelimit      => $search_timelimit,
    bind_timelimit        => $bind_timelimit,
    idle_timelimit        => $idle_timelimit,

    ssl_mode              => $ssl_mode,
    ssl_minimum           => $ssl_minimum,
    ssl_verify_certs      => $ssl_verify_certs,
    krb5_port             => $krb5_port,
    krb5adm_port          => $krb5adm_port,
    krb4_port             => $krb4_port,
    require               => Suiteds::Server::Openldap[ 'suiteds::server::openldap' ],
  }

  suiteds::server::freeradius{ 'suiteds::server::freeradius':
    ensure  => $ensure,
    servers               => $servers,
    domains               => $domains,
    default_domain        => $default_domain,
    admin_user            => $admin_user,
    admin_password        => $admin_password,
    base_path             => $base_path,
    config_path           => $config_path,
    misc_path             => $misc_path,
    exec_path             => $exec_path,
    pam_min_uid           => $pam_min_uid,
    pam_max_uid           => $pam_max_uid,
    log_level             => $log_level,
    require => Suiteds::Server::Kerberos[ 'suiteds::server::kerberos' ],
  }

  directory{ $paths:
    ensure  => $ensure,
    mode    => '0755',
    recurse => 'true',
    inherit => 'false',
    owner   => $root_user,
    group   => $root_group,
  }
}
