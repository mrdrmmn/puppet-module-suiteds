define suiteds::toggle (
  $ensure
) {
  $present = inline_template( '<%= name.split(":").at(0).to_s.strip %>' )
  $absent  = inline_template( '<%= name.split(":").at(1).to_s.strip %>' )
  $owner   = inline_template( '<%= name.split(":").at(2).to_s.strip %>' )
  $group   = inline_template( '<%= name.split(":").at(3).to_s.strip %>' )
  $mode    = inline_template( '<%= name.split(":").at(4).to_s.strip %>' )
  $tmpl    = inline_template( '<%= name.split(":").at(5).to_s.strip %>' )
  $file    = inline_template( '<%= name.split(":").at(6).to_s.strip %>' )

  case $ensure {
    'present': {
      $file_ensure = $ensure
    }
    'absent','purged': {
      $file_ensure = 'absent'
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }

  file{ $file:
    ensure  => $file_ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template( "suiteds/${tmpl}" )
  }
}
