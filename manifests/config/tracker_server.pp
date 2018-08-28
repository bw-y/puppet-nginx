class nginx::config::tracker_server {

  create_resources('nginx::resource::tracker_server', $::nginx::tracker_servers, $::nginx::tracker_servers_defaults)

}
