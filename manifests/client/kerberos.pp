define suiteds::client::kerberos (
  $ensure         = $suiteds::config::ensure,
  $servers        = $suiteds::config::servers,
  $domains        = $suiteds::config::domains,
  $default_domain = $suiteds::config::default_domain,
  $krb5_port      = $suiteds::config::krb5_port,
  $krb5adm_port   = $suiteds::config::krb5adm_port,
  $krb4_port      = $suiteds::config::krb4_port
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.         
  if( defined( Suiteds::Dummy[ 'suiteds::client::kerberos' ] ) ) {
    fail( 'The "suiteds::client::kerberos" define has already been called previously in your manifest!' )
  }
  suiteds::dummy{ 'suiteds::client::kerberos': }

  # Include our config.
  include suiteds::config

  $packages           = $suiteds::config::krb_client_packages
  $services           = $suiteds::config::krb_client_services
  $configs            = $suiteds::config::krb_client_configs
  $ldap_map           = $suiteds::config::ldap_map
  $ldap_access_groups = $suiteds::config::ldap_access_groups
  $root_user          = $suiteds::config::root_user
  $root_group         = $suiteds::config::root_group
  $krb_read_user      = $suiteds::config::krb_read_user
  $krb_write_user     = $suiteds::config::krb_write_user

  # Make sure our paths are fully qualified.
  $temp_krb_path = $suiteds::config::krb_path
  case inline_template( '<%= temp_krb_path.to_s.start_with?( "/" ) %>' ) {
    'true':  { $krb_path = $temp_krb_path                       }
    default: { $krb_path = "${base_path}/$temp_krb_path" }
  }

  package{ $packages:
    ensure => $ensure,
  }
  suiteds::toggle{ $configs:
    ensure  => $ensure,
    require => Package[ $packages ],
    #notify  => Service[ $services ],
  }
  case $ensure {
    'present','installed': {
      #service{ $services:
      #  ensure => 'running',
      #  enable => 'true',
      #}
    }
    'absent','removed','purged': {
      #service{ $services:
      #  ensure => 'stopped',
      #  enable => 'false',
      #}
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }
}
