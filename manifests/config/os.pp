class suiteds::config::os inherits suiteds::config::default {
  case $operatingsystem {
    'ubuntu','debian': {
      $ldap_user   = 'openldap'
      $ldap_group  = 'openldap'
      $root_user   = 'root'
      $root_group  = 'root'
      $nslcd_user  = 'nslcd'
      $nslcd_group = 'nslcd'
      $ssl_cipher_suite = 'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'

      $ldap_server_packages = [
        'slapd',
        'ldap-utils',
      ]
      $ldap_server_services = [
        'slapd',
      ]
      $ldap_server_configs  = [
        "present:absent:${root_user}:${root_group}:0644:server/debian/slapd   :/etc/default/slapd       ",
        "present:absent:${root_user}:${root_group}:0644:server/ldap.conf      :/etc/ldap/ldap.conf      ",
        "present:absent:${root_user}:${root_group}:0644:server/macodconfig.xml:/etc/ldap/mackdconfig.xml",
      ]

      $krb_server_packages = [
        'krb5-admin-server',
        'krb5-kdc',
        'krb5-kdc-ldap',
      ]
      $krb_server_services = [
        'krb5-admin-server',
        'krb5-kdc',
      ]
      $krb_server_configs = [
        "present:absent:${root_user}:${root_group}:0644:server/kdc.conf    :/etc/krb5kdc/kdc.conf",
      ]

      $ldap_client_packages = [
        'nss-updatedb',
        'libpam-ccreds',
        'libnss-db',
        'nslcd',
        'libpam-ldapd',
      ]
      $ldap_client_services = [
        'nslcd',
      ]
      $ldap_client_configs  = [
        "present:present:${root_user}:${root_group} :0644:client/nsswitch.conf:/etc/nsswitch.conf",
        "present:absent :${root_user}:${root_group} :0644:client/ldap.conf    :/etc/ldap.conf    ",
        "present:absent :${root_user}:${root_group} :0600:client/ldap.secret  :/etc/ldap.secret  ",
        "present:absent :${root_user}:${nslcd_group}:0640:client/nslcd.conf   :/etc/nslcd.conf   ",
      ]

      $krb_client_packages = [
        'krb5-user',
        'libpam-krb5',
      ]
      $krb_client_configs = [
        "present:absent:${root_user}:${root_group}:0644:client/krb5.conf   :/etc/krb5.conf       ",
      ]

    }

    'linux','centos','fedora': {
      $ldap_user  = 'ldap'
      $ldap_group = 'ldap'
      $root_user  = 'root'
      $root_group = 'root'
      $ssl_cipher_suite = 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'

      $ldap_server_packages = [
        'openldap-servers',
        'openldap-clients',
      ]
      $ldap_server_services = [
        'slapd'
      ]
      $ldap_server_configs  = [
        "present:absent:${root_user}:${root_group}:0644:server/redhat/ldap:/etc/sysconfig/ldap    ",
        "present:absent:${root_user}:${root_group}:0644:server/ldap.conf  :/etc/openldap/ldap.conf",
      ]

      $ldap_client_packages = [
        'pam_ccreds',
        'nss_db',
        'nss-pam-ldapd',
      ]
      $ldap_client_services = [
        'nslcd',
      ]
      $ldap_client_configs = [
        "present:present:${root_user}:${root_group}:0644:client/nsswitch.conf:/etc/nsswitch.conf",
        "present:absent :${root_user}:${root_group}:0644:client/ldap.conf    :/etc/pam_ldap.conf",
        "present:absent :${root_user}:${root_group}:0600:client/ldap.secret  :/etc/ldap.secret  ",
        "present:absent :${root_user}:${root_group}:0600:client/nslcd.conf   :/etc/nslcd.conf   ",
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
