# Define: nginx::redirect_uri
#
# Create a redirect site config preserving request URI,
# useful to map e.g. http://tuneeca.com/hendy to http://www.tuneeca.com/hendy
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * server_name : server_name directive (an array) -- optional
# * status : redirect | permanent
# * listen : address/port the server listen to. Defaults to 80.
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
# * dest : Destination URI, do not end with slash!
#
# Templates :
# * nginx/redirect_site.erb
#
# Sample Usage :
#  nginx::redirect { 'aksimata.com':
#    dest          => 'http://www.aksimata.com',
#    status        => permanent,
#  }
#
define nginx::redirect_uri(
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
    content => template('nginx/redirect_uri.erb'),
  }
}

