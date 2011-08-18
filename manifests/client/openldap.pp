# Define: suiteds::client::openldap
#
# This module manages suitds::client::openldap
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
define suiteds::client::openldap (
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
  $ssl_key_file          = $suiteds::config::ssl_key_file
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Suiteds::Dummy[ 'suiteds::client::openldap' ] ) ) {
    fail( 'The "suiteds::client::openldap" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::client::openldap': }

  # Include our config.
  include suiteds::config

  $packages           = $suiteds::config::ldap_client_packages
  $services           = $suiteds::config::ldap_client_services
  $configs            = $suiteds::config::ldap_client_configs
  $ldap_map           = $suiteds::config::ldap_map
  $ldap_access_groups = $suiteds::config::ldap_access_groups

  package{ $packages:
    ensure => $ensure,
  }
  suiteds::toggle{ $configs:
    ensure  => $ensure,
    require => Package[ $packages ],
    notify  => Service[ $services ],
  }
  case $ensure {
    'present','installed': {
      service{ $services:
        ensure => 'running',
        enable => 'true',
      }
    }
    'absent','removed','purged': {
      service{ $services:
        ensure => 'stopped',
        enable => 'false',
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }
}
