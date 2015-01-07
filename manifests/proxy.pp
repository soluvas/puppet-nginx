# Define: nginx::proxy
#
# Reverse proxy to (usually) Java webapp, with or without HTTPS, with HTTP/1.1 and WebSockets support.
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * proxy_pass: URI of backend webapp
# * server_name : server_name directive (could be an array)
# * listen : address/port the server listen to. Defaults to 80. Auto enable ssl if 443
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
# * include : custom include for the site (could be an array). Include files must exists
#   to avoid nginx reload errors. Use with nginx::site_include
# * ssl_certificate : ssl_certificate path. If empty auto-generating ssl cert
# * ssl_certificate_key : ssl_certificate_key path. If empty auto-generating ssl cert key
#   See http://wiki.nginx.org for details.
#
# Templates :
# * nginx/proxy.erb
#
# Sample Usage :
#
#   # Hyperic HQ
#   nginx::proxy { "hyperic.${::fqdn}":
#     proxy_pass          => 'http://localhost:7080/',
#     listen              => 443,
#     ssl_certificate     => '/etc/ssl/certs/star.example.com.chained.crt',
#     ssl_certificate_key => '/etc/ssl/private/star.example.com.key',
#     require             => [ File['/etc/ssl/certs/star.example.com.chained.crt',
#                                   '/etc/ssl/private/star.example.com.key'] ],
#   }
#
define nginx::proxy(
  $ensure              = 'present',
  $include             = '',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '24h',
  $proxy_pass,
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
    content => template('nginx/proxy.erb'),
  }
}

