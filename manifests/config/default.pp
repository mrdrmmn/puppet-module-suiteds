class suiteds::config::default {
  # An array of FQDNs of the hosts which will provide the directory services.
  $servers   = [ $fqdn ]

  # An array of domains for which we will provide directory services.  The
  # LDAP directory bases and Kerberos realms will be based off of this.
  $domains        = [ $domain ]

  # This this the domain name we will treat as primary when required.
  $default_domain = $domain

  # The admin user name and password.  This user will initially have full
  # rights to manage the directory services.
  $admin_user     = 'admin'
  $admin_password = $uniqueid

  # The base path where we will store all data.  This should be and empty or
  # non-existent directory.
  $base_path      = '/var/suiteds'
  $config_path    = 'etc'
  $misc_path      = 'misc'
  $ldap_path      = 'ldap'
  $krb_path       = 'kerberos'
  $ldap_pid_file  = 'slapd.pid'

  # This controls how we handle ssl certificate verification.  Valid values
  # are:  never, allow, try, and demand.  In general, if you are using self
  # signed certs, use 'never'.  Otherwise, use 'demand'.
  $ssl_verify_certs   = 'never'

  # What ciphers should be allowed for ssl connections.  This will vary based
  # on you specific needs and if your version of ldap was compiled against
  # openssl or gnutls.  For strong encryption, I think the following should be
  # sane:
  # openssl: 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'
  # gnutls:  'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'
  $ssl_cipher_suite      = 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'

  # The primary mode in which you want to use ssl.  Valid options are: off,
  # start_tls, and on.
  $ssl_mode              = 'on'
  
  # The minimum encryption level required to connect via ssl.
  $ssl_minimum           = '256'

  # The path to your ssl certificate and key.  If these do not exist, we
  # will auto generate once for you
  $ssl_cert_file         = 'ssl.crt'
  $ssl_key_file          = 'ssl.key'

  $ssl_cacert_file       = undef
  $ssl_cacert_path       = undef

  # sasl security properties.  this is only used locally and as near as I
  # can figure out, sasl does not work properly will ssl, so keep it a 0.
  # This should not be a problem as this only works over the unix socket
  # so it should be safe.
  $sasl_minssf           = '0'
  $sasl_maxssf           = undef

  # The values that will be used to generate a self signed cert if needed.
  $ssl_cert_country      = 'US'
  $ssl_cert_state        = 'California'
  $ssl_cert_city         = 'Culver City'
  $ssl_cert_organization = 'N/A'
  $ssl_cert_department   = 'N/A'
  $ssl_cert_domain       = $fqdn
  $ssl_cert_email        = "root@${fqdn}"

  # The path we will use for any 'Exec' resources
  $exec_path         = '/usr/sbin:/sbin:/usr/bin:/bin'

  # # # # # # # # # # # # # # # # # # # #
  # LDAP secific values
  # # # # # # # # # # # # # # # # # # # #
  $ldap_port             = '389'
  $ldaps_port            = '636'
  $ldap_protocols        = [ 'ldapi', 'ldaps', 'ldap' ]
  $ldap_default_protocol = 'ldaps'
  $ldap_version          = '3'
  $search_timelimit      = 15
  $bind_timelimit        = 15
  $idle_timelimit        = 15

  $ldap_schemas            = [
    'core.ldif',
    'cosine.ldif',
    'inetorgperson.ldif',
    'misc.ldif',
    'nis.ldif',
    'openldap.ldif',
    'samba.ldif',
    'apple.ldif',
    'kerberos.ldif',
  ]

  # [0] - A "friendly" name for this entry.
  # [1] - The db name based on nsswitch.
  # [2] - The method(s) used by nsswitch to look up data when ldap is disabled.
  # [3] - The method(s) used by nsswitch to look up data when ldap is enabled.
  # [4] - The OU where the data can be found in your ldap directory.
  # [5] - The key used to reference the db in ldap.conf.
  # [6] - The key used to reference the db in ldapscripts.conf.
  $db_mapping  = [
    'passwd    :passwd    :compat   :compat ldap [NOTFOUND=return] db   :People   :nss_base_passwd    :USUFFIX',
    'shadow    :shadow    :compat   :compat ldap [NOTFOUND=return] db   :People   :nss_base_shadow    :',
    'group     :group     :compat   :compat ldap [NOTFOUND=return] db   :Group    :nss_base_group     :GSUFFIX',
    'hosts     :hosts     :files dns:files dns ldap [NOTFOUND=return] db:Hosts    :nss_base_hosts     :',
    'services  :services  :db files :ldap [NOTFOUND=return] db files    :Services :nss_base_services  :',
    'networks  :networks  :files    :ldap [NOTFOUND=return] files       :Networks :nss_base_networks  :',
    'netmasks  :netmasks  :files    :ldap [NOTFOUND=return] files       :Networks :nss_base_netmasks  :',
    'protocols :protocols :db files :ldap [NOTFOUND=return] db files    :Protocols:nss_base_protocols :',
    'rpc       :rpc       :db files :ldap [NOTFOUND=return] db files    :Rpc      :nss_base_rpc       :',
    'ethers    :ethers    :db files :ldap [NOTFOUND=return] db files    :Ethers   :nss_base_ethers    :',
    'bootparams:bootparams:files    :ldap [NOTFOUND=return] files       :Ethers   :nss_base_bootparams:',
    'aliases   :aliases   :files    :ldap [NOTFOUND=return] files       :Aliases  :nss_base_aliases   :',
    'netgroup  :netgroup  :nis      :ldap [NOTFOUND=return] nis         :Netgroup :nss_base_netgroup  :',
    'machines  :          :         :                                   :Machines :                   :MSUFFUX',
    'mounts    :          :         :                                   :Mounts   :                   :',
    'macosx    :          :         :                                   :MacOSX   :                   :',
    'admin     :          :         :                                   :Admin    :                   :       ',
    'kerberos  :          :         :                                   :Kerberos :                   :       ',
  ]

  # # # # # # # # # # # # # # # # # # # #
  # Kerberos specific values
  # # # # # # # # # # # # # # # # # # # #
  $krb5_port      = '88'
  $krb5adm_port   = '749'
  $krb4_port      = '750'
  $krb_ldap_read  = 'krb-read'
  $krb_ldap_write = 'krb-write'

  # These variables will be modified by different portions of the config and
  # typically by the os specific portions.  They should not be manipulated
  # elsewhere.
  $server_packages   = []
  $server_services   = []
  $server_configs    = []
  $client_packages   = []
  $client_services   = []
  $client_configs    = []
  $ldap_user         = undef
  $ldap_group        = undef
  $root_user         = undef
  $root_group        = undef
} 
