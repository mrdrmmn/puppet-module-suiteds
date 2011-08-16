# Definition: suiteds
#
# This module installs and configures a complete suite of directory services
# on a set of servers in an N-way master conifuration and configures other
# machines to utilize the directory services for authentication and
# authorization.
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
define suiteds (
  $ensure                = undef,
  $servers               = undef,
  $domains               = undef,
  $default_domain        = undef,
  $admin_user            = undef,
  $admin_password        = undef,
  $base_path             = undef,
  $config_path           = undef,
  $misc_path             = undef,
  $ldap_path             = undef,
  $exec_path             = undef,
  $pam_min_uid           = undef,
  $pam_max_uid           = undef,
  $log_level             = undef,

  $ldap_protocols        = undef,
  $ldap_default_protocol = undef,
  $ldap_version          = undef,
  $ldap_port             = undef,
  $ldaps_port            = undef,
  $bind_policy           = undef,
  $search_timelimit      = undef,
  $bind_timelimit        = undef,
  $idle_timelimit        = undef,
  $sasl_minssf           = undef,
  $sasl_maxssf           = undef,

  $ssl_mode              = undef,
  $ssl_minimum           = undef,
  $ssl_verify_certs      = undef,
  $ssl_cacert_file       = undef,
  $ssl_cacert_path       = undef,
  $ssl_cert_file         = undef,
  $ssl_key_file          = undef,
  $ssl_cipher_suite      = undef,
  $ssl_cert_country      = undef,
  $ssl_cert_state        = undef,
  $ssl_cert_city         = undef,
  $ssl_cert_organization = undef,
  $ssl_cert_department   = undef,
  $ssl_cert_domain       = undef,
  $ssl_cert_email        = undef,

  $krb5_port             = undef,
  $krb5adm_port          = undef,
  $krb4_port             = undef
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Suiteds::Dummy[ 'suiteds' ] ) ) {
    fail( 'The "suiteds" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds': }

  # Load in our config and then play around with some variables..
  include suiteds::config

  $config_ensure                = $ensure                ? { default => $ensure,                '' => $suiteds::config::ensure                }
  $config_servers               = $servers               ? { default => $servers,               '' => $suiteds::config::servers               }

  if( ! $domains and ! $default_domain ) {
    $config_domains        = $suiteds::config::domains
    $config_default_domain = $suiteds::config::default_domain
  }
  if( ! $domains and $default_domain ) {
    $config_domains        = [ $default_domain ]
    $config_default_domain = $default_domain
  }
  if( $domains and ! $default_domain ) {
    $config_domains         = [ $domains ]
    $config_default_domains = inline_template( '<%= config_domains.flatten.at( 0 ) %>' )
  }

  $config_admin_user            = $admin_user            ? { default => $admin_user,            '' => $suiteds::config::admin_user            }
  $config_admin_password        = $admin_password        ? { default => $admin_password,        '' => $suiteds::config::admin_password        }
  $config_base_path             = $base_path             ? { default => $base_path,             '' => $suiteds::config::base_path             }

  # Make sure our paths are fully qualified.
  $temp_config_path = $config_path ? { default => $config_path, '' => $suiteds::config::config_path }
  case inline_template( '<%= temp_config_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_config_path = $temp_config_path                       }
    default: { $config_config_path = "${config_base_path}/$temp_config_path" }
  }
  $temp_misc_path = $misc_path ? { default => $misc_path, '' => $suiteds::config::misc_path }
  case inline_template( '<%= temp_misc_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_misc_path = $temp_misc_path                       }
    default: { $config_misc_path = "${config_base_path}/$temp_misc_path" }
  }
  $temp_ldap_path = $ldap_path ? { default => $ldap_path, '' => $suiteds::config::ldap_path }
  case inline_template( '<%= temp_ldap_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_ldap_path = $ldap_misc_path                       }
    default: { $config_ldap_path = "${config_base_path}/$temp_ldap_path" }
  }

  $config_exec_path             = $exec_path             ? { default => $exec_path,             '' => $suiteds::config::exec_path             }
  $config_pam_min_uid           = $pam_min_uid           ? { default => $pam_min_uid,           '' => $suiteds::config::pam_min_uid           }
  $config_pam_max_uid           = $pam_max_uid           ? { default => $pam_max_uid,           '' => $suiteds::config::pam_max_uid           }
  $config_log_level             = $log_level             ? { default => $log_level,             '' => $suiteds::config::log_level             }

  if( ! $ldap_protocols and ! $ldap_default_protocol ) {
    $config_ldap_protocols        = $suiteds::config::ldap_protocols
    $config_ldap_default_protocol = $suiteds::config::ldap_default_protocol
  }
  if( ! $ldap_protocols and $ldap_default_protocol ) {
    $config_ldap_protocols        = [ $ldap_default_protocol ]
    $config_ldap_default_protocol = $ldap_default_protocol
  }
  if( $ldap_protocols and ! $ldap_default_protocol ) {
    $config_ldap_protocols        = [ $ldap_default_protocol ]
    $config_ldap_default_protocol = inline_template( '<%= config_ldap_protocols.flatten.at( 0 ) %>' )
  }

  $config_ldap_version          = $ldap_version          ? { default => $ldap_version,          '' => $suiteds::config::ldap_version          }
  $config_ldap_port             = $ldap_port             ? { default => $ldap_port,             '' => $suiteds::config::ldap_port             }
  $config_ldaps_port            = $ldaps_port            ? { default => $ldaps_port,            '' => $suiteds::config::ldaps_port            }
  $config_ldap_bind_policy      = $ldap_bind_policy      ? { default => $ldap_bind_policy,      '' => $suiteds::config::ldap_bind_policy      }
  $config_search_timelimit      = $search_timelimit      ? { default => $search_timelimit,      '' => $suiteds::config::search_timelimit      }
  $config_bind_timelimit        = $bind_timelimit        ? { default => $bind_timelimit,        '' => $suiteds::config::bind_timelimit        }
  $config_idle_timelimit        = $idle_timelimit        ? { default => $idle_timelimit,        '' => $suiteds::config::idle_timelimit        }
  $config_sasl_minssf           = $sasl_minssf           ? { default => $sasl_minssf,           '' => $suiteds::config::sasl_minssf           }
  $config_sasl_maxssf           = $sasl_maxssf           ? { default => $sasl_maxssf,           '' => $suiteds::config::sasl_maxssf           }

  $config_ssl_mode              = $ssl_mode              ? { default => $ssl_mode,              '' => $suiteds::config::ssl_mode              }
  $config_ssl_minimum           = $ssl_minimum           ? { default => $ssl_minimum,           '' => $suiteds::config::ssl_minimum           }
  $config_ssl_verify_certs      = $ssl_verify_certs      ? { default => $ssl_verify_certs,      '' => $suiteds::config::ssl_verify_certs      }
  $config_ssl_cacert_file       = $ssl_cacert_file       ? { default => $ssl_cacert_file,       '' => $suiteds::config::ssl_cacert_file       }
  $config_ssl_cacert_path       = $ssl_cacert_path       ? { default => $ssl_cacert_path,       '' => $suiteds::config::ssl_cacert_path       }

  # Make sure our files are fully qualified.
  $temp_ssl_cert_file = $ssl_cert_file ? { default => $ssl_cert_file, '' => $suiteds::config::ssl_cert_file }
  case inline_template( '<%= temp_ssl_cert_file.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_ssl_cert_file = $temp_ssl_cert_file                 }
    default: { $config_ssl_cert_file = "${config_config_path}/$temp_ssl_cert_file" }
  }
  $temp_ssl_key_file  = $ssl_key_file  ? { default => $ssl_key_file,  '' => $suiteds::config::ssl_key_file  }
  case inline_template( '<%= temp_ssl_key_file.to_s.start_with?( "/" ) %>' ) {
    'true':  { $config_ssl_key_file = $temp_ssl_key_file                 }
    default: { $config_ssl_key_file = "${config_config_path}/$temp_ssl_key_file" }
  }

  $config_ssl_cipher_suite      = $ssl_cipher_suite      ? { default => $ssl_cipher_suite,      '' => $suiteds::config::ssl_cipher_suite      }
  $config_ssl_cert_country      = $ssl_cert_country      ? { default => $ssl_cert_country,      '' => $suiteds::config::ssl_cert_country      }
  $config_ssl_cert_state        = $ssl_cert_state        ? { default => $ssl_cert_state,        '' => $suiteds::config::ssl_cert_state        }
  $config_ssl_cert_city         = $ssl_cert_city         ? { default => $ssl_cert_city,         '' => $suiteds::config::ssl_cert_city         }
  $config_ssl_cert_organization = $ssl_cert_organization ? { default => $ssl_cert_organization, '' => $suiteds::config::ssl_cert_organization }
  $config_ssl_cert_department   = $ssl_cert_department   ? { default => $ssl_cert_department,   '' => $suiteds::config::ssl_cert_department   }
  $config_ssl_cert_domain       = $ssl_cert_domain       ? { default => $ssl_cert_domain,       '' => $suiteds::config::ssl_cert_domain       }
  $config_ssl_cert_email        = $ssl_cert_email        ? { default => $ssl_cert_email,        '' => $suiteds::config::ssl_cert_email        }

  $config_krb5_port             = $krb5_port             ? { default => $krb5_port,             '' => $suiteds::config::krb5_port             }
  $config_krb5adm_port          = $krb5adm_port          ? { default => $krb5adm_port,          '' => $suiteds::config::krb5adm_port          }
  $config_krb4_port             = $krb4_port             ? { default => $krb4_port,             '' => $suiteds::config::krb4_port             }

    # First, check to see if the current node is supposed to be a server node.
  $is_server = inline_template( '<%= config_servers.flatten.include?( fqdn.downcase ) %>' )
  if( $is_server == 'true' ) {
    suiteds::server{ $config_ensure:
      ensure                => $config_ensure,
      servers               => $config_servers,
      domains               => $config_domains,
      default_domain        => $config_default_domain,
      admin_user            => $config_admin_user,
      admin_password        => $config_admin_password,
      base_path             => $config_base_path,
      config_path           => $config_config_path,
      misc_path             => $config_misc_path,
      ldap_path             => $config_ldap_path,
      exec_path             => $config_exec_path,
      pam_min_uid           => $config_pam_min_uid,
      pam_max_uid           => $config_pam_max_uid,
      log_level             => $config_log_level,

      ldap_protocols        => $config_ldap_protocols,
      ldap_default_protocol => $config_ldap_default_protocol,
      ldap_version          => $config_ldap_version,
      ldap_port             => $config_ldap_port,
      ldaps_port            => $config_ldaps_portf,
      bind_policy           => $config_bind_policy,
      search_timelimit      => $config_search_timelimit,
      bind_timelimit        => $config_bind_timelimit,
      idle_timelimit        => $config_idle_timelimit,
      sasl_minssf           => $config_sasl_minssf,
      sasl_maxssf           => $config_sasl_maxssf,

      ssl_mode              => $config_ssl_mode,
      ssl_minimum           => $config_ssl_minimum,
      ssl_verify_certs      => $config_ssl_verify_certs,
      ssl_cacert_file       => $config_ssl_cacert_file,
      ssl_cacert_path       => $config_ssl_cacert_path,
      ssl_cert_file         => $config_ssl_cert_file,
      ssl_key_file          => $config_ssl_key_file,
      ssl_cipher_suite      => $config_ssl_cipher_suite,
      ssl_cert_country      => $config_ssl_cert_country,
      ssl_cert_state        => $config_ssl_cert_state,
      ssl_cert_city         => $config_ssl_cert_city,
      ssl_cert_organization => $config_ssl_cert_organization,
      ssl_cert_department   => $config_ssl_cert_department,
      ssl_cert_domain       => $config_ssl_cert_domain,
      ssl_cert_email        => $config_ssl_cert_email,

      krb5_port             => $config_krb5_port,
      krb5adm_port          => $config_krb5adm_port,
      krb4_port             => $config_krb4_port,
    }
  }
}
