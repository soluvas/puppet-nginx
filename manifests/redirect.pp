# Define: nginx::redirect
#
# Create a redirect site config from template using parameters.
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * server_name : server_name directive (an array)
# * status : redirect | permanent
# * listen : address/port the server listen to. Defaults to 80.
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
#
# Templates :
# * nginx/redirect_site.erb
#
# Sample Usage :
#  nginx::redirect { 'plus.elektronikrumah.com':
#  	server_name   => ['plus.elektronikrumah.com', 'www.plus.elektronikrumah.com'],
#    dest          => 'https://plus.google.com/106343484564841395454',
#    status        => permanent,
#  }
#
define nginx::redirect(
  $dest,
  $ensure              = 'present',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $status              = 'redirect') {

  $real_server_name = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $real_access_log = $access_log ? {
    undef   => "/var/log/nginx/${name}_access.log",
    default => $access_log,
  }

  nginx::site { $name:
    ensure  => $ensure,
    content => template('nginx/redirect_site.erb'),
  }
}

