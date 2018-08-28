# Class: nginx
#
class nginx (

  $down_dir                   = '/opt/nginx',
  $conf_dir                   = '/etc/nginx',
  $vhost_dir                  = '/etc/nginx/vhost',
  $ssl_dir                    = '/etc/nginx/ssl',
  $log_dir                    = '/var/log/nginx',
  $pid_file                   = '/var/run/nginx.pid',
  $err_log                    = '/var/log/nginx/error.log',
  $work_user                  = 'www-data',
  $default_type               = 'application/octet-stream',
  $gzip_types                 = 'application/x-javascript',
  $nginx_manage               = 'reload',
  $worker_connections         = 102400,
  $worker_rlimit_nofile       = 1048576,
  $old_conf                   = [],

  $log_files                  = {},
  $vhosts                     = {},
  $vhosts_defaults            = {},
  $locations                  = {},
  $locations_defaults         = {},
  $tracker_logrotate          = {},
  $tracker_logrotate_defaults = {},
  $tracker_servers            = {},
  $tracker_servers_defaults   = {},
  $tracker_locations          = {},
  $tracker_locations_defaults = {},

  $stage                      = 'application'
) inherits ::nginx::params {

  anchor { 'nginx::begin': } ->
  class { '::nginx::pre': } ->
  class { '::nginx::install': } ->
  class { '::nginx::config': } ~>
  class { '::nginx::service': } ->
  anchor { 'nginx::end': }

}
