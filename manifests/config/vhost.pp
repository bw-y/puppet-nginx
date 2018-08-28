class nginx::config::vhost {

  create_resources('nginx::resource::vhost', $::nginx::vhosts, $::nginx::vhosts_defaults)

}
