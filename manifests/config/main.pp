#
class nginx::config::main {

  file { "${::nginx::conf_dir}/nginx.conf":
    group   => 0,
    mode    => '0644',
    owner   => $::nginx::work_user,
    content => template("${module_name}/nginx.conf.erb")
  }

  cron { 'nginx error log clean':
    ensure  => present,
    hour    => '0',
    minute  => '30',
    user    => root,
    command => "echo > ${::nginx::err_log}"
  }

}
