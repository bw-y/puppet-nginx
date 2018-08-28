class nginx::config::location {

  create_resources('nginx::resource::location', $::nginx::locations, $::nginx::locations_defaults)

}
