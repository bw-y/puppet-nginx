class nginx::config::old_conf {

  nginx::resource::old_conf{ $::nginx::old_conf: }

}
