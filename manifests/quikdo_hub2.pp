define nginx::quikdo_hub2(
  $home,
  $domain,
  $ensure              = 'present',
  $index               = 'index.html index.php',
  $include             = '',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '5m',
  $appserver_uri       = 'http://localhost:8080/',
  $tenant_id,
  $tenant_env,
) {

  $real_server_name = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $real_access_log = $access_log ? {
    undef   => "/var/log/nginx/${name}_access.log",
    default => $access_log,
  }

  # Autogenerating ssl certs
  if $listen == '443' and  $ensure == 'present' and ($ssl_certificate == undef or $ssl_certificate_key == undef) {
    exec { "generate-${name}-certs":
      command => "/usr/bin/openssl req -new -inform PEM -x509 -nodes -days 999 -subj \
        '/C=ZZ/ST=AutoSign/O=AutoSign/localityName=AutoSign/commonName=${real_server_name}/organizationalUnitName=AutoSign/emailAddress=AutoSign/' \
        -newkey rsa:2048 -out /etc/nginx/ssl/${name}.pem -keyout /etc/nginx/ssl/${name}.key",
      unless  => "/usr/bin/test -f /etc/nginx/ssl/${name}.pem",
      require => File['/etc/nginx/ssl'],
      notify  => Service['nginx'],
    }
  }

  $real_ssl_certificate = $ssl_certificate ? {
    undef   => "/etc/nginx/ssl/${name}.pem",
    default => $ssl_certificate,
  }

  $real_ssl_certificate_key = $ssl_certificate_key ? {
    undef   => "/etc/nginx/ssl/${name}.key",
    default => $ssl_certificate_key,
  }

  nginx::site { $name:
    ensure  => $ensure,
    content => template('nginx/quikdo_hub.erb'),
  }
}

