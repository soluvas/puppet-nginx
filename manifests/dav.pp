# Define: nginx::dav
#
# Create a WebDAV site config from template using parameters.
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * server_name : server_name directive (an array)
# * root : filesystem path to document root
# * listen : address/port the server listen to. Defaults to 80.
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
#
# Templates :
# * nginx/dav.erb
#
# Sample Usage :
#  nginx::dav { "dav.berbatik.${::fqdn}":
#    root           => "/home/${developer}/berbatik_dev/dav",
#    write_user     => 'berbatik_dev',
#    write_password => 'bippo',
#    require        => File["/home/${developer}/berbatik_dev/dav"],
#  }
define nginx::dav(
  $root,
  $ensure               = 'present',
  $listen               = '80',
  $server_name          = undef,
  $access_log           = undef,
  $client_max_body_size = '8M',
  $write_user           = '',
  $write_password       = '') {

  $real_server_name = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $real_access_log = $access_log ? {
    undef   => "/var/log/nginx/${name}_access.log",
    default => $access_log,
  }

  if $write_user != '' {
  	file { "/etc/nginx/sites-htpasswd/${name}.htpasswd":
  	  content => template('nginx/htpasswd.erb'),
  	  owner   => 'root',
  	  group   => 'root',
  	  mode    => 0644,
  	  require => File['/etc/nginx/sites-htpasswd'],
  	}
  } else {
  	file { "/etc/nginx/sites-htpasswd/${name}.htpasswd":
  	  ensure  => absent,
  	}
  }

  nginx::site { $name:
    ensure  => $ensure,
    content => template('nginx/dav.erb'),
  }

}
