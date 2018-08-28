#
class nginx::service {
  if ! ($::nginx::nginx_manage in [ 'reload', 'start', 'stop', 'rotate' ]) {
    fail('nginx_manage must be [start|stop|restart|reload|rotate|configtest]')
  }

  exec { "nginx ${::nginx::nginx_manage}":
    refreshonly => true,
    logoutput   => on_failure,
    path        => $::nginx::exec_path,
    subscribe   => Class['::nginx::config'],
    command     => "${::nginx::down_dir}/${::nginx::nginx_ctrl_sh} \
${::nginx::nginx_manage}"
  }

}
