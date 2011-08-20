define suiteds::toggle (
  $ensure,
  $path = undef
) {
  $present = inline_template( '<%= name.split(":").at(0).to_s.strip %>' )
  $absent  = inline_template( '<%= name.split(":").at(1).to_s.strip %>' )
  $owner   = inline_template( '<%= name.split(":").at(2).to_s.strip %>' )
  $group   = inline_template( '<%= name.split(":").at(3).to_s.strip %>' )
  $mode    = inline_template( '<%= name.split(":").at(4).to_s.strip %>' )
  $tmpl    = inline_template( '<%= name.split(":").at(5).to_s.strip %>' )
  $file    = inline_template( '<%= name.split(":").at(6).to_s.strip %>' )

  $file_path = inline_template( '<%= file.to_s.start_with?( "/" ) %>' ) ? {
    'true'  => $file,
    default => "${path}/${file}"
  }

  case $ensure {
    'present': {
      $file_ensure = $present
    }
    'absent','purged': {
      $file_ensure = $absent
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
    content => template( "suiteds/${tmpl}" )
  }
}
