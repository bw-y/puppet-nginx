class nginx::config::tracker_location {

  create_resources('nginx::resource::tracker_location', $::nginx::tracker_locations, $::nginx::tracker_locations_defaults)

}
