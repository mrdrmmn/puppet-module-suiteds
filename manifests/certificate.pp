define suiteds::certificate (
  $ensure       = $suiteds::config::ensure,
  $owner        = $suiteds::config::root_user,
  $group        = $suiteds::config::root_group,
  $cert_file    = $suiteds::config::ssl_cert_file,
  $key_file     = $suiteds::config::ssl_key_file,
  $country      = $suiteds::config::ssl_cert_country,
  $state        = $suiteds::config::ssl_cert_state,
  $city         = $suiteds::config::ssl_cert_city,
  $organization = $suiteds::config::ssl_cert_organization,
  $department   = $suiteds::config::ssl_cert_department,
  $domain       = $suiteds::config::ssl_cert_domain,
  $email        = $suiteds::config::ssl_cert_email,
  $exec_path    = $suiteds::config::exec_path
) {
  $exec_create = "echo '${country}\n${state}\n${city}\n${organization}\n${department}\n${domain}\n${email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${key_file}' -out '${cert_file}'"
  $exec_exists = "test -s '${cert_file}' || test -s '${key_file}'"

  File{
    owner => $owner,
    group => $group,
    mode  => '0600',
  }

  case $ensure {
    'present': {
      # Make sure that we have an ssl certificate.  If not, generate a self-
      # signed certificate as long as the files are empty.
      if( ! defined( File[ $cert_file ] ) ) {
        file{ $cert_file:
          ensure  => $ensure,
          notify  => Exec[ $name ],
        }
      }
      if( ! defined( File[ $key_file ] ) ) {
        file{ $key_file:
          ensure  => $ensure,
          notify  => Exec[ $name ],
        }
      }
      exec{ $name:
        path        => $exec_path,
        command     => $exec_create,
        unless      => $exec_exists,
        refreshonly => 'true',
      }
    }
    'absent','purged': {
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
