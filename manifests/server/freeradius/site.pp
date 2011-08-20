define suiteds::server::freeradius::site (
  $ensure,
  $path,
  $template,
  $suffix,
  $owner,
  $group,
  $mode = 0600
) {
  $domain = $name
  $file_path = "${path}/${domain}.${suffix}"

  case $ensure {
    'present': {
      $file_ensure = 'present'
    }
    'absent','purged': {
      $file_ensure = 'absent'
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }

  file{ $file_path:
    ensure  => $file_ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template( $template )
  }
}
