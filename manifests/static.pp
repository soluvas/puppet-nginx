# Define: nginx::static
#
# Create a static site config from template using parameters.
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * server_name : server_name directive (an array)
# * root : filesystem path to document root
# * listen : address/port the server listen to. Defaults to 80.
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
#
# Templates :
# * nginx/static.erb
#
# Sample Usage :
#  nginx::static { 'www.kreasiindonesia.com':
#  	 server_name  => ['www.kreasiindonesia.com', 'kreasiindonesia.com',
#                     'm.kreasiindonesia.com', 'www.m.kreasiindonesia.com',
#                     'skin.kreasiindonesia.com', 'media.kreasiindonesia.com',
#                     'js.kreasiindonesia.com',
#                     'plus.kreasiindonesia.com', 'www.plus.kreasiindonesia.com'],
#    root         => '/home/magento/www_maintenance',
#  }
define nginx::static(
  $root,
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
    content => template('nginx/static.erb'),
  }
}

