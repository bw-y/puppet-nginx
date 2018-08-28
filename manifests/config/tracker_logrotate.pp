class nginx::config::tracker_logrotate {

  create_resources('nginx::resource::tracker_logrotate', $::nginx::tracker_logrotate, $::nginx::tracker_logrotate_defaults)

}
