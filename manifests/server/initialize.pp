define suiteds::server::openldap (
  srv_init_file,
  srv_popuplate_file,
  dir_init_file,
  dir_populate_file
) {
  case $ensure {
    'present': {
    }
    'absent','purged': {
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }
}
