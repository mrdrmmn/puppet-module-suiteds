# Define: suiteds::client
#
# This module manages suiteds::client
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define suiteds::client (
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
  if( defined( Suiteds::Dummy[ 'suiteds::client' ] ) ) {
    fail( 'The "suiteds::client" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::client': }

  # Include our config.
  include suiteds::config

  suiteds::client::openldap{ 'suiteds::client::openldap':
    ensure                => $ensure,
    servers               => $servers,
    domains               => $domains,
    default_domain        => $default_domain,
    admin_user            => $admin_user,
    admin_password        => $admin_password,
    base_path             => $base_path,
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
  }
  suiteds::client::kerberos{ 'suiteds::client::kerberos':
    ensure                => $ensure,
    servers               => $servers,
    domains               => $domains,
    default_domain        => $default_domain,
    krb5_port             => $krb5_port,
    krb5adm_port          => $krb5adm_port,
    krb4_port             => $config_krb4_port,
  }

  case $ensure {
    'present','installed': {
    }
    'absent','removed','purged': {
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }
}
