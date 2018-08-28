#
class nginx::config {

  class { '::nginx::config::main': } ->
  class { '::nginx::config::vhost': } ->
  class { '::nginx::config::location': } ->
  class { '::nginx::config::old_conf': } ->
  class { '::nginx::config::tracker_server': } ->
  class { '::nginx::config::tracker_location': } ->
  class { '::nginx::config::tracker_logrotate': }

  contain '::nginx::config::main'
  contain '::nginx::config::vhost'
  contain '::nginx::config::location'
  contain '::nginx::config::old_conf'
  contain '::nginx::config::tracker_server'
  contain '::nginx::config::tracker_location'
  contain '::nginx::config::tracker_logrotate'

}
